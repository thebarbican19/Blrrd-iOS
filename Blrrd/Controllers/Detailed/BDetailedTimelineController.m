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

-(void)viewDidAppear:(BOOL)animated {
    [self.viewNavigation navigationTitle:[self.data objectForKey:@"name"]];

}

-(void)viewWillAppear:(BOOL)animated {
    [self viewContentRefresh:nil];
    
}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:true];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    self.query.debug = true;
    
    self.usage = [[BUsageObject alloc] init];
    self.usage.delegate = self;
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.view.clipsToBounds = true;
    
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

    [self.viewTimeline collectionViewLoadContent:nil append:false loading:true error:nil];

}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    if (self.type == BDetailedViewTypeChannel) {
        [self.query queryChannelByIdentifyer:[self.data objectForKey:@"name"] page:self.viewTimeline.pagenation completion:^(NSArray *channel, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewTimeline collectionViewLoadContent:channel append:self.viewTimeline.pagenation==0?false:true loading:false error:error];
                
            }];
            
        }];
        
    }
    else {
        [self.query queryUserPosts:self.viewTimeline.pagenation completion:^(NSArray *items, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewTimeline collectionViewLoadContent:items append:self.viewTimeline.pagenation==0?false:true loading:false error:error];
                
            }];
            
        }];
        
    }
    
}

-(void)viewUpdateTimeline:(BQueryTimeline)timeline {
    [self.viewTimeline.footer present:true status:nil];
    if (self.type == BDetailedViewTypeChannel) {
        [self.query queryChannelByIdentifyer:[self.data objectForKey:@"name"] page:self.viewTimeline.pagenation completion:^(NSArray *channel, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [self.viewTimeline collectionViewLoadContent:channel append:self.viewTimeline.pagenation==0?false:true loading:false error:error];
                    if ((error == nil || error.code == 200) && channel.count == 0) {
                        [self.viewTimeline setScrollend:true];
                        [self.viewTimeline.footer present:false status:NSLocalizedString(@"Timeline_ScrollEnd_Title", nil)];

                    }
                    else {
                        [self.viewTimeline collectionViewLoadContent:channel append:self.viewTimeline.pagenation==0?false:true loading:false error:nil];
                        if (error.code != 200 && error != nil) {
                            [self.viewTimeline.footer present:false status:error.domain];
                            
                        }
                        
                    }
                    
                });
                
            }];
            
        }];
        
    }
    else {
        [self.query queryUserPosts:self.viewTimeline.pagenation completion:^(NSArray *items, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [self.viewTimeline collectionViewLoadContent:items append:self.viewTimeline.pagenation==0?false:true loading:false error:error];
                    if ((error == nil || error.code == 200) && items.count == 0) {
                        [self.viewTimeline setScrollend:true];
                        [self.viewTimeline.footer present:false status:NSLocalizedString(@"Timeline_ScrollEnd_Title", nil)];
                        
                    }
                    else {
                        [self.viewTimeline collectionViewLoadContent:items append:self.viewTimeline.pagenation==0?false:true loading:false error:nil];
                        if (error.code != 200 && error != nil) {
                            [self.viewTimeline.footer present:false status:error.domain];
                            
                        }
                        
                    }
                    
                });
                
            }];
            
        }];

    }
    
}

-(void)deviceInRestingState {
    for (BBlurredCell *view in self.viewTimeline.collectionView.visibleCells) {
        [view reveal:nil];
        
    }
    
}

-(void)deviceInActiveState {
    
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
