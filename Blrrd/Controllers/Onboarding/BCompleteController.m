//
//  BCompleteController.m
//  Blrrd
//
//  Created by Joe Barbour on 14/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BCompleteController.h"
#import "BConstants.h"

@interface BCompleteController ()

@end

@implementation BCompleteController

-(void)viewDidAppear:(BOOL)animated {
    [self.mixpanel timeEvent:@"App Completed Onboarding with Content"];
    [self.viewLoader startAnimation];
    [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
        [self.query queryTimeline:BQueryTimelineTrending page:0 completion:^(NSArray *posts, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewLoader stopAnimation];
                [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.viewInstructions setAlpha:0.0];
                    [self.viewInstructions setTransform:CGAffineTransformMakeScale(0.9, 0.9)];

                } completion:^(BOOL finished) {
                    if (self.login) {
                        [self.viewInstructions setText:NSLocalizedString(@"Onboarding_SetupLoginComplete_Text", nil)];
                        
                    }
                    else {
                        [self.viewInstructions setText:NSLocalizedString(@"Onboarding_SetupComplete_Text", nil)];
                        
                    }
                    
                    [self.viewIcon setImage:[UIImage imageNamed:@"onboarding_complete_icon"]];

                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        [self.viewInstructions setAlpha:1.0];
                        [self.viewInstructions setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                        [self.viewAction setFrame:CGRectMake(35.0, self.view.bounds.size.height - 95.0, self.view.bounds.size.width - 70.0, 50.0)];

                    } completion:nil];

                }];
                
            }];
            
        }];
        
    }];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0x140F26);
    self.view.clipsToBounds = true;
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.query = [[BQueryObject alloc] init];
    
    self.viewIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 2) - 90.0, 70.0, 180.0, 180.0)];
    self.viewIcon.contentMode = UIViewContentModeCenter;
    self.viewIcon.image = [UIImage imageNamed:@"onboarding_loading_icon"];
    [self.view addSubview:self.viewIcon];
    
    self.viewInstructions = [[SAMLabel alloc] initWithFrame:CGRectMake(30.0, 270.0, self.view.bounds.size.width - 60.0, 80.0)];
    self.viewInstructions.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
    self.viewInstructions.backgroundColor = [UIColor clearColor];
    self.viewInstructions.font = [UIFont fontWithName:@"Nunito-SemiBold" size:16];
    self.viewInstructions.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.viewInstructions.textAlignment = NSTextAlignmentCenter;
    self.viewInstructions.numberOfLines = 5;
    self.viewInstructions.text = NSLocalizedString(@"Onboarding_SetupLoading_Text", nil);
    [self.view addSubview:self.viewInstructions];
    
    self.viewLoader = [[BLMultiColorLoader alloc] initWithFrame:CGRectMake(60.0, 60.0, self.viewIcon.bounds.size.width - 120.0, self.viewIcon.bounds.size.height - 120.0)];
    self.viewLoader.backgroundColor = [UIColor clearColor];
    self.viewLoader.lineWidth = 4.8;
    self.viewLoader.colorArray = @[UIColorFromRGB(0x140F26)];
    self.viewLoader.userInteractionEnabled = false;
    [self.viewIcon addSubview:self.viewLoader];
    
    self.viewAction = [[UIButton alloc] initWithFrame:CGRectMake(35.0, self.view.bounds.size.height, self.view.bounds.size.width - 70.0, 50.0)];
    [self.viewAction.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:12]];
    [self.viewAction setTitleColor:UIColorFromRGB(0x140F26) forState:UIControlStateNormal];
    [self.viewAction setBackgroundColor:UIColorFromRGB(0x69DCCB)];
    [self.viewAction setTitle:NSLocalizedString(@"Onboarding_ActionComplete_Text", nil).uppercaseString forState:UIControlStateNormal];
    [self.viewAction.layer setCornerRadius:5.0];
    [self.viewAction setTag:1];
    [self.viewAction addTarget:self action:@selector(viewComplete) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.viewAction];

}

-(void)viewComplete {
    [self.mixpanel track:@"App Completed Onboarding with Content"];
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
    
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
