//
//  LaunchAuthorizationController.m
//  Teech
//
//  Created by Joe Barbour on 10/03/2017.
//  Copyright © 2017 Teech. All rights reserved.
//

#import "BNotificationsController.h"
#import "BConstants.h"
#import "BCompleteController.h"

@interface BNotificationsController ()

@end

@implementation BNotificationsController

-(void)viewDidAppear:(BOOL)animated {
    [self.mixpanel timeEvent:@"App Notifications Authorization Viewed"];

}

-(void)viewWillDisappear:(BOOL)animated {
    [self.mixpanel track:@"App Notifications Authorization Viewed"];

}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = true;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColorFromRGB(0x140F26);
    self.view.clipsToBounds = true;
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.appdel = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.mixpanel = [Mixpanel sharedInstance];
    
    self.query = [[BQueryObject alloc] init];
    
    self.viewIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 2) - 90.0, 70.0, 180.0, 180.0)];
    self.viewIcon.contentMode = UIViewContentModeCenter;
    self.viewIcon.image = [UIImage imageNamed:@"onboarding_push_icon"];
    [self.view addSubview:self.viewIcon];
    
    self.viewInstructions = [[SAMLabel alloc] initWithFrame:CGRectMake(30.0, 270.0, self.view.bounds.size.width - 60.0, 80.0)];
    self.viewInstructions.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
    self.viewInstructions.backgroundColor = [UIColor clearColor];
    self.viewInstructions.font = [UIFont fontWithName:@"Nunito-SemiBold" size:16];
    self.viewInstructions.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.viewInstructions.textAlignment = NSTextAlignmentCenter;
    self.viewInstructions.numberOfLines = 5;
    self.viewInstructions.text = NSLocalizedString(@"Onboarding_Authorization_Text", nil);
    [self.view addSubview:self.viewInstructions];
    
    self.viewAction = [[UIButton alloc] initWithFrame:CGRectMake(35.0, self.view.bounds.size.height - 95.0, self.view.bounds.size.width - 70.0, 50.0)];
    [self.viewAction.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:12]];
    [self.viewAction setTitleColor:UIColorFromRGB(0x140F26) forState:UIControlStateNormal];
    [self.viewAction setBackgroundColor:UIColorFromRGB(0x69DCCB)];
    [self.viewAction setTitle:NSLocalizedString(@"Onboarding_ActionAuthorizeNotifications_Text", nil).uppercaseString forState:UIControlStateNormal];
    [self.viewAction.layer setCornerRadius:5.0];
    [self.viewAction setTag:1];
    [self.viewAction addTarget:self action:@selector(viewAuthorize:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.viewAction];
    
}

-(void)viewAuthorize:(UIButton *)action {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.appdel applicationAuthorizeRemoteNotifications:^(NSError *error, BOOL granted) {
                    [self.mixpanel track:[NSString stringWithFormat:@"App Notifications %@Authorized" ,granted?@"":@"Not "]];
                    [self viewUpdateUser];
                    
                }];
                
            }];
            
        }
        else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined && action != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound|UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
                    [self.appdel applicationAuthorizeRemoteNotifications:^(NSError *error, BOOL granted) {
                        [self.mixpanel track:[NSString stringWithFormat:@"App Notifications %@Authorized" ,granted?@"":@"Not "]];
                        [self viewUpdateUser];

                    }];
                    
                }];
                
            }];
        }
        else if (settings.authorizationStatus == UNAuthorizationStatusDenied && action != nil) {
            [self.mixpanel track:@"App Notifications Not Authorized"];
            [self viewUpdateUser];

        }
        
    }];
  
}

-(void)viewUpdateUser {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.viewAction setTitle:NSLocalizedString(@"Onboarding_ActionUpdating_Text", nil).uppercaseString forState:UIControlStateNormal];
        [self.viewAction setEnabled:false];

        [self.query postUserUpdate:^(NSError *error) {
            BCompleteController *viewComplete = [[BCompleteController alloc] init];
            viewComplete.login = self.login;
            
            [self.navigationController pushViewController:viewComplete animated:true];
            [self.viewAction setEnabled:true];

        }];
        
    }];

}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
    
}

-(BOOL)prefersStatusBarHidden {
    return false;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    
}

@end
