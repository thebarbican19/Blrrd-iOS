//
//  BAuthController.m
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BAuthController.h"
#import "BConstants.h"

@interface BAuthController ()

@end

@implementation BAuthController

-(void)viewDismiss {
    [self dismissViewControllerAnimated:true completion:nil];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(viewAuthenticate) withObject:nil afterDelay:3.0];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    self.query.debug = APP_DEBUG_MODE;
    
    self.credentials = [[BCredentialsObject alloc] init];

    self.statusbarstyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;

    self.status = [[UILabel alloc] initWithFrame:CGRectMake(30.0, (self.view.bounds.size.height / 2) - 80.0, self.view.bounds.size.width - 60.0, 160.0)];
    self.status.numberOfLines = 3;
    self.status.textAlignment = NSTextAlignmentCenter;
    self.status.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.status.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
    [self.view addSubview:self.status];
    
    [self setNeedsStatusBarAppearanceUpdate];

}

-(void)viewAuthenticate {
    [self.query authenticationLoginWithCredentials:@{@"username":@"emanuel.vila", @"password":@"Florian1"} completion:^(NSDictionary *user, NSError *error) {
        if (error.code == 200 && user) {
            [self.status setText:NSLocalizedString(@"Authentication_StatusSucsess_Text", nil)];
            [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
                if (error.code == 200) [self viewDismiss];
                else [self.status setText:error.domain];
                
            }];
            
        }
        else [self.status setText:error.domain];
        
    }];
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
    
}

-(BOOL)prefersStatusBarHidden {
    return self.statusbarhidden;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusbarstyle;
    
}

@end
