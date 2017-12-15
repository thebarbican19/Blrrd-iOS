//
//  LaunchAuthorizationController.h
//  Teech
//
//  Created by Joe Barbour on 10/03/2017.
//  Copyright © 2017 Teech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <Mixpanel/Mixpanel.h>

#import "AppDelegate.h"
#import "BCredentialsObject.h"
#import "BQueryObject.h"

#import "GDPlaceholderView.h"

@interface BNotificationsController : UIViewController <UNUserNotificationCenterDelegate> {
    
}

@property (nonatomic, strong) AppDelegate *appdel;
@property (nonatomic, retain) Mixpanel *mixpanel;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;

@property (nonatomic, strong) UIImageView *viewIcon;
@property (nonatomic, strong) SAMLabel *viewInstructions;
@property (nonatomic, strong) UIButton *viewAction;
@property (nonatomic, strong) GDPlaceholderView *viewPlaceholder;

@property (nonatomic) BOOL login;

@end
