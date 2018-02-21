//
//  BTimelineSubview.h
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ShotBlocker/ShotBlocker.h>

#import "BBlurredCell.h"
#import "BCredentialsObject.h"
#import "BQueryObject.h"
#import "BImageObject.h"
#import "BFooterView.h"
#import "GDPlaceholderView.h"
#import "GDActionSheet.h"
#import "AppDelegate.h"

@protocol BTimelineDelegate;
@interface BTimelineSubview : UICollectionViewController <BBlurredCellDelegate, GDPlaceholderDelegate, GDActionSheetDelegate>

@property (nonatomic, strong) id <BTimelineDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) BBlurredCell *activecell;
@property (nonatomic, assign) BQueryTimeline timeline;
@property (nonatomic, assign) BOOL updating;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL scrollend;
@property (nonatomic, assign) float scrollheight;
@property (nonatomic, assign) float scrollposition;
@property (nonatomic, assign) float pagenation;
@property (nonatomic, assign) float pages;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BImageObject *imageobj;

@property (nonatomic, strong) GDPlaceholderView *placeholder;
@property (nonatomic, strong) BFooterView *footer;
@property (nonatomic, strong) GDActionSheet *actionsheet;
@property (nonatomic, strong) AppDelegate *appdel;

-(void)collectionViewLoadContent:(NSArray *)content append:(BOOL)append loading:(BOOL)loading error:(NSError *)error;

@end

@protocol BTimelineDelegate <NSObject>

@optional

-(void)viewContentRefresh:(UIRefreshControl *)refresh;
-(void)viewUpdateTimeline:(BQueryTimeline)timeline;
-(void)viewScrolled:(float)position;
-(void)viewReportImage:(NSDictionary *)image;
-(void)viewPresentFriendProfile:(NSMutableDictionary *)data;

@end
