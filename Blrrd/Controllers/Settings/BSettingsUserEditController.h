//
//  BSettingsUserEditController.h
//  Blrrd
//
//  Created by Joe Barbour on 07/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>
#import <Mixpanel.h>
#import "BNavigationView.h"
#import "GDFormInput.h"
#import "GDPlaceholderView.h"

#import "BCredentialsObject.h"
#import "BQueryObject.h"

@interface BSettingsUserEditController : UIViewController <BNavigationDelegate, GDFormInputDelegate, GDPlaceholderDelegate>

@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic) GDFormInputType type;
@property (nonatomic) NSString *header;
@property (nonatomic) NSString *password;
@property (nonatomic, strong) NSString *value;
@property (nonatomic) BOOL friendfinder;
@property (nonatomic) BOOL signup;

@property (nonatomic, strong) BNavigationView *viewNavigation;
@property (nonatomic, strong) GDFormInput *viewInput;
@property (nonatomic, strong) GDPlaceholderView *viewPlaceholder;
@property (nonatomic, strong) UIButton *viewAction;

@end
