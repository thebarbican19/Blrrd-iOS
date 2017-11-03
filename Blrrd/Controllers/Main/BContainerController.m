//
//  BContainerController.m
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BContainerController.h"
#import "BAuthController.h"
#import "BConstants.h"

@interface BContainerController ()

@end

@implementation BContainerController

-(void)viewCheckAuthenticaion {
    if (self.credentials.userKey == nil) {
        BAuthController *viewAuthenticate = [[BAuthController alloc] init];
        viewAuthenticate.view.backgroundColor = [UIColor blackColor];
    
        [self.navigationController presentViewController:viewAuthenticate animated:false completion:nil];
        
    }
    else [self viewSetup];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self viewCheckAuthenticaion];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    self.query.debug = APP_DEBUG_MODE;
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.statusbarstyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.credentials destoryAllCredentials];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
}

-(void)viewSetup {
    if (![self.view.subviews containsObject:self.viewTimeline.view]) {
        [self.query queryFriendsTimeline:0 completion:^(NSArray *posts, NSError *error) {
            self.viewTimelineLayout = [[UICollectionViewFlowLayout alloc] init];
            self.viewTimelineLayout.minimumLineSpacing = 35.0;
            self.viewTimelineLayout.sectionInset = UIEdgeInsetsMake(100.0, 15.0, 100.0, 15.0);
            self.viewTimelineLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
            
            self.viewTimeline = [[BTimelineSubview alloc] initWithCollectionViewLayout:self.viewTimelineLayout];
            self.viewTimeline.collectionView.frame = self.view.bounds;
            self.viewTimeline.collectionView.backgroundColor = [UIColor clearColor];
            self.viewTimeline.content = posts.mutableCopy;
            [self addChildViewController:self.viewTimeline];
            [self.view addSubview:self.viewTimeline.view];
            
        }];
        
    }

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
