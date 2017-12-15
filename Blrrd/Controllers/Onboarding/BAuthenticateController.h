//
//  BAuthenticateController.h
//  Blrrd
//
//  Created by Joe Barbour on 14/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCredentialsObject.h"
#import "BQueryObject.h"
#import "BNavigationView.h"

#import "GDFormInput.h"
#import "AppDelegate.h"

@interface BAuthenticateController : UIViewController <UIScrollViewDelegate, BNavigationDelegate, GDFormInputDelegate> {
    CGRect formActionFrame;
    CGRect formKeyboard;
    
}

@property (strong, nonatomic) Mixpanel *mixpanel;
@property (strong, nonatomic) BCredentialsObject *user;
@property (strong, nonatomic) BQueryObject *query;
@property (nonatomic, strong) AppDelegate *appdel;

@property (nonatomic) BOOL resetmode;
@property (nonatomic) BOOL login;
@property (nonatomic) int page;
@property (nonatomic, strong) NSMutableArray *forms;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSMutableDictionary *credentials;

@property (nonatomic, strong) UIScrollView *formScroll;
@property (nonatomic, strong) BNavigationView *formNavigation;
@property (nonatomic, strong) UIButton *formAction;

@end
