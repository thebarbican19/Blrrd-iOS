//
//  BContainerController.m
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BContainerController.h"
#import "BAuthController.h"
#import "BDetailedTimelineController.h"
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
    else {
        [self viewSetup];
        [self.appdel applicationHandleSockets:false];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self viewCheckAuthenticaion];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.queue = [[NSOperationQueue alloc] init];
    self.queue.qualityOfService = NSQualityOfServiceUtility;

    self.appdel = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    self.query = [[BQueryObject alloc] init];
    self.query.debug = APP_DEBUG_MODE;
    self.query.delegate = self;
    
    self.usage = [[BUsageObject alloc] init];
    self.usage.delegate = self;
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.statusbarstyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;
    
    //[self.credentials destoryAllCredentials];
    //if (APP_DEBUG_MODE) [self.query cacheDestroy];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
}

-(void)viewSetup {
    if (![self.view.subviews containsObject:self.viewContainer]) {
        self.viewContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + MAIN_TABBAR_HEIGHT))];
        self.viewContainer.backgroundColor = [UIColor clearColor];
        self.viewContainer.scrollEnabled = false;
        self.viewContainer.pagingEnabled = true;
        self.viewContainer.contentSize = CGSizeMake(self.view.bounds.size.width * 3, self.viewContainer.bounds.size.height);
        self.viewContainer.showsHorizontalScrollIndicator = false;
        [self.view addSubview:self.viewContainer];
        
        self.viewTimelineLayout = [[UICollectionViewFlowLayout alloc] init];
        self.viewTimelineLayout.minimumLineSpacing = 75.0;
        self.viewTimelineLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.viewTimelineLayout.sectionInset = UIEdgeInsetsMake(100.0, 15.0, 100.0, 15.0);

        self.viewTimeline = [[BTimelineSubview alloc] initWithCollectionViewLayout:self.viewTimelineLayout];
        self.viewTimeline.collectionView.frame = CGRectMake(self.viewContainer.bounds.size.width * 0, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height);
        self.viewTimeline.collectionView.backgroundColor = [UIColor clearColor];
        self.viewTimeline.delegate = self;
        self.viewTimeline.timeline = BQueryTimelineFriends;
        [self addChildViewController:self.viewTimeline];
        [self.viewContainer addSubview:self.viewTimeline.view];
        
        self.viewSegment = [[BSegmentControl alloc] initWithFrame:CGRectMake(self.view.center.x - 80.0, 28.0, 160.0, 50.0)];
        self.viewSegment.backgroundColor = [UIColorFromRGB(0x3B3B4D) colorWithAlphaComponent:0.2];
        self.viewSegment.delegate = self;
        self.viewSegment.buttons = @[@"timeline_segment_friends", @"timeline_segment_trending"].mutableCopy;
        self.viewSegment.type = BSegmentTypeBox;
        self.viewSegment.index = 0;
        self.viewSegment.selecedtextcolor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.viewSegment.textcolor = [UIColor colorWithWhite:1.0 alpha:0.5];
        self.viewSegment.layer.cornerRadius = self.viewSegment.bounds.size.height / 2;
        self.viewSegment.clipsToBounds = true;
        [self.viewTimelineLayout.collectionView addSubview:self.viewSegment];
        
        self.viewCanvas = [[BCanvasController alloc] init];
        self.viewCanvas.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 1, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height);
        self.viewCanvas.view.backgroundColor = [UIColor clearColor];
        [self addChildViewController:self.viewCanvas];
        [self.viewContainer addSubview:self.viewCanvas.view];
        
        self.viewDiscover = [[BDiscoverController alloc] init];
        self.viewDiscover.tableView.frame = CGRectMake(self.viewContainer.bounds.size.width * 2, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height);
        self.viewDiscover.tableView.backgroundColor = [UIColor clearColor];
        [self addChildViewController:self.viewDiscover];
        [self.viewContainer addSubview:self.viewDiscover.view];
        
        self.viewChannelsLayout = [[UICollectionViewFlowLayout alloc] init];
        self.viewChannelsLayout.minimumLineSpacing = 14.0;
        self.viewChannelsLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.viewChannelsLayout.sectionInset = UIEdgeInsetsMake(14.0, 14.0, 14.0, 14.0);
        
        self.viewChannels = [[BChannelController alloc] initWithCollectionViewLayout:self.viewChannelsLayout];
        self.viewChannels.collectionView.frame = CGRectMake(0.0, 0.0, self.viewContainer.bounds.size.width, 175.0);
        self.viewChannels.collectionView.backgroundColor = [UIColor clearColor];
        self.viewChannels.collectionView.showsHorizontalScrollIndicator = false;
        self.viewChannels.delegate = self;
        [self addChildViewController:self.viewChannels];
        [self.viewDiscover.tableView setTableHeaderView:self.viewChannels.collectionView];
        
        self.viewTabbar = [[BTabbarView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewContainer.bounds.size.height, self.viewContainer.bounds.size.width, MAIN_TABBAR_HEIGHT)];
        self.viewTabbar.buttons = @[@{@"image":@"tabbar_home", @"text":@"home"} ,
                                    @{@"image":@"tabbar_camera"},
                                    @{@"image":@"tabbar_discover", @"text":@"discovery"}];
        self.viewTabbar.delegate = self;
        self.viewTabbar.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.viewTabbar];
        
    }
    
    [self.viewTimeline collectionViewLoadContent:[self.query cacheRetrive:@"postsApi/getAllFriendsPostsNext"] append:false loading:true error:nil];

    if ([self.query cacheExpired:@"postsApi/getAllFriendsPostsNext"]) {
        [self.queue addOperationWithBlock:^{
            [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (self.timelineindex == 0) {
                        [self.viewTimeline collectionViewLoadContent:posts append:false loading:false error:error];
        
                    }
                    
                }];
                
            }];
            
        }];
            
    }

    if ([self.query cacheExpired:@"channelsApi/getChannelsHotPostsNext"]) {
        [self.queue addOperationWithBlock:^{
            [self.query queryTimeline:BQueryTimelineTrending page:0 completion:^(NSArray *posts, NSError *error) {
                if (self.timelineindex == 1) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.viewTimeline collectionViewLoadContent:posts append:false loading:false error:error];
                        
                    }];
                    
                }
            }];
            
        }];
        
    }
    
    if ([self.query cacheExpired:@"channelsApi/getChannels"]) {
        [self.queue addOperationWithBlock:^{
            [self.query queryChannels:^(NSArray *channels, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.viewChannels viewSetupContent:channels];
                    
                }];
                
            }];
            
        }];
        
    }
    else [self.viewChannels viewSetupContent:[self.query cacheRetrive:@"channelsApi/getChannels"]];
    
    if ([self.query cacheExpired:@"postsApi/getViewTimesNewApi"]) {
        [self.queue addOperationWithBlock:^{
            [self.query queryNotifications:^(NSArray *notifications, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.viewDiscover viewSetupNotification:notifications limit:6];
                    
                }];
                
            }];
            
        }];
        
    }
    else [self.viewDiscover viewSetupNotification:[self.query cacheRetrive:@"postsApi/getViewTimesNewApi"] limit:6];
    
    if ([self.query cacheExpired:@"friendsApi/getRequests"]) {
        [self.queue addOperationWithBlock:^{
            [self.query queryRequests:^(NSArray *requests, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.viewDiscover viewSetupRequests:requests limit:3];
                     
                }];
                
            }];
            
        }];
        
    }
    else [self.viewDiscover viewSetupRequests:[self.query cacheRetrive:@"friendsApi/getRequests"] limit:3];
    
    if ([self.query cacheExpired:@"userApi/getAllUsers/"]) {
        [self.queue addOperationWithBlock:^{
            [self.query querySuggestedUsers:^(NSArray *users, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.viewDiscover viewSetupSuggested:users limit:0];
                    
                }];
                
            }];
            
        }];
        
    }
    else [self.viewDiscover viewSetupSuggested:[self.query cacheRetrive:@"userApi/getAllUsers/"] limit:0];
    
}

-(void)viewSwitchTimeline:(int)index animated:(BOOL)animated {
    if (index == 0) [self.viewTimeline setTimeline:BQueryTimelineFriends];
    else [self.viewTimeline setTimeline:BQueryTimelineTrending];

    if (!animated) {
        if (index == 0) {
            [self.viewTimeline collectionViewLoadContent:[self.query cacheRetrive:@"postsApi/getAllFriendsPostsNext"] append:false loading:false error:nil];
            
        }
        else {
            [self.viewTimeline collectionViewLoadContent:[self.query cacheRetrive:@"channelsApi/getChannelsHotPostsNext"] append:false loading:nil error:nil];
            
        }
        
    }
    else {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewTimeline.collectionView setFrame:CGRectMake(0.0, 40.0, self.view.bounds.size.width, self.viewContainer.bounds.size.height)];
            [self.viewTimeline.collectionView setAlpha:0.0];

        } completion:^(BOOL finished) {
            if (index == 0) {
                [self.viewTimeline collectionViewLoadContent:[self.query cacheRetrive:@"postsApi/getAllFriendsPostsNext"] append:false loading:false error:nil];
                
            }
            else {
                [self.viewTimeline collectionViewLoadContent:[self.query cacheRetrive:@"channelsApi/getChannelsHotPostsNext"] append:false loading:false error:nil];
                
            }
            
            [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.viewTimeline.collectionView setFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.viewContainer.bounds.size.height)];
                [self.viewTimeline.collectionView setAlpha:1.0];
                
            } completion:nil];
            
        }];
        
    }
    
}

-(void)viewUpdateTimeline:(BQueryTimeline)timeline {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.viewTimeline.footer present:true status:nil];
        [self.query queryTimeline:timeline page:self.viewTimeline.pagenation completion:^(NSArray *posts, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    if ((error == nil || error.code == 200) && posts.count == 0) {
                        [self.viewTimeline setScrollend:true];
                        [self.viewTimeline.footer present:false status:@"that's all folks"];
                        
                    }
                    else {
                        [self.viewTimeline collectionViewLoadContent:posts append:self.viewTimeline.pagenation==0?false:true loading:false error:nil];
                        if (error.code != 200 && error != nil) {
                            [self.viewTimeline.footer present:false status:error.domain];
                            
                        }
                    
                    }
                    
                });
                
            }];

        }];
        
    }];

}

-(void)viewPresentSubviewWithIndex:(int)index animated:(BOOL)animated {
    if (index == 1) [self.viewCanvas viewInitiateCamera];
    [UIView animateWithDuration:animated?0.15:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewContainer setContentOffset:CGPointMake(self.view.bounds.size.width * index, 0.0)];
        
    } completion:^(BOOL finished) {
        if (index != 1) [self.viewCanvas viewTermiateCamera];
        
    }];
        
}

-(void)viewPresentChannel:(NSDictionary *)channel {
    BDetailedTimelineController *viewDetailed = [[BDetailedTimelineController alloc] init];
    viewDetailed.view.backgroundColor = self.view.backgroundColor;
    viewDetailed.data = channel;
    
    [self.navigationController pushViewController:viewDetailed animated:true];
    
}

-(void)segmentViewWasTapped:(BSegmentControl *)segment index:(NSUInteger)index {
    [self setTimelineindex:(int)index];
    [self viewSwitchTimeline:(int)index animated:true];
    
}

-(void)deviceInRestingState {
    for (BBlurredCell *cell in self.viewTimeline.collectionView.visibleCells) {
        [cell reveal:nil];

    }
    
    NSLog(@"deviceInRestingState");

}

-(void)deviceInActiveState {
    NSLog(@"deviceInActiveState");

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
