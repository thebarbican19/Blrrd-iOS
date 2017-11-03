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
       
    }
    return self;
    
}

-(void)authenticationLoginWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion {
    NSString *endpoint = @"userApi/checkUser/";
    NSString *method = @"POST";
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint dictionary:credentials method:method] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
    NSString *endpoint = [NSString stringWithFormat:@"postsApi/%@/?myusername=%@" ,page==0?@"getAllFriendsPostsV2":@"getAllFriendsPostsNext" ,self.credentials.userHandle];
    NSString *method = @"GET";
    NSArray *cache = [self cacheRetrive:endpoint];
    if (cache != nil) {
        completion(cache, [self requestErrorHandle:200 message:@"returned from cache" error:nil]);
        
    }
    else {
        NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint dictionary:nil method:method] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
            if (data.length > 0 && !error) {
                if (status.statusCode == 200) {
                    [self cacheSave:[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"data"] endpoint:endpoint];
                    
                    completion([self cacheRetrive:endpoint], [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil]);
                    
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

-(void)cacheSave:(id)data endpoint:(NSString *)endpoint {
    if (data != nil) {
        [self.data setObject:@{@"data":data, @"expiry":[NSDate dateWithTimeIntervalSinceNow:60*60]} forKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]];
        [self.data synchronize];
        
        if (self.debug) NSLog(@"\n\nSaved Cache 💾 with Key %@ \n\n", endpoint);

    }
    
}

-(id)cacheRetrive:(NSString *)endpoint {
    NSDate *expiry = [[self.data objectForKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]] objectForKey:@"expiry"];
    if ([[NSDate date] compare:expiry] == NSOrderedDescending || expiry == nil) return nil;
    else return [[self.data objectForKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]] objectForKey:@"data"];
    
}

-(NSURLSession *)requestSession:(BOOL)main {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.qualityOfService = NSQualityOfServiceBackground;
    
    return [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:main?[NSOperationQueue mainQueue]:queue];
    
}

-(NSError *)requestErrorHandle:(int)code message:(NSString *)message error:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];

    if (error) return [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    else if (message == nil && error == nil) return [NSError errorWithDomain:@"unknown error" code:600 userInfo:nil];
    else return [NSError errorWithDomain:message code:code userInfo:nil];
    
}

-(NSMutableURLRequest *)requestMaster:(NSString *)endpoint dictionary:(NSDictionary *)dictionary method:(NSString *)method {
    NSURL *sessionEndpoint = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@" ,APP_HOST_URL, endpoint]];
    NSMutableURLRequest *sessionRequest = [NSMutableURLRequest requestWithURL:sessionEndpoint cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [sessionRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [sessionRequest setHTTPMethod:method];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
    
    if (dictionary != nil) {
        [sessionRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:@[dictionary] options:NSJSONWritingPrettyPrinted error:nil]];
        
    }
    
    if (self.debug) NSLog(@"\n\nLoading ✍️ %@: %@\n\n" ,method, sessionEndpoint);
    
    return sessionRequest;
    
}


@end
