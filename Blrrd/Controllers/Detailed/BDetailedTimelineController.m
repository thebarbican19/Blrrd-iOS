//
//  BDetailedTimelineController.m
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BDetailedTimelineController.h"
#import "BConstants.h"

@interface BDetailedTimelineController ()

@end

@implementation BDetailedTimelineController

-(void)viewDidLayoutSubviews {
    [self.viewNavigation navigationTitle:[self.data objectForKey:@"name"]];

}

-(void)viewWillAppear:(BOOL)animated {
    
    
}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:true];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    
    self.viewNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.name = [self.data objectForKey:@"name"];
    self.viewNavigation.delegate = self;
    [self.view addSubview:self.viewNavigation];
    
    self.viewTimelineLayout = [[UICollectionViewFlowLayout alloc] init];
    self.viewTimelineLayout.minimumLineSpacing = 75.0;
    self.viewTimelineLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.viewTimelineLayout.sectionInset = UIEdgeInsetsMake(85.0, 15.0, 100.0, 15.0);
    
    self.viewTimeline = [[BTimelineSubview alloc] initWithCollectionViewLayout:self.viewTimelineLayout];
    self.viewTimeline.collectionView.frame = CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - APP_STATUSBAR_HEIGHT);
    self.viewTimeline.collectionView.backgroundColor = [UIColor clearColor];
    self.viewTimeline.delegate = self;
    self.viewTimeline.timeline = BQueryTimelineChannel;
    [self addChildViewController:self.viewTimeline];
    [self.view addSubview:self.viewTimeline.view];
    [self.view sendSubviewToBack:self.viewTimeline.view];

    [self.viewTimeline collectionViewLoadContent:nil append:false loading:true];

}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    [self.query queryChannelByIdentifyer:[self.data objectForKey:@"name"] page:self.viewTimeline.pagenation completion:^(NSArray *channel, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.viewTimeline collectionViewLoadContent:channel append:false loading:false];
            
        }];
        
    }];
    
}

-(void)viewUpdateTimeline:(BQueryTimeline)timeline {
    
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
