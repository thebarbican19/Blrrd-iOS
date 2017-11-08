//
//  BQueryObject.m
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BQueryObject.h"
#import "BConstants.h"

@implementation BQueryObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.credentials = [[BCredentialsObject alloc] init];
        self.mixpanel = [Mixpanel sharedInstance];

    }
    return self;
    
}

-(NSDictionary *)retriveEndpoint:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ || key == %@" ,key ,key];
    NSMutableArray *endpoints = [[NSMutableArray alloc] init];
    [endpoints addObject:@{@"endpoint":@"userApi/checkUser/",
                           @"method":@"POST",
                           @"name":@"authenticate",
                           @"key":@"authenticate",
                           @"parameter":@""}];
    [endpoints addObject:@{@"endpoint":@"postsApi/getAllFriendsPostsV2/",
                           @"method":@"GET",
                           @"name":@"friendstimelineone",
                           @"key":@"maintimeline",
                           @"parameter":[NSString stringWithFormat:@"?myusername=%@" ,self.credentials.userHandle]}];
    [endpoints addObject:@{@"endpoint":@"postsApi/getAllFriendsPostsNext/",
                           @"method":@"GET",
                           @"name":@"friendstimelinenext",
                           @"key":@"maintimeline",
                           @"parameter":[NSString stringWithFormat:@"?myusername=%@" ,self.credentials.userHandle]}];
  
    
    
    NSMutableDictionary *returned = [[NSMutableDictionary alloc] initWithDictionary:[[endpoints filteredArrayUsingPredicate:predicate] firstObject]];
    NSString *output = [NSString stringWithFormat:@"%@%@%@" ,APP_HOST_URL ,[returned objectForKey:@"endpoint"] ,[returned objectForKey:@"parameter"]];
    [returned setObject:[NSURL URLWithString:output] forKey:@"url"];
    
    return returned;
    
}

-(void)authenticationLoginWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion {
    NSDictionary *endpoint = [self retriveEndpoint:@"authenticate"];
    NSString *endpointmethod = [endpoint objectForKey:@"method"];
    NSURL *endpointurl = [endpoint objectForKey:@"url"];
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpointurl dictionary:credentials method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            if (status.statusCode == 200) {
                NSDictionary *user = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [self.credentials setUserIdentifyer:[user objectForKey:@"id"]];
                [self.credentials setUserEmail:[user objectForKey:@"email"]];
                [self.credentials setUserHandle:[user objectForKey:@"username"]];
                [self.credentials setUserAvatar:[user objectForKey:@"photo"]];
                [self.credentials setUserPublic:[[user objectForKey:@"publicuser"] boolValue]];
                [self.credentials setDevicePush:[user objectForKey:@"pushId"]];

                [self.mixpanel.people set:@{@"$name":self.credentials.userHandle==nil?@"Unknown User":self.credentials.userHandle,
                                          @"$email":self.credentials.userEmail==nil?@"":self.credentials.userEmail}];
                [self.mixpanel identify:self.credentials.userKey];
                
                completion(user, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil]);
                
            }
            else if (status.statusCode == 500) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil]);
                
            }
            
        }
        else completion(nil, [self requestErrorHandle:(int)error.code message:nil error:error]);

    }];
    
    [task resume];
    
}

-(void)authenticationSignupWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion {
    
}

-(void)queryFriendsTimeline:(int)page completion:(void (^)(NSArray *posts, NSError *error))completion {
    NSDictionary *endpoint = [self retriveEndpoint:page==0?@"friendstimelineone":@"friendstimelinenext"];
    NSString *endpointname = [endpoint objectForKey:@"name"];
    NSString *endpointmethod = [endpoint objectForKey:@"method"];
    NSURL *endpointurl = [endpoint objectForKey:@"url"];

    BOOL cacheexpired = [self cacheExpired:endpointname];
    if (cacheexpired == false) {
        completion([self cacheRetrive:endpointname], [self requestErrorHandle:200 message:@"returned from cache" error:nil]);
        
    }
    else {
        NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpointurl dictionary:nil method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
            if (data.length > 0 && !error) {
                if (status.statusCode == 200) {
                    [self cacheSave:[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"data"] endpointname:endpointname append:page==0?false:true];
                    
                    completion([self cacheRetrive:endpointname], [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil]);
                    
                }
                else if (status.statusCode == 500) {
                    completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil]);
                    
                }
                
            }
            else completion(nil, [self requestErrorHandle:(int)error.code message:nil error:error]);
            
        }];
        
        [task resume];
        
    }
    
}

-(void)cacheSave:(id)data endpointname:(NSString *)endpoint append:(BOOL)append {
    if (data != nil) {
        [self.data setObject:@{@"data":data, @"expiry":[NSDate dateWithTimeIntervalSinceNow:60*60]} forKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]];
        [self.data synchronize];
        
        if (self.debug) NSLog(@"\n\nSaved Cache 💾 with Key %@ \n\n", endpoint);

    }
    
}

-(id)cacheRetrive:(NSString *)endpoint {
    if ([self.data objectForKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]] == nil) return [[NSArray alloc] init];
    else return [[self.data objectForKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]] objectForKey:@"data"];

}

-(BOOL)cacheExpired:(NSString *)endpoint {
    NSDate *expiry = [[self.data objectForKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]] objectForKey:@"expiry"];
    if ([[NSDate date] compare:expiry] == NSOrderedDescending || expiry == nil) return true;
    else if ([self.data objectForKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]] == nil) return true;
    else return false;
    
}

-(NSURLSession *)requestSession:(BOOL)main {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.qualityOfService = NSQualityOfServiceBackground;
    
    return [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:main?[NSOperationQueue mainQueue]:queue];
    
}

-(NSError *)requestErrorHandle:(int)code message:(NSString *)message error:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
    
    if (code == 401) {
        [self.credentials destoryAllCredentials];
        if ([self.delegate respondsToSelector:@selector(viewCheckAuthenticaion)]) {
            [self.delegate viewCheckAuthenticaion];
            
        }
        
    }

    if (error) return [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    else if (message == nil && error == nil) return [NSError errorWithDomain:@"unknown error" code:600 userInfo:nil];
    else return [NSError errorWithDomain:message code:code userInfo:nil];
    
}

-(NSMutableURLRequest *)requestMaster:(NSURL *)endpoint dictionary:(NSDictionary *)dictionary method:(NSString *)method {
    NSMutableURLRequest *sessionRequest = [NSMutableURLRequest requestWithURL:endpoint cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [sessionRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [sessionRequest setHTTPMethod:method];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
    
    if (dictionary != nil) {
        [sessionRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:@[dictionary] options:NSJSONWritingPrettyPrinted error:nil]];
        
    }
    
    if (self.debug) NSLog(@"\n\nLoading ✍️ %@: %@\n\n" ,method, endpoint);
    
    return sessionRequest;
    
}


@end
