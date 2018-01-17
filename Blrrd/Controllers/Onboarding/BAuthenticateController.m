//
//  BAuthenticateController.m
//  Blrrd
//
//  Created by Joe Barbour on 14/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BAuthenticateController.h"
#import "BConstants.h"
#import "BDocumentController.h"
#import "BNotificationsController.h"
#import "BCompleteController.h"
#import "BFriendFinderController.h"

@interface BAuthenticateController ()

@end

@implementation BAuthenticateController

-(void)viewDidAppear:(BOOL)animated {
    if (self.login) {
        [self.formNavigation navigationRightButton:nil];
        [self.formNavigation navigationTitle:NSLocalizedString(@"Authentication_LoginButton_Title", nil)];
        [self.mixpanel track:@"App Login Form Viewed"];
         
    }
    else {
        [self.formNavigation navigationRightButton:NSLocalizedString(@"Onboarding_ActionTerms_Text", nil)];
        [self.formNavigation navigationTitle:NSLocalizedString(@"Authentication_SignupButton_Title", nil)];
        [self.mixpanel track:@"App Signup Form Viewed"];
        
    }
    
}
 
-(void)viewNavigationButtonTapped:(UIButton *)button {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (button.tag == 0) {
            if (self.page == 0) {
                [self.view endEditing:true];
                [self.navigationController popViewControllerAnimated:true];
                
            }
            else {
                self.page --;
                
                [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    if (self.page < self.forms.count) {
                        [self.formScroll setContentOffset:CGPointMake(self.view.bounds.size.width * self.page, 0.0)];
                        [[self formWithTag:self.page] textFeildBecomeFirstResponder:self.credentials];
                        
                    }
                    
                } completion:nil];
                
            }
            
        }
        else {
            if (self.login) {
                
            }
            else {
                if ([self.formNavigation.rightbutton isEqualToString:NSLocalizedString(@"Onboarding_ActionTerms_Text", nil)]) {
                    BDocumentController *viewDocument = [[BDocumentController alloc] init];
                    viewDocument.header = NSLocalizedString(@"Settings_ItemTerms_Title", nil);
                    viewDocument.file = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"pdf"];
                    
                    [self.navigationController pushViewController:viewDocument animated:true];
                    [self.mixpanel track:@"App Terms & Conditions Viewed"];
                    
                }
                else if ([self.formNavigation.rightbutton isEqualToString:NSLocalizedString(@"Onboarding_ActionLoginShort_Text", nil)]) {
                    BAuthenticateController *viewAuthentication = [[BAuthenticateController alloc] init];
                    viewAuthentication.login = true;
                    
                    [self.navigationController pushViewController:viewAuthentication animated:true];
                    
                }

            }
            
        }
        
    }];
    
}
 
-(void)viewDidLoad {
    [super viewDidLoad];

    self.appdel = (AppDelegate*) [[UIApplication sharedApplication] delegate];

    self.mixpanel = [Mixpanel sharedInstance];
    
    self.user = [[BCredentialsObject alloc] init];
    
    self.query = [[BQueryObject alloc] init];
    
    self.view.backgroundColor = UIColorFromRGB(0x140F26);
    self.view.clipsToBounds = true;
    
    self.formNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.formNavigation.backgroundColor = [UIColor clearColor];
    self.formNavigation.name = nil;
    self.formNavigation.delegate = self;
    self.formNavigation.rightbutton = NSLocalizedString(@"Onboarding_ActionTerms_Text", nil);
    [self.view addSubview:self.formNavigation];
    
    self.formScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + 70.0, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + 70.0))];
    self.formScroll.pagingEnabled = true;
    self.formScroll.scrollEnabled = false;
    self.formScroll.clipsToBounds = true;
    self.formScroll.delegate = self;
    self.formScroll.backgroundColor = [UIColor clearColor];
    self.formScroll.contentSize = CGSizeMake(self.view.bounds.size.width * self.forms.count, self.view.bounds.size.height);
    [self.view addSubview:self.formScroll];

    self.formAction = [[UIButton alloc] initWithFrame:CGRectMake(35.0, self.view.bounds.size.height - 95.0, self.view.bounds.size.width - 70.0, 50.0)];
    [self.formAction.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:12]];
    [self.formAction setTitleColor:UIColorFromRGB(0x140F26) forState:UIControlStateNormal];
    [self.formAction setBackgroundColor:UIColorFromRGB(0x69DCCB)];
    [self.formAction setTitle:NSLocalizedString(@"Onboarding_ActionSignup_Text", nil).uppercaseString forState:UIControlStateNormal];
    [self.formAction.layer setCornerRadius:5.0];
    [self.formAction setTag:0];
    [self.formAction addTarget:self action:@selector(formAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.formAction];
    
    [self viewSetup];
    
}

-(void)viewSetup {
    self.forms = [[NSMutableArray alloc] init];
    self.page = 0;
    self.credentials = [[NSMutableDictionary alloc] init];
    if (!self.login) {
        [self.forms addObject:@{@"title":NSLocalizedString(@"Authentication_FormEmail_Title", nil),
                                @"key":@"email",
                                @"placeholder":NSLocalizedString(@"AuthenticateSignupEmailPlaceholder", nil),
                                @"value":@""}];
        
        [self.forms addObject:@{@"title":NSLocalizedString(@"Authentication_FormUsername_Title", nil),
                                @"key":@"username",
                                @"placeholder":NSLocalizedString(@"AuthenticateSignupUsernamePlaceholder", nil),
                                @"value":@""}];
        
        [self.forms addObject:@{@"title":NSLocalizedString(@"Authentication_FormPassword_Title", nil),
                                @"key":@"password",
                                @"placeholder":NSLocalizedString(@"AuthenticateSignupPasswordPlaceholder", nil),
                                @"value":@""}];
        
        [self.forms addObject:@{@"title":NSLocalizedString(@"Authentication_FormRePassword_Title", nil),
                                @"key":@"repassword",
                                @"placeholder":NSLocalizedString(@"AuthenticateSignupPasswordPlaceholder", nil),
                                @"value":@""}];
        
        
        
    }
    else {
        [self.forms addObject:@{@"title":NSLocalizedString(@"Authentication_FormEmail_Title", nil),
                                @"key":@"email",
                                @"placeholder":NSLocalizedString(@"AuthenticateSignupEmailPlaceholder", nil),
                                @"value":@""}];
        
        [self.forms addObject:@{@"title":NSLocalizedString(@"Authentication_FormPassword_Title", nil),
                                @"key":@"password",
                                @"placeholder":NSLocalizedString(@"AuthenticateLoginPasswordPlaceholder", nil),
                                @"value":@""}];
        
    }
    
    BOOL reset = false;
    for (UIView *subview in self.formScroll.subviews) {
        [subview removeFromSuperview];
        reset = true;
        
    }
    
    for (int i = 0;i < self.forms.count; i++) {
        NSDictionary *formItem = [self.forms objectAtIndex:i];
        
        GDFormInput *formInput = [[GDFormInput alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * i, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
        formInput.backgroundColor = [UIColor clearColor];
        if ([[formItem objectForKey:@"key"] isEqualToString:@"email"]) formInput.type = GDFormInputTypeEmail;
        else if ([[formItem objectForKey:@"key"] isEqualToString:@"username"]) formInput.type = GDFormInputTypeUsername;
        else if ([[formItem objectForKey:@"key"] isEqualToString:@"password"]) formInput.type = GDFormInputTypePassword;
        else if ( [[formItem objectForKey:@"key"] isEqualToString:@"repassword"]) formInput.type = GDFormInputTypePasswordReenter;
        else formInput.type = GDFormInputTypePasswordReenter;
        formInput.login = self.login;
        formInput.delegate = self;
        formInput.tag = i;
        [self.formScroll addSubview:formInput];
        
    }
    
    [self.formAction setTitle:NSLocalizedString(@"Authentication_NextAction_Title", nil).uppercaseString forState:UIControlStateNormal];
    [self.formScroll setContentSize:CGSizeMake(self.view.bounds.size.width * self.forms.count, self.view.bounds.size.height - 70.0)];
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.formScroll setContentOffset:CGPointMake(self.view.bounds.size.width * self.page, 0.0)];
        
    } completion:^(BOOL finished) {
        if (reset) [[self formWithTag:self.page] textFeildBecomeFirstResponder:self.credentials];
        
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[self formWithTag:0] textFeildBecomeFirstResponder:self.credentials];
        
    });
    
}

-(void)formPresentedKeyboard:(float)height {
    [self.formScroll setFrame:CGRectMake(0.0, 70.0, self.view.bounds.size.width, self.view.bounds.size.height - (height + 70.0))];
    [self.formScroll setContentSize:CGSizeMake(self.view.bounds.size.width * self.forms.count, self.formScroll.bounds.size.height)];
    
    formActionFrame = self.formAction.frame;
    formActionFrame.origin.y = self.view.bounds.size.height - (42.0 + height + self.formAction.bounds.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.formAction setAlpha:1.0];
        [self.formAction setFrame:formActionFrame];
        [self.formAction setNeedsDisplay];
        
    } completion:nil];
    
}

-(void)formDismissedKeyboard {
    [self.formScroll setFrame:CGRectMake(0.0, 70.0, self.view.bounds.size.width, self.view.bounds.size.height - 70.0)];
    [self.formScroll setContentSize:CGSizeMake(self.view.bounds.size.width * self.forms.count, self.view.bounds.size.height - 70.0)];
    
    formActionFrame = self.formAction.frame;
    formActionFrame.origin.y = self.view.bounds.size.height - (42.0 + self.formAction.bounds.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.formAction setAlpha:1.0];
        [self.formAction setFrame:formActionFrame];
        [self.formAction setNeedsDisplay];
        
    } completion:nil];
    
}

-(void)formKeyboardReturnPressed {
    [self formAction:self.formAction];
    
}

-(void)formAction:(UIButton *)button {
    GDFormInput *selected = [self formWithTag:self.page];
    if (button.tag == 1) {
        [self setLogin:true];
        [self viewSetup];
        
    }
    else if (button.tag == 2) {
        [self setLogin:false];
        [self viewSetup];
        
    }
    else {
        if (selected.validated) {
            if (self.page != self.forms.count) self.page ++;
            
            NSString *type;
            if (selected.type == GDFormInputTypeEmail) type = @"email";
            else if (selected.type == GDFormInputTypeUsername) type = @"username";
            else if (selected.type == GDFormInputTypePassword) type = @"password";
            
            if (type.length > 0 && selected.entry != nil) [self.credentials setObject:selected.entry forKey:type];
            
            NSLog(@"credentials %@" ,self.credentials);
            
        }
        else {
            [selected textFeildBecomeFirstResponder:self.credentials];
            [selected textFeildValidateCheck];
            
        }
        
        if ((self.page + 1) == self.forms.count) {
            [self.formAction setTitle:self.login?NSLocalizedString(@"Authentication_LoginAction_Title", nil).uppercaseString:NSLocalizedString(@"Authentication_SignupAction_Title", nil).uppercaseString forState:UIControlStateNormal];
            
        }
        
        GDFormInput *selected = [self formWithTag:self.page];
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.page < self.forms.count) {
                [self.formScroll setContentOffset:CGPointMake(self.view.bounds.size.width * self.page, 0.0)];
                [selected textFeildBecomeFirstResponder:self.credentials];
                
            }
            
        } completion:^(BOOL finished) {
            if (self.page == self.forms.count) {
                [selected textFeildSetTitle:NSLocalizedString(@"Authenticate_Loading_Title", nil)];
                [self.formAction setEnabled:false];
                if (self.login) {
                    [self.mixpanel track:@"App Login Complete"];
                    [self.query authenticationLoginWithCredentials:self.credentials completion:^(NSDictionary *user, NSError *error) {
                        [self formHandleContent:error];

                    }];
                    
                }
                else {
                    [self.mixpanel track:@"App Signup Complete"];
                    [self.query authenticationSignupWithCredentials:self.credentials completion:^(NSDictionary *user, NSError *error) {
                        [self formHandleContent:error];
                        
                    }];
                    
                }
                
            }
            
        }];
        
    }
    
}

-(void)formHandleContent:(NSError *)error {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        GDFormInput *last = [self formWithTag:(int)self.forms.count - 1];

        if (error.code == 200) {
            [self.appdel applicationNotificationsAuthorized:^(UNAuthorizationStatus authorized) {
                if (authorized == UNAuthorizationStatusNotDetermined) {
                    BNotificationsController *viewNotifications = [[BNotificationsController alloc] init];
                    viewNotifications.login = self.login;
                    
                    [self.navigationController pushViewController:viewNotifications animated:true];
                    
                }
                else {
                    if (self.login) {
                        BCompleteController *viewComplete = [[BCompleteController alloc] init];
                        viewComplete.login = self.login;
                        
                        [self.navigationController pushViewController:viewComplete animated:true];
                       
                        
                    }
                    else {
                        BFriendFinderController *viewFriends = [[BFriendFinderController alloc] init];
                        viewFriends.signup = true;
                        
                        [self.navigationController pushViewController:viewFriends animated:true];
                        
                    }
                    
                    if (authorized == UNAuthorizationStatusAuthorized) {
                        [self.appdel applicationAuthorizeRemoteNotifications:^(NSError *error, BOOL granted) {
                            
                        }];
                        
                    }
                    
                }
                
            }];
            
        }
        else {
            NSLog(@"Error: %@" ,error);
            if (error.code == 409 && !self.login) {
                [self.formNavigation navigationRightButton:NSLocalizedString(@"Onboarding_ActionLoginShort_Text", nil)];
                
            }

            self.page --;
            
            [last textFeildSetTitle:error.domain];
            [last.formInput setText:nil];
            
        }
        
        [self.formAction setEnabled:true];
        
    }];
    
}

-(GDFormInput *)formWithTag:(int)tag {
    for (UIView *view in self.formScroll.subviews) {
        if ([view isKindOfClass:[GDFormInput class]]) {
            if (view.tag == tag) return (GDFormInput *)[view viewWithTag:tag];
            
        }
        
    }
    return nil;
    
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
