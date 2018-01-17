//
//  BOnboardingController.m
//  Blrrd
//
//  Created by Joe Barbour on 05/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BOnboardingController.h"
#import "BConstants.h"
#import "BAuthenticateController.h"

@interface BOnboardingController ()

@end

@implementation BOnboardingController

-(void)viewWillDisappear:(BOOL)animated {
    [self.viewLogin setEnabled:true];
    [self.viewSignup setEnabled:true];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.viewLogo = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 2) - 90.0, 70.0, 180.0, 180.0)];
    self.viewLogo.contentMode = UIViewContentModeCenter;
    self.viewLogo.image = [UIImage imageNamed:@"splash_logo"];
    [self.view addSubview:self.viewLogo];
    
    self.viewTagline = [[SAMLabel alloc] initWithFrame:CGRectMake(30.0, 270.0, self.view.bounds.size.width - 60.0, 80.0)];
    self.viewTagline.backgroundColor = [UIColor clearColor];
    self.viewTagline.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
    self.viewTagline.font = [UIFont fontWithName:@"Nunito-SemiBold" size:16];
    self.viewTagline.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.viewTagline.textAlignment = NSTextAlignmentCenter;
    self.viewTagline.text = NSLocalizedString(@"Onboarding_Tagling_Text", nil);
    [self.view addSubview:self.viewTagline];

    self.viewSignup = [[UIButton alloc] initWithFrame:CGRectMake(35.0, self.view.bounds.size.height - 115.0, self.view.bounds.size.width - 70.0, 50.0)];
    [self.viewSignup.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:12]];
    [self.viewSignup setTitleColor:UIColorFromRGB(0x140F26) forState:UIControlStateNormal];
    [self.viewSignup setBackgroundColor:UIColorFromRGB(0x69DCCB)];
    [self.viewSignup setTitle:NSLocalizedString(@"Onboarding_ActionSignup_Text", nil) forState:UIControlStateNormal];
    [self.viewSignup.layer setCornerRadius:5.0];
    [self.viewSignup setTag:1];
    [self.viewSignup addTarget:self action:@selector(viewPresentAuthentication:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.viewSignup];
    
    self.viewLogin = [[UIButton alloc] initWithFrame:CGRectMake(20.0, self.view.bounds.size.height - 60.0, self.view.bounds.size.width - 40.0, 50.0)];
    [self.viewLogin.titleLabel setFont:[UIFont fontWithName:@"Nunito-Bold" size:12]];
    [self.viewLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.viewLogin setBackgroundColor:[UIColor clearColor]];
    [self.viewLogin setTitle:NSLocalizedString(@"Onboarding_ActionLogin_Text", nil) forState:UIControlStateNormal];
    [self.viewLogin.layer setCornerRadius:5.0];
    [self.viewLogin setTag:2];
    [self.viewLogin addTarget:self action:@selector(viewPresentAuthentication:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.viewLogin];

}

-(void)viewPresentAuthentication:(UIButton *)button {
    BAuthenticateController *viewAuthentication = [[BAuthenticateController alloc] init];
    viewAuthentication.login = button.tag==2?true:false;
    viewAuthentication.view.backgroundColor = UIColorFromRGB(0x140F26);
    
    [self.viewLogin setEnabled:false];
    [self.viewSignup setEnabled:false];
    [self.navigationController pushViewController:viewAuthentication animated:true];
    
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
