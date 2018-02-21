//
//  AppDelegate.m
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "BConstants.h"
#import "BDetailedTimelineController.h"
#import "BOnboardingController.h"
#import "BCompleteController.h"
#import "BFriendFinderController.h"
#import "GDFeedbackController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.credentials = [[BCredentialsObject alloc] init];
    self.mixpanel = [Mixpanel sharedInstance];
    self.pushbots = [[Pushbots alloc] initWithAppId:@"5a5a6091a5d10304d650b176" prompt:false];

    [Mixpanel sharedInstanceWithToken:@"e25f29857e2e509f1f1e6befde7b7688"];
    [AppAnalytics initWithAppKey:@"4Xuz4xbSahIJ8VbfFkamJSve8fEQ5RwC" options:@{DebugLog:@(NO)}];
    [self.pushbots trackPushNotificationOpenedWithPayload:launchOptions];

    [self.credentials setDeviceIdentifyer];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        [self.data setBool:true forKey:@"app_inactive"];
        [self.data synchronize];
        
    }
    
    if (![self.data boolForKey:@"app_installed"]) {
        [self.credentials setAppSaveImages:true];
        if (!APP_DEBUG_MODE) [self.mixpanel track:@"App Installed" properties:nil];

    }
    else {
        if (!APP_DEBUG_MODE) [self.mixpanel track:@"App Opened" properties:@{@"version":APP_VERSION, @"build":APP_BUILD}];

    }
    
    [self applicationVersionCheck];
    [self applicationCheckCrashes];
    [self applicationSetActiveTimer:true];
    
    [application setMinimumBackgroundFetchInterval:APP_DEBUG_MODE?UIApplicationBackgroundFetchIntervalMinimum:3600*3];
    
    [[UITextField appearance] setTintColor:UIColorFromRGB(0x69DCCB)];
    [[UITextView appearance] setTintColor:UIColorFromRGB(0x69DCCB)];
    
    [self.data setBool:true forKey:@"app_installed"];
    [self.data synchronize];
    
    return true;
    
}

-(void)applicationHandleSockets:(BOOL)terminate {
    /*
    self.credentials = [[BCredentialsObject alloc] init];
    self.sockets = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://62.75.213.212:8000/ws/viewtimesNewApi/%@" ,self.credentials.userHandle]]];
    self.sockets.delegate = self;
    
    if (terminate) [self.sockets close];
    else if (self.sockets != nil) [self.sockets open];
    */
    
}

-(void)applicationCheckCrashes {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.mixpanel = [Mixpanel sharedInstance];
    if ([[self.data objectForKey:@"app_installed"] boolValue] && ![[self.data objectForKey:@"app_killed"] boolValue]) {
        if (![self.credentials userAdmin]) {
            [self.mixpanel track:@"App Crashed"];
            [self.query cacheDestroy:nil];

        }
        
    }
    
    [self.data setBool:false forKey:@"app_killed"];
    [self.data synchronize];
    
}

-(void)applicationVersionCheck {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.credentials = [[BCredentialsObject alloc] init];
    self.mixpanel = [Mixpanel sharedInstance];
    if ([[self.data objectForKey:@"app_installed"] boolValue] && ([[self.data objectForKey:@"app_version"] floatValue] != APP_VERSION_FLOAT || [[self.data objectForKey:@"app_build"] floatValue] != APP_BUILD_FLOAT || [[self.data objectForKey:@"app_version"] floatValue] == 0)) {
        [self.credentials setFriendsAdded:false];
        [self.data setFloat:APP_VERSION_FLOAT forKey:@"app_version"];
        [self.data setFloat:APP_BUILD_FLOAT forKey:@"app_build"];
        if (![self.credentials userAdmin]) {
            [self.mixpanel track:@"App Updated To New Version" properties:@{@"Version":APP_VERSION}];
            
        }
        
    }
    
}

-(void)applicationSetActiveTimer:(BOOL)initiate  {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.credentials = [[BCredentialsObject alloc] init];
    self.mixpanel = [Mixpanel sharedInstance];

    if (!self.timer.isValid && initiate) self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(applicationSetActiveTimer:) userInfo:nil repeats:true];
    
    int active = [[self.data objectForKey:@"app_timer"] intValue] + 1;
    
    [self.data setInteger:active forKey:@"app_timer"];
    [self.data synchronize];
    
    
    
}

-(void)applicationRatePrompt {
    self.credentials = [[BCredentialsObject alloc] init];
    self.mixpanel = [Mixpanel sharedInstance];
    if (self.credentials.userTotalRevealedTime > 60 * 5 && self.credentials.userPosts > 0 && self.credentials.appRated == false) {
        if (APP_DEVICE_FLOAT >= 10.3) {
            [SKStoreReviewController requestReview];
            [self.credentials setAppRated:true];
            [self.mixpanel track:@"App Rated"];
            
        }
        
    }
    
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.query =  [[BQueryObject alloc] init];
    self.query.background = true;
    self.mixpanel = [Mixpanel sharedInstance];
    self.backgroundtask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:self.backgroundtask];
        [self setBackgroundtask:UIBackgroundTaskInvalid];
        
    }];
    
    [self.mixpanel timeEvent:@"App Updated Content in Background"];
    
    if ([self.query cacheExpired:@"following"]) {
        [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
            [self.mixpanel track:@"App Updated Content in Background"];
            
            if (error.code == 200 || error == nil) completionHandler(UIBackgroundFetchResultNewData);
            else completionHandler(UIBackgroundFetchResultNewData);
            
        }];
        
    }
    else completionHandler(UIBackgroundFetchResultNoData);
    
}

-(void)applicationWillResignActive:(UIApplication *)application {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.credentials = [[BCredentialsObject alloc] init];

    [self.data setObject:[NSDate date] forKey:@"app_lastopened"];
    [self.data setBool:true forKey:@"app_killed"];
    [self.data synchronize];
    
    [self.timer invalidate];
    [self applicationHandleSockets:true];
    
}

-(void)applicationWillTerminate:(UIApplication *)application {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.credentials = [[BCredentialsObject alloc] init];

    [self.data setObject:[NSDate date] forKey:@"app_lastopened"];
    [self.data setBool:true forKey:@"app_killed"];
    [self.data synchronize];
    
    [self.timer invalidate];
    [self applicationHandleSockets:true];

}

-(void)applicationDidEnterBackground:(UIApplication *)application {

}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    [self applicationHandleSockets:true];

}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    [self applicationHandleSockets:false];

}

-(void)applicationNotificationsAuthorized:(void (^)(UNAuthorizationStatus authorized))completion {
    if (APP_DEVICE >= 10){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"Settings Push: %@" ,settings);
                completion(settings.authorizationStatus);
                
            }];
            
        }];
        
    }
    else {
        completion([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]?UNAuthorizationStatusAuthorized:UNAuthorizationStatusNotDetermined);
        
    }
    
}

-(void)applicationAuthorizeRemoteNotifications:(void (^)(NSError *error, BOOL granted))completion {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound|UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UIApplication sharedApplication] registerForRemoteNotifications];

            completion(error, granted);
            
        }];
            
    }];
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.mixpanel = [Mixpanel sharedInstance];
    self.credentials = [[BCredentialsObject alloc] init];

    NSString *token = [deviceToken.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"token: %@ user: %@" ,deviceToken ,self.credentials.userHandle);
    if (self.credentials.userHandle != nil) {
        [self.pushbots registerOnPushbots:deviceToken];
        [self.pushbots setAlias:self.credentials.userHandle];

    }

    [self.credentials setDevicePush:token];
    [self.mixpanel.people addPushDeviceToken:deviceToken];
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo  {
    self.query = [[BQueryObject alloc] init];
    if (application.applicationState == UIApplicationStateActive) {
        [self.query cacheDestroy:@"content/time.php"];
        [self.query queryNotifications:^(NSArray *notifications, NSError *error) {
            NSLog(@"did recive notification");
            
        }];
        
        [self.pushbots trackPushNotificationOpenedWithPayload:userInfo];
        
    }
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [self applicationOpenFromURL:url];
    
    return true;
    
}

-(void)applicationOpenFromURL:(NSURL *)url {
    self.mixpanel = [Mixpanel sharedInstance];
    self.credentials = [[BCredentialsObject alloc] init];
    self.query = [[BQueryObject alloc] init];
    self.instagram = [[BInstagramObject alloc] init];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *components in [url.query componentsSeparatedByString:@"&"]) {
        [parameters setObject:[[components componentsSeparatedByString:@"="] lastObject] forKey:[[components componentsSeparatedByString:@"="] firstObject]];
        
    }
    
    if (parameters) {
        [self.mixpanel track:@"App Opened from URL" properties:@{@"URL":[NSString stringWithFormat:@"%@" ,url]}];
        
        [(UINavigationController  *)self.window.rootViewController popToRootViewControllerAnimated:false];
        [(UINavigationController  *)self.window.rootViewController dismissViewControllerAnimated:false completion:nil];
        
        if ([url.host isEqualToString:@"login"]) {
            if (self.credentials.userEmail != nil) {
                BCompleteController *viewCompletion = [[BCompleteController alloc] init];
                viewCompletion.type = BCompleteScreenAutoLogin;
                viewCompletion.data = @{@"password":[parameters objectForKey:@"newpass"], @"email":self.credentials.userEmail};
                
                UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:viewCompletion];
                navigation.navigationBarHidden = true;
                
                [(UINavigationController  *)self.window.rootViewController presentViewController:navigation animated:true    completion:nil];

            }
            else {
                BOnboardingController *viewOnboarding = [[BOnboardingController alloc] init];
                viewOnboarding.view.backgroundColor = MAIN_BACKGROUND_COLOR;
                
                UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:viewOnboarding];
                navigation.navigationBarHidden = true;

                [(UINavigationController  *)self.window.rootViewController presentViewController:navigation animated:true    completion:nil];
                
            }
            
        }
        
        if ([url.host isEqualToString:@"instagram"]) {
            [self.query postUpdateUser:nil type:@"instagram" value:[parameters objectForKey:@"username"] completion:^(NSError *error) {
                if (error.code == 200) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.credentials setInstagramKey:[parameters objectForKey:@"key"]];
                        [self.credentials setInstagramUsername:[parameters objectForKey:@"username"]];
                        [self.credentials setInstagramToken:[parameters objectForKey:@"tok"]];
                        
                        if (!self.credentials.userAdmin) {
                            [self.mixpanel track:@"App Instagram Added" properties:@{@"Username":self.credentials.instagramHandle}];
                            
                        }
                        
                        BFriendFinderController *viewFriend = [[BFriendFinderController alloc] init];
                        viewFriend.header = NSLocalizedString(@"Friend_Header_Text", nil);
                        
                        [(UINavigationController  *)self.window.rootViewController pushViewController:viewFriend animated:false];
                        
                    }];
                    
                    [self.instagram queryInstagramProfile:^(NSDictionary *profile) {
                        if ([self.credentials userFullname] == nil && [profile objectForKey:@"full_name"] != nil) {
                            [self.query postUpdateUser:nil type:@"fullname" value:[profile objectForKey:@"full_name"] completion:^(NSError *error) {
                                if (error.code == 200) {
                                    [self.credentials setUserFullname:[profile objectForKey:@"full_name"]];
                                    if ([self.credentials userGender] > 0) {
                                        [self.query postUpdateUser:nil type:@"gender" value:[NSString stringWithFormat:@"%d" ,self.credentials.userGender] completion:^(NSError *error) {
                                            
                                        }];
                                        
                                    }
                                }
                                
                            }];
                            
                        }
                        
                        if ([self.credentials userWebsite] == nil && [profile objectForKey:@"website"] != nil) {
                            [self.query postUpdateUser:nil type:@"website" value:[profile objectForKey:@"website"] completion:^(NSError *error) {
                                if (error.code == 200) {
                                    [self.credentials setUserWebsite:[profile objectForKey:@"website"]];
                                    
                                }
                                
                            }];
                            
                        }
                        
                        [self.instagram updateFriendship:@"463375653" action:@"follow" completion:^(NSError *error) {
                            NSLog(@"updatw friedshipt: %@" ,error);
                            
                        }];
                        
                    }];
                    
                }
                
            }];
            
        }
        
        if ([url.host isEqualToString:@"user"]) {
            BDetailedTimelineController *viewProfile = [[BDetailedTimelineController alloc] init];
            if ([[parameters objectForKey:@"key"] containsString:@"user_"]) {
                if ([self.credentials.userKey isEqualToString:[parameters objectForKey:@"key"]]) {
                    viewProfile.type = BDetailedViewTypeMyPosts;
                    viewProfile.data = @{@"name":NSLocalizedString(@"Profile_MyPosts_Header", nil), @"username":self.credentials.userHandle};
                    
                }
                else viewProfile.type = BDetailedViewTypeUserProfile;
                
            }
            else {
                if ([self.credentials.userHandle isEqualToString:[parameters objectForKey:@"handle"]]) {
                    viewProfile.type = BDetailedViewTypeMyPosts;
                    viewProfile.data = @{@"name":NSLocalizedString(@"Profile_MyPosts_Header", nil), @"username":self.credentials.userHandle};

                    [(UINavigationController  *)self.window.rootViewController pushViewController:viewProfile animated:false];

                }
                else {
                    [self.query querySuggestedUsers:[parameters objectForKey:@"handle"] emails:nil socials:nil completion:^(NSArray *users, NSError *error) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            if (error.code == 200 && users.count > 0) {
                                viewProfile.type = BDetailedViewTypeUserProfile;
                                viewProfile.data = users.firstObject;
                                
                                NSLog(@"querySuggestedUsers; %@" ,users.firstObject);
                                
                                [(UINavigationController  *)self.window.rootViewController pushViewController:viewProfile animated:true];
                                
                            }
                            
                        }];
                        
                    }];
                   

                }
                
            }


        }
        
        if ([url.host isEqualToString:@"feedback"]) {
            GDFeedbackController *viewFeedback = [[GDFeedbackController alloc] init];
            viewFeedback.header = NSLocalizedString(@"Settings_ItemFeedback_Title", nil);
            viewFeedback.type = @"In-App Feedback";
            viewFeedback.placeholder = NSLocalizedString(@"Settings_FeedbackPlaceholder_Text", nil);
            
            [(UINavigationController  *)self.window.rootViewController pushViewController:viewFeedback animated:false];

        }
        
        if ([url.host isEqualToString:@"rate"]) {
            [SKStoreReviewController requestReview];
            [self.credentials setAppRated:true];
            [self.mixpanel track:@"App Rated"];
            
        }
        
        if ([url.host isEqualToString:@"reset"]) {
            if ([parameters objectForKey:@"full"]) {
                [self.credentials destoryAllCredentials];
            
                BOnboardingController *viewOnboarding = [[BOnboardingController alloc] init];
                viewOnboarding.view.backgroundColor = MAIN_BACKGROUND_COLOR;

                [(UINavigationController  *)self.window.rootViewController presentViewController:viewOnboarding animated:true    completion:nil];

            }
            
            [self.query cacheDestroy:nil];

            [[SDImageCache sharedImageCache] clearMemory];
            [[SDImageCache sharedImageCache] clearDisk];
            
        }
    }
    
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (IS_IPHONE) return UIInterfaceOrientationMaskPortrait;
    else return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    
}


-(BOOL)shouldAutorotate {
    return false;
    
}

-(void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"webSocketDidOpen %@" ,webSocket);
    
}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string {
    NSLog(@"webSocketDidReceiveMessageWithString %@" ,string);

}

-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data {
    NSLog(@"webSocketdidReceiveMessageWithData %@" ,data);

}

-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"webSocketdidFailWithError %@" ,error);

}

-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"webSocketDidOpen %@" ,webSocket);

}

@end
