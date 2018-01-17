//
//  BDeailedImageController.m
//  Blrrd
//
//  Created by Joe Barbour on 04/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BDeailedImageController.h"
#import "BConstants.h"
#import "BNotificationCell.h"

#import "GDFeedbackController.h"

@interface BDeailedImageController ()

@end

@implementation BDeailedImageController

-(void)viewWillAppear:(BOOL)animated {
    self.notifications = [[NSMutableArray alloc] initWithArray:[self.query notificationsForSpecificImage:[self.selected objectForKey:@"postid"]]];
    self.page = [self.posts indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [[NSPredicate predicateWithFormat:@"postid == %@", [self.selected objectForKey:@"postid"]] evaluateWithObject:obj];
        
    }];
    
    if (self.page <= self.posts.count) {
        [self setIndex:[NSIndexPath indexPathForRow:self.page inSection:0]];
        [self.viewTimeline reloadData];
        [self.viewTimeline scrollToItemAtIndexPath:self.index atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:false];

    }
    else if (self.selected != nil) {
        [self.notifications addObject:self.selected];
        [self setIndex:[NSIndexPath indexPathForRow:self.notifications.count - 1 inSection:0]];
        [self.viewTimeline reloadData];
        [self.viewTimeline scrollToItemAtIndexPath:self.index atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:false];
    
    }
    
}

-(void)viewPresentSubviewWithIndex:(int)index animated:(BOOL)animated {
    [self.delegate viewPresentSubviewWithIndex:index animated:animated];
    [self.navigationController popToRootViewControllerAnimated:false];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self.viewNavigation navigationTitle:[self.selected objectForKey:@"caption"]];

}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    if (button.tag == 0) {
        [self.navigationController popViewControllerAnimated:true];
        
    }
    else if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"ImageDetailed_Report_Text", nil).uppercaseString]) {
        GDFeedbackController *viewFeedback = [[GDFeedbackController alloc] init];
        viewFeedback.type = @"report";
        viewFeedback.imagedata = self.selected;
        viewFeedback.placeholder = NSLocalizedString(@"ImageDetailed_ReportSend_Placeholder", nil);
        viewFeedback.header = NSLocalizedString(@"ImageDetailed_Report_Title", nil);
        
        [self.navigationController pushViewController:viewFeedback animated:true];
        
    }
    else if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"ImageDetailed_Delete_Text", nil).uppercaseString]) {
        [self.viewTimeline performBatchUpdates:^{
            [self.posts removeObjectAtIndex:self.page];
            [self.viewTimeline deleteItemsAtIndexPaths:@[self.index]];
            
        } completion:^(BOOL finished) {
            [self scrollViewDidEndDecelerating:self.viewTimeline];
            
        }];
        
    }
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IPHONE_X) {
        self.safearea = [UIApplication sharedApplication].keyWindow.window.safeAreaInsets.bottom + APP_STATUSBAR_HEIGHT;
        
    }
    
    self.imageobj = [BImageObject sharedInstance];

    self.credentials = [[BCredentialsObject alloc] init];
    
    self.query = [[BQueryObject alloc] init];
    self.query.debug = true;

    self.viewNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.name = [self.selected objectForKey:@"name"];
    self.viewNavigation.delegate = self;
    self.viewNavigation.rightbutton = nil;
    [self.view addSubview:self.viewNavigation];
    
    self.viewTimelineLayout = [[UICollectionViewFlowLayout alloc] init];
    self.viewTimelineLayout.minimumLineSpacing = 30.0;
    self.viewTimelineLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.viewTimelineLayout.sectionInset = UIEdgeInsetsMake(85.0, 15.0, 100.0, 15.0);
    
    self.viewScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - (MAIN_TABBAR_HEIGHT + APP_STATUSBAR_HEIGHT + self.safearea))];
    self.viewScroll.backgroundColor = [UIColor clearColor];
    self.viewScroll.scrollEnabled = true;
    self.viewScroll.delegate = self;
    [self.view addSubview:self.viewScroll];
    
    self.viewTabbar = [[BTabbarView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height - (self.safearea + MAIN_TABBAR_HEIGHT), self.view.bounds.size.width, self.safearea + MAIN_TABBAR_HEIGHT)];
    self.viewTabbar.buttons = @[@{@"image":@"tabbar_home", @"text":NSLocalizedString(@"Main_TabbarHome_Text", nil)} ,
                                @{@"image":@"tabbar_camera"},
                                @{@"image":@"tabbar_profile", @"text":NSLocalizedString(@"Main_TabbarProfile_Text", nil)}];
    self.viewTabbar.delegate = self;
    self.viewTabbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewTabbar];
    [self.viewTabbar viewUpdateWithTheme:BTabbarViewThemeDefault];
    
    self.viewTimeline = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, self.viewNavigation.bounds.size.height, self.view.bounds.size.width, (self.view.bounds.size.width + 40.0)) collectionViewLayout:self.viewTimelineLayout];
    self.viewTimeline.backgroundColor = [UIColor clearColor];
    self.viewTimeline.showsHorizontalScrollIndicator = false;
    self.viewTimeline.hidden = false;
    self.viewTimeline.delegate = self;
    self.viewTimeline.tag = 1;
    self.viewTimeline.pagingEnabled = true;
    self.viewTimeline.dataSource = self;
    [self.viewScroll addSubview:self.viewTimeline];
    [self.viewTimeline registerClass:[BBlurredCell class] forCellWithReuseIdentifier:@"item"];

    self.viewNotifications = [[UITableView alloc] initWithFrame:CGRectMake(12.0, self.viewNavigation.bounds.size.height + self.viewTimeline.bounds.size.height, self.view.bounds.size.width - 24.0, self.view.bounds.size.height - (self.viewNavigation.bounds.size.height + self.viewTimeline.bounds.size.height))];
    self.viewNotifications.backgroundColor = [UIColor clearColor];
    self.viewNotifications.delegate = self;
    self.viewNotifications.dataSource = self;
    self.viewNotifications.scrollEnabled = false;
    self.viewNotifications.separatorColor = [UIColor clearColor];
    self.viewNotifications.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 12.0)];
    [self.viewScroll addSubview:self.viewNotifications];
    [self.viewNotifications registerClass:[BNotificationCell class] forCellReuseIdentifier:@"notification"];

    self.viewSheet = [[GDActionSheet alloc] initWithFrame:super.view.bounds];
    self.viewSheet.viewColour = [UIColor whiteColor];
    self.viewSheet.delegate = self;
    self.viewSheet.cancelText = NSLocalizedString(@"Timeline_ActionDismissShare_Text", nil);
    self.viewSheet.cancelAction = false;
    self.viewSheet.presentAction = false;
    
    [self scrollViewDidEndDecelerating:self.viewTimeline];
    [self.view bringSubviewToFront:self.viewNavigation];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width - 30.0, self.view.bounds.size.width + 20.0);
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBlurredCell *cell = (BBlurredCell *)[self.viewTimeline dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    
    [cell setDelegate:self];
    [cell content:[self.posts objectAtIndex:indexPath.row] index:indexPath];
    
    [cell.contentView.layer setShadowColor:UIColorFromRGB(0x000000).CGColor];
    [cell.contentView.layer setShadowOffset:CGSizeMake(0.0, 2.0)];
    [cell.contentView.layer setShadowRadius:9.0];
    [cell.contentView.layer setCornerRadius:8.0];
    
    return cell;
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        CGRect tableframe = self.viewNotifications.frame;
        tableframe.origin.y += 20.0;
        
        [UIView animateWithDuration:0.15 delay:0.1 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.viewNotifications setAlpha:0.0];
            [self.viewNotifications setFrame:tableframe];
            
        } completion:nil];
        
    }
        
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.page = self.viewTimeline.contentOffset.x / self.viewTimeline.frame.size.width;
    self.index = [NSIndexPath indexPathForRow:self.page inSection:0];
    self.selected = [self.posts objectAtIndex:self.page];
    self.notifications = [[NSMutableArray alloc] initWithArray:[self.query notificationsForSpecificImage:[self.selected objectForKey:@"postid"]]];

    [self.viewNavigation navigationTitle:[self.selected objectForKey:@"caption"]];
    [self.viewNotifications reloadData];
    
    CGRect tableframe = self.viewNotifications.frame;
    tableframe.origin.y = self.viewTimeline.bounds.size.height + 60.0;
    tableframe.size.height = tableframe.origin.y + self.viewNotifications.contentSize.height + 20.0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.viewNotifications setAlpha:1.0];
        [self.viewNotifications setFrame:tableframe];
        [self.viewScroll setContentSize:CGSizeMake(0.0, self.viewNotifications.bounds.size.height)];
    
    } completion:nil];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (NSIndexPath *item in [self.viewTimeline indexPathsForVisibleItems]) {
        BBlurredCell *cell = (BBlurredCell *)[self.viewTimeline cellForItemAtIndexPath:item];
        [cell reveal:nil];
        
    }
    
}

-(void)collectionViewRevealed:(BBlurredCell *)revealed {
    for (BBlurredCell *cell in self.viewTimeline.visibleCells) {
        if (cell != revealed) [cell reveal:nil];
        
    }
    
}

-(void)collectionViewPresentOptions:(BBlurredCell *)item {
    NSDictionary *data = [self.posts objectAtIndex:item.indexpath.row];
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    if ([[data objectForKey:@"username"] isEqualToString:self.credentials.userHandle] || [self.credentials.userType isEqualToString:@"admin"]) {
        [buttons addObject:@{@"key":@"delete", @"title":NSLocalizedString(@"Timeline_ActionSheetDelete_Text", nil)}];
        
    }
    
    if (![[data objectForKey:@"username"] isEqualToString:self.credentials.userHandle]) {
        [buttons addObject:@{@"key":@"report", @"title":NSLocalizedString(@"Timeline_ActionSheetReport_Text", nil)}];
        
    }
    
    [self.viewSheet setIndexPath:item.indexpath];
    [self.viewSheet setKey:@"options"];
    [self.viewSheet setButtons:buttons];
    [self.viewSheet presentActionAlert];
    
}

-(void)actionSheetTappedButton:(GDActionSheet *)action index:(NSInteger)index {
    NSDictionary *data = [self.posts objectAtIndex:action.indexPath.row];
    if ([action.key isEqualToString:@"options"]) {
        if ([[[action.buttons objectAtIndex:index] objectForKey:@"key"] isEqualToString:@"delete"]) {
            [self.imageobj uploadRemove:data completion:^(NSError *error) {
                if (error.code == 200) {
                    [self.viewTimeline performBatchUpdates:^{
                        [self.posts removeObjectAtIndex:action.indexPath.row];
                        [self.viewTimeline deleteItemsAtIndexPaths:@[action.indexPath]];
                        
                    } completion:nil];
                    
                }
                                
            }];
            
        }
        else if ([[[action.buttons objectAtIndex:index] objectForKey:@"key"] isEqualToString:@"report"]) {
            GDFeedbackController *viewFeedback = [[GDFeedbackController alloc] init];
            viewFeedback.type = @"report";
            viewFeedback.imagedata = data;
            viewFeedback.placeholder = NSLocalizedString(@"ImageDetailed_ReportSend_Placeholder", nil);
            viewFeedback.header = NSLocalizedString(@"ImageDetailed_Report_Title", nil);
            
            [self.navigationController pushViewController:viewFeedback animated:true];
            
        }
        
    }
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.notifications.count == 0) return 1;
    else return self.notifications.count;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BNotificationCell *notification = (BNotificationCell *)cell;
    notification.status.frame = CGRectMake(19.0, 0.0, cell.contentView.bounds.size.width - (cell.contentView.bounds.size.height + 28.0) , cell.contentView.bounds.size.height - 12.0);
    notification.timestamp.frame = CGRectMake(19.0, cell.contentView.bounds.size.height - 18.0, cell.contentView.bounds.size.width - 16.0 ,8.0);
    notification.image.frame = CGRectMake(cell.contentView.bounds.size.width - (cell.contentView.bounds.size.height + 2.0), 3.0, cell.contentView.bounds.size.height - 6.0, cell.contentView.bounds.size.height - 6.0);
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BNotificationCell *cell = (BNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notification" forIndexPath:indexPath];
    
    if (self.notifications.count == 0) {
        [cell.status setText:NSLocalizedString(@"Profile_NotificationEmpty_Body", nil)];
        [cell.timestamp setHidden:true];
        
    }
    else {
        [cell content:[self.notifications objectAtIndex:indexPath.row] type:BNotificationCellTypeUser];
        [cell.timestamp setHidden:false];

    }
    [cell.image setHidden:true];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
    
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
