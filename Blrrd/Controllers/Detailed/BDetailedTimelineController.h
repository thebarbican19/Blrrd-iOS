//
//  BDetailedTimelineController.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTimelineSubview.h"
#import "BSectionHeader.h"
#import "BNavigationView.h"

@interface BDetailedTimelineController : UIViewController <BTimelineDelegate, BNavigationDelegate>

@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic, strong) UICollectionViewFlowLayout *viewTimelineLayout;
@property (nonatomic, strong) BTimelineSubview *viewTimeline;
@property (nonatomic, strong) BNavigationView *viewNavigation;

@end
