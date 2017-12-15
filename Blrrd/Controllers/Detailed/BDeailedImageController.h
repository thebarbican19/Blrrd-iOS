//
//  BDeailedImageController.h
//  Blrrd
//
//  Created by Joe Barbour on 04/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNavigationView.h"
#import "BTabbarView.h"
#import "BBlurredCell.h"
#import "GDActionSheet.h"

#import "BQueryObject.h"
#import "BUsageObject.h"
#import "BImageObject.h"
#import "BCredentialsObject.h"

@protocol BDetailedImageDelegate;
@interface BDeailedImageController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, BNavigationDelegate, BBlurredCellDelegate, BTabbarDelegate, BImageObjectDelegate, GDActionSheetDelegate>

@property (nonatomic, strong) id <BDetailedImageDelegate> delegate;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) BUsageObject *usage;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BImageObject *imageobj;

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSDictionary *selected;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSIndexPath *index;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic) float safearea;

@property (nonatomic, strong) UICollectionViewFlowLayout *viewTimelineLayout;
@property (nonatomic, strong) UICollectionView *viewTimeline;
@property (nonatomic, strong) UITableView *viewNotifications;
@property (nonatomic, strong) UIScrollView *viewScroll;
@property (nonatomic, strong) BNavigationView *viewNavigation;
@property (nonatomic, strong) BTabbarView *viewTabbar;
@property (nonatomic, strong) GDActionSheet *viewSheet;

@end

@protocol BDetailedImageDelegate <NSObject>

@optional

-(void)viewPresentSubviewWithIndex:(int)index animated:(BOOL)animated;

@end
