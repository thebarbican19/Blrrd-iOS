//
//  BSettingsUserEditController.m
//  Blrrd
//
//  Created by Joe Barbour on 07/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import "BSettingsUserEditController.h"
#import "BConstants.h"

@interface BSettingsUserEditController ()

@end

@implementation BSettingsUserEditController

-(void)viewNavigationButtonTapped:(UIButton *)button {
    if (self.type == GDFormInputTypePasswordReenter) {
        [self setPassword:nil];
        [self setType:GDFormInputTypePassword];
        
        [self.viewInput setType:GDFormInputTypePassword];
        [self.viewInput textFeildSetTitle:NSLocalizedString(@"Authentication_FormPassword_Title", nil)];
        [self.viewInput.formInput setText:nil];
        
    }
    else {
        [self.navigationController popViewControllerAnimated:true];
        
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self.viewNavigation navigationTitle:self.header];
    [self.viewInput setEntry:self.value];
    
}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    [self viewNavigationButtonTapped:nil];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.mixpanel = [Mixpanel sharedInstance];
    
    self.query = [[BQueryObject alloc] init];
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.view.clipsToBounds = true;
    self.navigationController.navigationBarHidden = true;
    self.navigationController.view.clipsToBounds = true;
    
    self.viewNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.name = nil;
    self.viewNavigation.delegate = self;
    [self.view addSubview:self.viewNavigation];
    
    self.viewInput = [[GDFormInput alloc] initWithFrame:CGRectMake(0.0, 50.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.viewInput.backgroundColor = [UIColor clearColor];
    self.viewInput.type = self.type;
    self.viewInput.entry = self.value;
    self.viewInput.delegate = self;
    self.viewInput.login = false;
    [self.view addSubview:self.viewInput];
    [self.view sendSubviewToBack:self.viewInput];

    self.viewPlaceholder = [[GDPlaceholderView alloc] initWithFrame:self.view.frame];
    self.viewPlaceholder.delegate = self;
    self.viewPlaceholder.backgroundColor = [UIColor clearColor];
    self.viewPlaceholder.textcolor = [UIColor whiteColor];
    self.viewPlaceholder.gesture = true;
    self.viewPlaceholder.delegate = self;
    self.viewPlaceholder.alpha = 0.0;
    [self.view addSubview:self.viewPlaceholder];
    [self.view sendSubviewToBack:self.viewPlaceholder];
    
    self.viewAction = [[UIButton alloc] initWithFrame:CGRectMake(35.0, self.view.bounds.size.height - 95.0, self.view.bounds.size.width - 70.0, 50.0)];
    [self.viewAction.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:12]];
    [self.viewAction setTitleColor:UIColorFromRGB(0x140F26) forState:UIControlStateNormal];
    [self.viewAction setBackgroundColor:UIColorFromRGB(0x69DCCB)];
    [self.viewAction setTitle:NSLocalizedString(@"Authentication_UpdateButton_Title", nil).uppercaseString forState:UIControlStateNormal];
    [self.viewAction.layer setCornerRadius:5.0];
    [self.viewAction setTag:0];
    [self.viewAction addTarget:self action:@selector(formAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.viewAction];

}

-(void)formPresentedKeyboard:(float)height {
    CGRect actionframe = self.viewAction.frame;
    actionframe.origin.y = self.view.bounds.size.height - (42.0 + height + self.viewAction.bounds.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewAction setAlpha:1.0];
        [self.viewAction setFrame:actionframe];
        [self.viewAction setNeedsDisplay];
        
    } completion:nil];
}

-(void)formDismissedKeyboard {
    CGRect actionframe = self.viewAction.frame;
    actionframe.origin.y = self.view.bounds.size.height - (42.0 + self.viewAction.bounds.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewAction setFrame:actionframe];
        [self.viewAction setNeedsDisplay];
        
    } completion:nil];
    
}

-(void)formKeyboardReturnPressed {
    [self formAction:self.viewAction];
    
}

-(void)formAction:(UIButton *)button {
    if (self.type == GDFormInputTypeEmail && [self.viewInput.entry isEqualToString:[self.credentials userEmail]]) {
        [self.viewInput setValidated:false];
        [self.viewInput textFeildSetTitle:NSLocalizedString(@"Authenticate_NoChanges_Error", nil)];
        [self.viewInput textFeildValidateCheck];

    }
    else if (self.type == GDFormInputTypePhone && [self.viewInput.entry isEqualToString:[self.credentials userPhone:false]]) {
        [self.viewInput setValidated:false];
        [self.viewInput textFeildSetTitle:NSLocalizedString(@"Authenticate_NoChanges_Error", nil)];
        [self.viewInput textFeildValidateCheck];

    }
    else if (self.type == GDFormInputTypeDisplay && [self.viewInput.entry isEqualToString:[self.credentials userFullname]]) {
        [self.viewInput setValidated:false];
        [self.viewInput textFeildSetTitle:NSLocalizedString(@"Authenticate_NoChanges_Error", nil)];
        [self.viewInput textFeildValidateCheck];
        
    }
    else if (self.type == GDFormInputTypePasswordReenter && ![self.viewInput.entry isEqualToString:self.password]) {
        [self.viewInput setValidated:false];
        [self.viewInput textFeildSetTitle:NSLocalizedString(@"Authenticate_RePasswordUnmatched_Error", nil)];
        [self.viewInput textFeildValidateCheck];
        
    }
    else {
        if (self.viewInput.validated) {
            NSString *type;
            if (self.type == GDFormInputTypeEmail) type = @"email";
            else if (self.type == GDFormInputTypePhone) type = @"phone";
            else if (self.type == GDFormInputTypePassword) type = @"password";
            else if (self.type == GDFormInputTypePasswordReenter) type = @"password";
            else if (self.type == GDFormInputTypeDisplay) type = @"fullname";

            if (self.type == GDFormInputTypePassword) {
                [self setPassword:self.viewInput.entry];
                [self setType:GDFormInputTypePasswordReenter];
                
                [self.viewInput setType:GDFormInputTypePasswordReenter];
                [self.viewInput textFeildSetTitle:NSLocalizedString(@"Authentication_FormRePassword_Title", nil)];
                [self.viewInput textFeildBecomeFirstResponder:@{@"password":self.password}];
                [self.viewInput.formInput setText:nil];

            }
            else {
                [self.viewInput textFeildSetTitle:NSLocalizedString(@"Authenticate_Updating_Error", nil)];
                [self.query postUpdateUser:nil type:type value:self.viewInput.entry completion:^(NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if (error.code == 200) {
                            if (self.type == GDFormInputTypeEmail)
                                [self.credentials setUserEmail:self.viewInput.entry];
                            else if (self.type == GDFormInputTypePhone)
                                [self.credentials setUserPhoneNumber:self.viewInput.entry];
                            else if (self.type == GDFormInputTypeDisplay)
                                [self.credentials setUserFullname:self.viewInput.entry];

                            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                [self.viewAction setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
                                [self.viewAction setAlpha:0.0];
                                [self.viewInput setFrame:CGRectMake(0.0, 30.0, self.view.bounds.size.width, self.view.bounds.size.height)];
                                [self.viewInput setAlpha:0.0];
                                
                            } completion:^(BOOL finished) {
                                [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Authentication_ChangeOkayError_Title", nil) instructions:NSLocalizedString(@"Authentication_ChangeOkayError_Body", nil)];
                                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                    [self.viewPlaceholder setAlpha:1.0];
                                    
                                } completion:nil];
                                
                            }];
                            
                            [self.viewInput.formInput resignFirstResponder];
                            
                        }
                        else [self.viewInput textFeildSetTitle:error.domain];
                        
                    }];
                    
                }];
                
            }
            
        }
        else {
            [self.viewInput textFeildBecomeFirstResponder:@{}];
            [self.viewInput textFeildValidateCheck];
            
        }
        
    }
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
    
}

-(BOOL)prefersStatusBarHidden {
    return false;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    
}

@end
