//
//  BTimelineSubview.h
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBlurredCell.h"
#import "BQueryObject.h"
#import "BFooterView.h"
#import "GDPlaceholderView.h"

@protocol BTimelineDelegate;
@interface BTimelineSubview : UICollectionViewController <BBlurredCellDelegate, GDPlaceholderDelegate>

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

@property (nonatomic, strong) GDPlaceholderView *placeholder;
@property (nonatomic, strong) BFooterView *footer;

-(void)collectionViewLoadContent:(NSArray *)content append:(BOOL)append loading:(BOOL)loading;

@end

@protocol BTimelineDelegate <NSObject>

@optional

-(void)viewContentRefresh:(UIRefreshControl *)refresh;
-(void)viewUpdateTimeline:(BQueryTimeline)timeline;

@end
