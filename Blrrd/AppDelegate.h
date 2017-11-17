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

#import "BCredentialsObject.h"
#import "BQueryObject.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIGestureRecognizerDelegate, SRWebSocketDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) SRWebSocket *sockets;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundtask;

-(void)applicationRegisterPushNotifications;
-(void)applicationHandleSockets:(BOOL)terminate;

@end

