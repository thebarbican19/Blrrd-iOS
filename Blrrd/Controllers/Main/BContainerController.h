//
//  BContainerController.h
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "BQueryObject.h"
#import "BCredentialsObject.h"
#import "BTimelineSubview.h"
#import "BSegmentControl.h"
#import "BUsageObject.h"
#import "BDiscoverController.h"
#import "BChannelController.h"
#import "BCanvasController.h"
#import "BTabbarView.h"

@interface BContainerController : UIViewController <BSegmentDelegate, BQueryDelegate, BTimelineDelegate, BUsageDelegate, BDiscoverDelegate, BTabbarDelegate, BChannelDelegate>

@property (nonatomic, retain) AppDelegate *appdel;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) BUsageObject *usage;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic) int timelineindex;
@property (nonatomic) int viewindex;
@property (nonatomic) float scrollpos;
@property (nonatomic) NSOperationQueue *queue;

@property (nonatomic, strong) BTabbarView *viewTabbar;
@property (nonatomic, strong) UIScrollView *viewContainer;
@property (nonatomic, strong) BSegmentControl *viewSegment;
@property (nonatomic, strong) BTimelineSubview *viewTimeline;
@property (nonatomic, strong) BDiscoverController *viewDiscover;
@property (nonatomic, strong) BChannelController *viewChannels;
@property (nonatomic, strong) BCanvasController *viewCanvas;
@property (nonatomic, strong) UICollectionViewFlowLayout *viewTimelineLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *viewChannelsLayout;

@property (nonatomic) UIStatusBarStyle statusbarstyle;
@property (nonatomic) BOOL statusbarhidden;

@end
