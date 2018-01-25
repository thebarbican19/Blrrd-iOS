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
    NSString *endpoint = @"user/login.php";
    NSString *endpointmethod = @"POST";
    
    if ([[credentials objectForKey:@"email"] length] > 0 && [[credentials objectForKey:@"password"] length] > 0) {
        NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:credentials method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
            if (data.length > 0 && !error) {
                NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                if ([[output objectForKey:@"error_code"] intValue] == 200) {
                    NSDictionary *user = [output objectForKey:@"user"];
                    [self.credentials setUserIdentifyer:[user objectForKey:@"key"]];
                    [self.credentials setUserEmail:[user objectForKey:@"email"]];
                    [self.credentials setUserHandle:[user objectForKey:@"username"]];
                    [self.credentials setUserAvatar:[user objectForKey:@"avatar"]];
                    [self.credentials setUserPublic:[[user objectForKey:@"public"] boolValue]];
                    [self.credentials setUserType:[user objectForKey:@"type"]];
                    [self.credentials setAuthToken:[[user objectForKey:@"auth"] objectForKey:@"token"]];
                    [self.credentials setAuthExpiry:[[user objectForKey:@"auth"] objectForKey:@"expiry"]];
                    [self.credentials setUserTotalTime:[[[user objectForKey:@"stats"] objectForKey:@"totaltime"] intValue] append:false];

                    NSLog(@"useer %@" ,user);
                    
                    [self.mixpanel.people set:@{@"$name":self.credentials.userHandle==nil?@"Unknown User":self.credentials.userHandle,
                                              @"$email":self.credentials.userEmail==nil?@"":self.credentials.userEmail}];
                    [self.mixpanel identify:self.credentials.userKey];
                    [self.mixpanel track:@"App Logged In"];
                    
                    completion(user, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                    
                }
                else if (status.statusCode == 401) {
                    completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                    
                }
                else {
                    NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                    completion(nil, [self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
                    
                }
                
                
            }
            else completion(nil, [self requestErrorHandle:(int)error.code message:nil error:error endpoint:endpoint]);

        }];
        
        [task resume];
        
    }
    else completion(nil, [self requestErrorHandle:400 message:@"Username cannot be nil" error:nil endpoint:endpoint]);

}

-(void)authenticationSignupWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion {
    NSString *endpoint = @"user/signup.php";
    NSString *endpointmethod = @"POST";

    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:credentials method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
            if ([[output objectForKey:@"error_code"] intValue] == 200) {
                NSDictionary *user = [output objectForKey:@"user"];
                [self.credentials setUserIdentifyer:[user objectForKey:@"key"]];
                [self.credentials setUserEmail:[user objectForKey:@"email"]];
                [self.credentials setUserHandle:[user objectForKey:@"username"]];
                [self.credentials setUserAvatar:[user objectForKey:@"avatar"]];
                [self.credentials setUserPublic:[[user objectForKey:@"public"] boolValue]];
                [self.credentials setUserType:[user objectForKey:@"type"]];
                [self.credentials setAuthToken:[[user objectForKey:@"auth"] objectForKey:@"token"]];
                [self.credentials setAuthExpiry:[[user objectForKey:@"auth"] objectForKey:@"expiry"]];
                [self.credentials setUserTotalTime:[[[user objectForKey:@"stats"] objectForKey:@"totaltime"] intValue] append:false];

                [self.mixpanel.people set:@{@"$name":self.credentials.userHandle==nil?@"Unknown User":self.credentials.userHandle,
                                            @"$email":self.credentials.userEmail==nil?@"":self.credentials.userEmail}];
                [self.mixpanel identify:self.credentials.userKey];
                
                completion(user, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if ([[output objectForKey:@"error_code"] intValue] == 401) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            else {
                NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                completion(nil, [self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);

            }
            
        }
        else completion(nil, [self requestErrorHandle:(int)error.code message:nil error:error endpoint:endpoint]);
        
    }];
    
    [task resume];
}

-(void)authenticationDestroy:(void (^)(NSError *error))completion {
    NSString *endpoint = @"user/me.php";
    NSString *endpointmethod = @"DELETE";
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:nil method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
            if ([[output objectForKey:@"error_code"] intValue] == 200) {
                [self.credentials destoryAllCredentials];
                [self cacheDestroy:nil];

            }
            
            completion([self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:error endpoint:endpoint]);
            
        }
        else completion([self requestErrorHandle:(int)error.code message:nil error:error endpoint:endpoint]);

    }];
    
    [task resume];
    
}

-(void)queryTimeline:(BQueryTimeline)type page:(int)page completion:(void (^)(NSArray *posts, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"content/timeline.php"];
    NSString *endpointmethod = @"GET";
    NSMutableDictionary *endpointparams = [[NSMutableDictionary alloc] init];
    [endpointparams setObject:@(page) forKey:@"pagnation"];
    if (type == BQueryTimelineTrending) [endpointparams setObject:@"trending" forKey:@"type"];
    else [endpointparams setObject:@"following" forKey:@"type"];

    BOOL cacheexpired = [self cacheExpired:[endpointparams objectForKey:@"type"]];
    if (cacheexpired == false && page == 0) {
        completion([self cacheRetrive:[endpointparams objectForKey:@"type"]], [self requestErrorHandle:200 message:@"returned from cache" error:nil endpoint:endpoint]);
        
    }
    else {
        NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
            if (data.length > 0 && !error) {
                NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                if ([[output objectForKey:@"error_code"] intValue] == 200) {
                    NSMutableArray *posts = [[NSMutableArray alloc] init];
                    [posts addObjectsFromArray:[output objectForKey:@"output"]];
                    
                    [self cacheSave:posts endpointname:[endpointparams objectForKey:@"type"] append:page==0?false:true expiry:60*50];
                    
                    completion(posts, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                    
                }
                else if (status.statusCode == 401) {
                    completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                    
                }
                else {
                    NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                    completion(nil, [self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
                    
                }
                
            }
            else completion(nil, [self requestErrorHandle:(int)error.code message:nil error:error endpoint:endpoint]);
            
        }];
        
        [task resume];
        
    }
    
}

-(void)queryUserPosts:(NSString *)username page:(int)page completion:(void (^)(NSArray *items, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"user/posts.php"];
    NSString *endpointmethod = @"GET";
    NSDictionary *endpointparams;
    NSLog(@"queryUserPosts %@" ,username);
    if (username == nil || [self.credentials.userKey isEqualToString:username]) endpointparams = @{@"pagnation":@(page)};
    else endpointparams = @{@"pagnation":@(page), @"userid":username};

    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSLog(@"queryuser %@" ,[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            if (status.statusCode == 200) {
                NSMutableArray *posts = [[NSMutableArray alloc] init];
                [posts addObjectsFromArray:[[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject] objectForKey:@"output"]];

                if ([username isEqualToString:self.credentials.userKey]) {
                    NSLog(@"saving cache: %@" ,username)
                    [self cacheSave:posts endpointname:self.credentials.userKey append:page==0?false:true expiry:60*60*24*4];
                    
                }
                
                completion(posts, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 401) {
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
    NSString *endpoint = [NSString stringWithFormat:@"content/time.php"];
    NSString *endpointmethod = @"GET";
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:nil method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
            if ([[output objectForKey:@"error_code"] intValue] == 200) {
                NSMutableArray *notifications = [[NSMutableArray alloc] init];
                for (NSDictionary *item in [output objectForKey:@"output"]) {
                    NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:item];
                    [append setObject:[self requestTimestamp:[item objectForKey:@"timestamp"]] forKey:@"timestamp"];
                    [notifications addObject:append];
                    
                }
                
                [self cacheSave:notifications endpointname:endpoint append:false expiry:60*5];
                
                completion(notifications, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 401) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            else {
                NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                completion(nil, [self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
                
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
    NSDictionary *endpointparams = @{@"username":self.credentials.userHandle, @"gettype":@"notfriends"};

    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            if (status.statusCode == 200) {
                NSMutableArray *requests = [[NSMutableArray alloc] init];
                [requests addObjectsFromArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
                
                [self cacheSave:requests endpointname:endpoint append:false expiry:60*30];
                
                completion(requests, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 401) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            else {
                NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                completion(nil, [self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
                
            }
            
        }
        else {
            completion(nil, [self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
}

-(void)querySuggestedUsers:(NSString *)search completion:(void (^)(NSArray *users, NSError *error))completion {
    NSString *endpointsearch =  [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *endpoint;
    if (search.length > 0) endpoint = [NSString stringWithFormat:@"user/suggested.php?search=%@" ,endpointsearch];
    else endpoint = [NSString stringWithFormat:@"user/suggested.php"];
    NSString *endpointmethod = @"GET";

    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:nil method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
            if ([[output objectForKey:@"error_code"] intValue] == 200) {
                NSMutableArray *requests = [[NSMutableArray alloc] init];
                [requests addObjectsFromArray:[output objectForKey:@"output"]];
                
                if (search == nil) {
                    [self cacheSave:requests endpointname:endpoint append:false expiry:60*30];
                    
                }
                
                completion(requests, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if ([[output objectForKey:@"error_code"] intValue] == 401) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            else {
                completion(nil, [self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
                
            }
            
        }
        else {
            completion(nil, [self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
}

-(void)queryFriends:(NSString *)type completion:(void (^)(NSArray *users, NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"user/friendship.php"];
    NSString *endpointmethod = @"GET";
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:nil method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
            if ([[output objectForKey:@"error_code"] intValue] == 200) {
                NSMutableArray *requests = [[NSMutableArray alloc] init];
                [requests addObjectsFromArray:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
                
                [self cacheSave:requests endpointname:endpoint append:false expiry:60*30];
                
                completion(requests, [self requestErrorHandle:(int)status.statusCode message:@"all okay" error:nil endpoint:endpoint]);
                
            }
            else if (status.statusCode == 401) {
                completion(nil, [self requestErrorHandle:401 message:@"credentials incorrect" error:nil endpoint:endpoint]);
                
            }
            else {
                completion(nil, [self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
                
            }
            
        }
        else {
            completion(nil, [self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
}

-(void)queryUserStats:(void (^)(NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"user/me.php"];
    NSString *endpointmethod = @"GET";
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:nil method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
            if ([[output objectForKey:@"error_code"] intValue] == 200) {
                NSDictionary *user = [output objectForKey:@"user"];
                NSDictionary *stats = [user objectForKey:@"stats"];
                
                [self cacheSave:stats endpointname:endpoint append:false expiry:60*5];
                
                [self.credentials setUserTotalTime:[[stats objectForKey:@"totaltime"] intValue] append:false];
                [self.credentials setUserEmail:[user objectForKey:@"email"]];
                [self.credentials setUserType:[user objectForKey:@"type"]];
                [self.credentials setUserPublic:[[user objectForKey:@"public"] boolValue]];
                [self.credentials setUserAvatar:[user objectForKey:@"avatar"]];
                [self.credentials setUserTotalPosts:[[stats objectForKey:@"posts"] intValue]];

            }
            
            completion([self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);

        }
        else {
            completion([self requestErrorHandle:(int)status.statusCode message:error.domain error:nil endpoint:endpoint]);
            
        }
        
    }];
    
    [task resume];
    
}

-(void)postTime:(NSDictionary *)image secondsadded:(int)seconds timeline:(BQueryTimeline)timeline completion:(void (^)(NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"content/time.php"];
    NSString *endpointmethod = @"POST";
    NSDictionary *endpointparams = @{@"postid":[image objectForKey:@"postid"],
                                     @"seconds":[NSNumber numberWithInt:seconds]};
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
            completion([self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
            
        }
        else {
            completion([self requestErrorHandle:(int)status.statusCode message:error.domain error:error endpoint:endpoint]);
            
        }

    }];
    
    if (timeline == BQueryTimelineFriends) [self cacheUpdatePostWithData:endpointparams endpoint:@"following"];
    else [self cacheUpdatePostWithData:endpointparams endpoint:@"trending"];
    
    [task resume];
    
}

-(void)postRequest:(NSString *)user request:(NSString *)request completion:(void (^)(NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"user/friendship.php?userid=%@" ,user];
    NSString *endpointmethod;
    if ([request isEqualToString:@"add"]) endpointmethod = @"POST";
    else endpointmethod = @"DELETE";
    
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:nil method:endpointmethod] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];

            completion([self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
            
        }
        else {
            completion([self requestErrorHandle:(int)status.statusCode message:error.domain error:error endpoint:endpoint]);
            
        }
        
    }];

    [task resume];
    
}

-(void)postReport:(NSString *)item message:(NSString *)message completion:(void (^)(NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"content/report.php"];
    NSDictionary *endpointparams = @{@"item":item, @"message":message};
    NSURLSessionTask *task = [[self requestSession:true] dataTaskWithRequest:[self requestMaster:endpoint params:endpointparams method:@"POST"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (data.length > 0 && !error) {
            NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
            
            completion([self requestErrorHandle:[[output objectForKey:@"error_code"] intValue] message:[output objectForKey:@"status"] error:nil endpoint:endpoint]);
            
        }
        else {
            completion([self requestErrorHandle:(int)status.statusCode message:error.domain error:error endpoint:endpoint]);
            
        }
        
    }];

    [task resume];
    
}

-(NSArray *)notificationsMergeByType:(BNotificationMergeType)type {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:false];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username != %@" ,self.credentials.userHandle];
    NSMutableArray *notifications = [[NSMutableArray alloc] initWithArray:[self cacheRetrive:@"content/time.php"]];
    
    NSLog(@"notifications %@" ,notifications);
    
    NSMutableArray *merge = [[NSMutableArray alloc] init];
    NSMutableArray *output = [[NSMutableArray alloc] init];
    for (NSDictionary *item in notifications) {
        NSMutableDictionary *format = [[NSMutableDictionary alloc] init];
        if (type == BNotificationMergeTypePosts) {
            [format setObject:[item objectForKey:@"postid"] forKey:@"postid"];
            
        }
        else if (type == BNotificationMergeTypeUniqueUsers) {
            [format setObject:[[item objectForKey:@"user"] objectForKey:@"username"] forKey:@"username"];
            
        }
        else {
            [format setObject:[item objectForKey:@"postid"] forKey:@"postid"];
            [format setObject:[[item objectForKey:@"user"] objectForKey:@"username"] forKey:@"username"];

        }
        
        [merge addObject:format];

    }
    
    NSCountedSet *counted = [[NSCountedSet alloc] initWithArray:merge];
    for (NSDictionary *merged in counted) {
        NSPredicate *predicate;
        if (type == BNotificationMergeTypePosts) {
            predicate = [NSPredicate predicateWithFormat:@"postid == %@" ,[merged objectForKey:@"postid"]];
            
        }
        else if (type == BNotificationMergeTypeUniqueUsers) {
            predicate = [NSPredicate predicateWithFormat:@"user.username == %@" ,[merged objectForKey:@"username"]];
            
        }
        else if (type == BNotificationMergeTypeUniqueUsersAndPosts) {
            predicate = [NSPredicate predicateWithFormat:@"postid == %@ && user.username == %@" ,[merged objectForKey:@"postid"], [merged objectForKey:@"username"]];

        }
        
        NSArray *filtered = [notifications filteredArrayUsingPredicate:predicate];
        NSLog(@"[notifications filteredArrayUsingPredicate:predicate] %@" ,[notifications filteredArrayUsingPredicate:predicate]);
        NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:filtered.firstObject];
        int totaltime = 0;
        for (NSDictionary *item in [notifications filteredArrayUsingPredicate:predicate]) {
            totaltime += [[item objectForKey:@"seconds"] intValue];
            
        }
        
        [append setObject:[merged objectForKey:@"postid"] forKey:@"postid"];
        [append setObject:@(totaltime) forKey:@"totalsecs"];
        [append setObject:@([counted countForObject:merged]) forKey:@"sessions"];

        [output addObject:append];
        
    }
    
    

    return [[output filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:@[sort]];
    
}

-(NSArray *)notificationsForSpecificImage:(NSString *)identifyer {
    NSArray *notifications = [[NSArray alloc] initWithArray:[self notificationsMergeByType:BNotificationMergeTypeUniqueUsersAndPosts]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:false];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postid == %@" ,identifyer];
    
    NSLog(@"identifyer %@ - %@" ,notifications ,identifyer)
    return [[notifications filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:@[sort]];
    
}

-(BOOL)friendCheck:(NSString *)username {
    NSArray *users = [[NSArray alloc] initWithArray:[self cacheRetrive:@"user/friendship.php"]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@" ,username];
    
    if ([[users filteredArrayUsingPredicate:predicate] count] > 0) return false;
    else return true;
    
}

-(NSArray *)friendsList {
    return nil;
    
}

-(void)cacheUpdatePostWithData:(NSDictionary *)data endpoint:(NSString *)endpoint {
    NSMutableArray *timelinedata = [[NSMutableArray alloc] initWithArray:[self cacheRetrive:endpoint]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", [data objectForKey:@"postId"]];
    NSUInteger index = [timelinedata indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [predicate evaluateWithObject:obj];
        
    }];
    
    if (index < timelinedata.count) {
        NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:[timelinedata objectAtIndex:index]];
        [append setObject:[data objectForKey:@"seconds"] forKey:@"seconds"];
        [append setObject:@([[append objectForKey:@"sectotal"] integerValue] + [[data objectForKey:@"seconds"] intValue]) forKey:@"seconds"];
        [append setObject:@([[append objectForKey:@"seen"] intValue] + 1) forKey:@"seen"];
        
        [timelinedata replaceObjectAtIndex:index withObject:append];
        [self cacheSave:timelinedata endpointname:endpoint append:false expiry:60*60];

    }
    else {
        [self cacheUpdatePostWithData:data endpoint:endpoint];

    }
    
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

-(void)cacheDestroy:(NSString *)endpoint {
    if (endpoint == nil) {
        for (NSString *key in [[self.data dictionaryRepresentation] allKeys]) {
            if ([key containsString:@"cache"]) {
                [self.data removeObjectForKey:key];
                [self.data synchronize];
                
            }
            
        }
        
    }
    else {
        [self.data removeObjectForKey:[NSString stringWithFormat:@"cache_%@" ,endpoint]];
        [self.data synchronize];

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
    self.credentials = [[BCredentialsObject alloc] init];
    NSMutableString *buildendpoint = [[NSMutableString alloc] init];
    [buildendpoint appendString:APP_HOST_URL];
    [buildendpoint appendString:endpoint];
    
    if (![method isEqualToString:@"POST"] && [params isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)params;
        
        [buildendpoint appendString:@"?"];
        for (NSString *key in dictionary.allKeys) {
            [buildendpoint appendString:[NSString stringWithFormat:@"%@=%@&" ,key ,[params objectForKey:key]]];
            
        }
           
        [buildendpoint setString:[buildendpoint substringWithRange:NSMakeRange(0, buildendpoint.length - 1)]];
                                       
    }
        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:buildendpoint] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request addValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"blappversion"];
    [request addValue:APP_LANGUAGE forHTTPHeaderField:@"bllanguage"];
    if (self.credentials.authToken) [request addValue:self.credentials.authToken forHTTPHeaderField:@"blbearer"];
    [request setHTTPMethod:method];
        
    if (params != nil && [method isEqualToString:@"POST"]) {
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil]];
        
    }
    
    if (self.debug) NSLog(@"\n\nLoading ✍️ %@: %@\n\n" ,method, buildendpoint);
    
    return request;
    
}

-(NSDate *)requestTimestamp:(NSString *)timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSDateFormatter *formattertwo = [[NSDateFormatter alloc] init];
    formattertwo.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";

    if ([formatter dateFromString:timestamp] == nil) return [formattertwo dateFromString:timestamp];
    else return [formatter dateFromString:timestamp];
    
}
@end
