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
    [self.viewNavigation navigationTitle:[self.data objectForKey:@"username"]];
    [self.viewHeader setup:self.data];

}

-(void)viewWillAppear:(BOOL)animated {
    if (self.type == BDetailedViewTypeUserProfile) {
        [self.viewNavigation setHidden:true];
        [self.viewHeader setHidden:false];
        
    }
    else {
        [self.viewNavigation setHidden:false];
        [self.viewHeader setHidden:true];

    }

    [self viewContentRefresh:nil];
    
}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    if (button.tag == 1) {
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        [buttons addObject:@{@"key":@"block", @"title":NSLocalizedString(@"Friend_BlockUser_Action", nil)}];
        if (self.credentials.userAdmin) {
            [buttons addObject:@{@"key":@"verify", @"title":NSLocalizedString(@"Friend_VerifyUser_Action", nil)}];

        }
        
        if ([self.query friendCheck:[self.data objectForKey:@"userid"]]) {
            [buttons addObject:@{@"key":@"follow", @"title":NSLocalizedString(@"Friend_ActionUnfollow_Text", nil)}];
            
        }
        else {
            [buttons addObject:@{@"key":@"follow", @"title":NSLocalizedString(@"Friend_ActionFollow_Text", nil)}];

        }
        
        [self.viewSheet setKey:@"options"];
        [self.viewSheet setButtons:buttons];
        [self.viewSheet presentActionAlert];
        
    }
    else {
        [self.navigationController popViewControllerAnimated:true];

    }
    
}

-(void)viewPresentSubviewWithIndex:(int)index animated:(BOOL)animated {
    [self.delegate viewPresentSubviewWithIndex:index animated:animated];
    [self.navigationController popToRootViewControllerAnimated:false];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    self.query.debug = true;
    
    self.usage = [[BUsageObject alloc] init];
    self.usage.delegate = self;
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.view.clipsToBounds = true;
    
    if (IS_IPHONE_X) {
        self.safearea = [UIApplication sharedApplication].keyWindow.window.safeAreaInsets.bottom + APP_STATUSBAR_HEIGHT;
        
    }

    self.viewNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.name = [self.data objectForKey:@"name"];
    self.viewNavigation.delegate = self;
    self.viewNavigation.hidden = true;
    [self.view addSubview:self.viewNavigation];
    
    self.viewHeader = [[BUserProfileHeader alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewHeader.backgroundColor = [UIColor clearColor];
    self.viewHeader.data = self.data;
    self.viewHeader.delegate = self;
    self.viewHeader.hidden = true;
    [self.view addSubview:self.viewHeader];
        
    self.viewTimelineLayout = [[UICollectionViewFlowLayout alloc] init];
    self.viewTimelineLayout.minimumLineSpacing = 75.0;
    self.viewTimelineLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.viewTimelineLayout.sectionInset = UIEdgeInsetsMake(85.0, 15.0, 100.0, 15.0);
    
    self.viewTimeline = [[BTimelineSubview alloc] initWithCollectionViewLayout:self.viewTimelineLayout];
    self.viewTimeline.collectionView.frame = CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - (MAIN_TABBAR_HEIGHT + APP_STATUSBAR_HEIGHT + self.safearea));
    self.viewTimeline.collectionView.backgroundColor = [UIColor clearColor];
    self.viewTimeline.delegate = self;
    self.viewTimeline.timeline = BQueryTimelineChannel;
    [self addChildViewController:self.viewTimeline];
    [self.view addSubview:self.viewTimeline.view];
    [self.view sendSubviewToBack:self.viewTimeline.view];
    
    self.viewSheet = [[GDActionSheet alloc] initWithFrame:super.view.bounds];
    self.viewSheet.viewColour = [UIColor whiteColor];
    self.viewSheet.delegate = self;
    self.viewSheet.cancelText = NSLocalizedString(@"Timeline_ActionDismissShare_Text", nil);
    self.viewSheet.cancelAction = false;
    self.viewSheet.presentAction = false;
    
    self.viewTabbar = [[BTabbarView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height - (self.safearea + MAIN_TABBAR_HEIGHT), self.view.bounds.size.width, self.safearea + MAIN_TABBAR_HEIGHT)];
    self.viewTabbar.buttons = @[@{@"image":@"tabbar_home", @"text":NSLocalizedString(@"Main_TabbarHome_Text", nil)} ,
                                @{@"image":@"tabbar_camera"},
                                @{@"image":@"tabbar_profile", @"text":NSLocalizedString(@"Main_TabbarProfile_Text", nil)}];
    self.viewTabbar.delegate = self;
    self.viewTabbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewTabbar];
    [self.viewTabbar viewUpdateWithTheme:BTabbarViewThemeDefault];

    [self.viewTimeline collectionViewLoadContent:nil append:false loading:true error:nil];

}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    [self.query queryUserPosts:[self.data objectForKey:@"userid"] page:self.viewTimeline.pagenation completion:^(NSArray *items, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.viewTimeline collectionViewLoadContent:items append:self.viewTimeline.pagenation==0?false:true loading:false error:error];
            
        }];
        
    }];
    
}

-(void)viewUpdateTimeline:(BQueryTimeline)timeline {
    [self.viewTimeline.footer present:true status:nil];
    [self.query queryUserPosts:[self.data objectForKey:@"userid"] page:self.viewTimeline.pagenation completion:^(NSArray *items, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self.viewTimeline collectionViewLoadContent:items append:self.viewTimeline.pagenation==0?false:true loading:false error:error];
                if ((error == nil || error.code == 200) && items.count == 0) {
                    [self.viewTimeline setScrollend:true];
                    [self.viewTimeline.footer present:false status:NSLocalizedString(@"Timeline_ScrollEnd_Title", nil)];

                }
                else {
                    if (error.code != 200 && error != nil) {
                        [self.viewTimeline.footer present:false status:error.domain];
                        
                    }
                    
                }
                
            });
            
        }];

    }];
    
}

-(void)deviceInRestingState {
    /*
    for (BBlurredCell *view in self.viewTimeline.collectionView.visibleCells) {
        [view reveal:nil];
        
    }
    */
    
}

-(void)actionSheetTappedButton:(GDActionSheet *)action index:(NSInteger)index {
    if ([action.key isEqualToString:@"options"]) {
        if ([[[action.buttons objectAtIndex:index] objectForKey:@"key"] isEqualToString:@"report"]) {
            
        }
        else if ([[[action.buttons objectAtIndex:index] objectForKey:@"key"] isEqualToString:@"block"]) {
            [self.query postBlock:[self.data objectForKey:@"userid"] completion:^(NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.navigationController popViewControllerAnimated:true];
                    
                }];

            }];
            
        }
        else if ([[[action.buttons objectAtIndex:index] objectForKey:@"key"] isEqualToString:@"verify"]) {
            [self.query postUpdateUser:[self.data objectForKey:@"userid"] type:@"promote" value:@"yes" completion:^(NSError *error) {
                
                
            }];
            
        }
        else if ([[[action.buttons objectAtIndex:index] objectForKey:@"key"] isEqualToString:@"follow"]) {
            NSString *request;
            bool remove;
            if ([self.query friendCheck:[self.data objectForKey:@"userid"]]) {
                request = @"delete";
                remove = true;
            }
            else {
                request = @"add";
                remove = false;
                
            }
            
            [self.query postRequest:[self.data objectForKey:@"userid"] request:request completion:^(NSError *error) {
                NSLog(@"postRequest %@ error %@ user: %@" ,request ,error ,[self.data objectForKey:@"userid"]);
                if (error.code == 200) {
                    [self.query friendsListAppend:[self.data objectForKey:@"userid"] remove:remove];

                }
                
            }];
            
        }
        
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
