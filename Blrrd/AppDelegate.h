//
//  AppDelegate.h
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <UserNotifications/UserNotifications.h>
#import <Mixpanel.h>
#import <SRWebSocket.h>
#import <AppAnalytics/Appanalytics.h>
#import <Pushbots/Pushbots.h>

#import "BCredentialsObject.h"
#import "BQueryObject.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIGestureRecognizerDelegate, SRWebSocketDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) SRWebSocket *sockets;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) NSTimer *timer;
@property (strong, nonatomic) Pushbots *pushbots;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundtask;

-(void)applicationNotificationsAuthorized:(void (^)(UNAuthorizationStatus authorized))completion;
-(void)applicationAuthorizeRemoteNotifications:(void (^)(NSError *error, BOOL granted))completion;
-(void)applicationHandleSockets:(BOOL)terminate;
-(void)applicationRatePrompt;

@end

