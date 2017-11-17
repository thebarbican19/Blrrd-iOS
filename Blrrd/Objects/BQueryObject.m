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

-(void)authenticationLoginWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion {
    NSString *endpoint = @"userApi/checkUser/";
    NSString *endpointmethod = @"POST";
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:@[credentials] method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                
                completion(user, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 500) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            
        }
        else completion(nil, [self requestErrorHandle:(int)error.code message:nil error:error endpoint:endpoint]);

    }];
    
    [task resume];
    
}

-(void)authenticationSignupWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion {
    
}

-(void)queryTimeline:(BQueryTimeline)type page:(int)page completion:(void (^)(NSArray *posts, NSError *error))completion {
    NSString *endpoint;
    if (type == BQueryTimelineTrending) endpoint = [NSString stringWithFormat:@"channelsApi/getChannelsHotPostsNext"];
    else endpoint = [NSString stringWithFormat:@"postsApi/getAllFriendsPostsNext"];
    NSString *endpointmethod = @"GET";
    NSDictionary *endpointparams = @{@"myusername":self.credentials.userHandle, @"skipnumber":@(page * 10)};

    BOOL cacheexpired = [self cacheExpired:endpoint];
    if (cacheexpired == false && page == 0) {
        completion([self cacheRetrive:endpoint], [self requestErrorHandle:200 message:@"returned from cache" error:nil endpoint:endpoint]);
        
    }
    else {
        NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
            if (data.length > 0 && !error) {
                if (status.statusCode == 200) {
                    NSMutableArray *posts = [[NSMutableArray alloc] init];
                    [posts addObjectsFromArray:[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"data"]];
                    
                    [self cacheSave:posts endpointname:endpoint append:page==0?false:true expiry:60*60];
                    
                    completion(posts, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                    
                }
                else if (status.statusCode == 500) {
                    completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                    
                }
                
            }
            else completion(nil, [self requestErrorHandle:(int)error.code message:nil error:error endpoint:endpoint]);
            
        }];
        
        [task resume];
        
    }
    
}

-(void)queryChannels:(void (^)(NSArray *channels, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"channelsApi/getChannels"];
    NSString *endpointmethod = @"GET";
    NSDictionary *endpointparams = @{@"myusername":self.credentials.userHandle};

    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            if (status.statusCode == 200) {
                NSMutableArray *channels = [[NSMutableArray alloc] init];
                [channels addObjectsFromArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
                                
                [self cacheSave:channels endpointname:endpoint append:false expiry:60*60*24];
                
                completion(channels, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 500) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            
        }
        else {
            completion(nil, [self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
}

-(void)queryChannelByIdentifyer:(NSString *)identifyer page:(int)page completion:(void (^)(NSArray *channel, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"channelsApi/getChannelPosts"];
    NSString *endpointmethod = @"GET";
    NSDictionary *endpointparams = @{@"channelname":identifyer, @"skipnumber":@(page * 10)};
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            if (status.statusCode == 200) {
                NSMutableArray *channels = [[NSMutableArray alloc] init];
                [channels addObjectsFromArray:[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] objectForKey:@"data"]];
                
                [self cacheSave:channels endpointname:endpoint append:page==0?false:true expiry:60*5];

                completion(channels, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 500) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            
        }
        else {
            completion(nil, [self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
    
}

-(void)queryNotifications:(void (^)(NSArray *notifications, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"postsApi/getViewTimesNewApi"];
    NSString *endpointmethod = @"GET";
    NSDictionary *endpointparams = @{@"username":self.credentials.userHandle};
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"posted_datetime" ascending:false];
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            if (status.statusCode == 200) {
                NSMutableArray *notifications = [[NSMutableArray alloc] init];
                for (NSDictionary *item in [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]) {
                    NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:item];
                    [append setObject:[self requestTimestamp:[item objectForKey:@"posted_datetime"]] forKey:@"posted_datetime"];
                    [notifications addObject:append];

                }
                
                [self cacheSave:[notifications sortedArrayUsingDescriptors:@[sort]] endpointname:endpoint append:false expiry:60*30];
                
                completion([notifications sortedArrayUsingDescriptors:@[sort]], [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 500) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            
        }
        else {
            completion(nil, [self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
}

-(void)queryRequests:(void (^)(NSArray *requests, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"friendsApi/getRequests"];
    NSString *endpointmethod = @"GET";
    NSDictionary *endpointparams = @{@"username":self.credentials.userHandle, @"gettype":@"notfriend"};

    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            if (status.statusCode == 200) {
                NSMutableArray *requests = [[NSMutableArray alloc] init];
                [requests addObjectsFromArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
                
                [self cacheSave:requests endpointname:endpoint append:false expiry:60*30];
                
                completion(requests, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 500) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            
        }
        else {
            completion(nil, [self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
}

-(void)querySuggestedUsers:(void (^)(NSArray *users, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"userApi/getAllUsers"];
    NSString *endpointmethod = @"GET";
    NSDictionary *endpointparams = @{@"myusername":self.credentials.userHandle, @"gettype":@"members"};
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            if (status.statusCode == 200) {
                NSMutableArray *requests = [[NSMutableArray alloc] init];
                [requests addObjectsFromArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
                
                [self cacheSave:requests endpointname:endpoint append:false expiry:60*30];
                
                completion(requests, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 500) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            
        }
        else {
            completion(nil, [self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
}

-(void)postTime:(NSDictionary *)image secondsadded:(int)seconds completion:(void (^)(NSError *error))completion {
    NSString *uniqueid = [NSString stringWithFormat:@"%d" ,(int)[[NSDate date] timeIntervalSince1970]];
    NSString *endpoint = [NSString stringWithFormat:@"postsApi/addViewTime"];
    NSString *endpointmethod = @"POST";
    NSDictionary *endpointparams = @{@"postId":[image objectForKey:@"id"],
                                     @"seconds":[NSNumber numberWithInt:seconds],
                                     @"username":self.credentials.userHandle,
                                     @"posted_datetime":[image objectForKey:@"posted_datetime"],
                                     @"id":uniqueid};
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        completion([self requestErrorHandle:(int)status.statusCode message:error.domain error:error endpoint:endpoint]);

    }];
    
    [task resume];
    
}

-(void)cacheSave:(id)data endpointname:(NSString *)endpoint append:(BOOL)append expiry:(int)expiry {
    if (data != nil) {
        NSString *key = [NSString stringWithFormat:@"cache_%@" ,endpoint];
        NSMutableArray *content = [[NSMutableArray alloc] init];
        if (append) [content addObjectsFromArray:[self cacheRetrive:endpoint]];
        [content addObjectsFromArray:data];

        [self.data setObject:@{@"data":content, @"expiry":[NSDate dateWithTimeIntervalSinceNow:expiry]} forKey:key];
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

-(void)cacheDestroy {
    for (NSString *key in [[self.data dictionaryRepresentation] allKeys]) {
        if ([key containsString:@"cache"]) [self.data removeObjectForKey:key];
        
    }
    
}

-(NSURLSession *)requestSession:(BOOL)main {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.qualityOfService = main?NSQualityOfServiceUtility:NSQualityOfServiceBackground;
    
    return [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:queue];
    
}

-(NSError *)requestErrorHandle:(int)code message:(NSString *)message error:(NSError *)error endpoint:(NSString *)endpoint {
    if (code == 401) {
        [self.credentials destoryAllCredentials];
        if ([self.delegate respondsToSelector:@selector(viewCheckAuthenticaion)]) {
            [self.delegate viewCheckAuthenticaion];
            
        }
        
    }
    
    NSError *err;
    if (error) err = [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    else if (message == nil && error == nil) err = [NSError errorWithDomain:@"unknown error" code:600 userInfo:nil];
    else if (message == nil && error.localizedDescription != nil) [NSError errorWithDomain:error.localizedDescription code:error.code userInfo:nil];
    else err = [NSError errorWithDomain:message code:code userInfo:nil];
    
    if (err == nil || err.code == 200) {
        if (self.debug) NSLog(@"\n\nSucsess %d 🎉 %@\n\n" ,code ,endpoint);

    }
    else if (self.debug) NSLog(@"\n\nError %d 🎉 %@\n\n" ,code ,message);

    return err;
    
}

-(NSMutableURLRequest *)requestMaster:(NSString *)endpoint params:(id)params method:(NSString *)method {
    NSMutableString *buildendpoint = [[NSMutableString alloc] init];
    [buildendpoint appendString:APP_HOST_URL];
    [buildendpoint appendString:endpoint];
    [buildendpoint appendString:@"/"];
    
    if (![method isEqualToString:@"POST"] && [params isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)params;
        
        [buildendpoint appendString:@"?"];
        for (NSString *key in dictionary.allKeys) {
            [buildendpoint appendString:[NSString stringWithFormat:@"%@=%@&" ,key ,[params objectForKey:key]]];
            
        }
           
        [buildendpoint setString:[buildendpoint substringWithRange:NSMakeRange(0, buildendpoint.length - 1)]];
                                       
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:buildendpoint] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:method];
        
    if (params != nil && [method isEqualToString:@"POST"]) {
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil]];
        
    }
    
    if (self.debug) NSLog(@"\n\nLoading ✍️ %@: %@\n\n" ,method, buildendpoint);
    
    return request;
    
}

-(NSDate *)requestTimestamp:(NSString *)timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";
    
    NSDateFormatter *formattertwo = [[NSDateFormatter alloc] init];
    formattertwo.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";

    if ([formatter dateFromString:timestamp] == nil) return [formattertwo dateFromString:timestamp];
    else return [formatter dateFromString:timestamp];
    
}
@end
