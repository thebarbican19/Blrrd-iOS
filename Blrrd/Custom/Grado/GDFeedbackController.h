//
//  LKFeedbackController.h
//  Lynker
//
//  Created by Joe Barbour on 01/09/2015.
//  Copyright (c) 2015 Lynker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GBDeviceInfo/GBDeviceInfo.h>
#import "BCredentialsObject.h"
#import "BNavigationView.h"
#import "GDPlaceholderView.h"
#import "UITextView+Placeholder.h"
#import "Mixpanel.h"

@interface GDFeedbackController : UIViewController <UITextViewDelegate, BNavigationDelegate, GDPlaceholderDelegate> {
    CGRect feedbackKeyboard;
    CGRect feedbackFrame;

}

@property (nonatomic, strong) BNavigationView *feedbackNavigation;
@property (nonatomic, strong) GDPlaceholderView *feedbackPlaceholder;
@property (nonatomic, strong) IBOutlet UITextView *feedbackEntry;

@property (nonatomic, strong) BCredentialsObject *credentials;

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary *userdata;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) GBDeviceInfo *device;

@end
