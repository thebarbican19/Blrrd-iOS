//
//  BOnboardingController.h
//  Blrrd
//
//  Created by Joe Barbour on 05/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMLabel.h"

@interface BOnboardingController : UIViewController

@property (nonatomic, strong) UIImageView *viewLogo;
@property (nonatomic, strong) SAMLabel *viewTagline;
@property (nonatomic, strong) UIButton *viewSignup;
@property (nonatomic, strong) UIButton *viewLogin;

@end
