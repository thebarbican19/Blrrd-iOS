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

#import "BUsageObject.h"
#import "BCredentialsObject.h"

typedef enum {
    BDetailedViewTypeChannel,
    BDetailedViewTypeProfile
    
} BDetailedViewType;

@interface BDetailedTimelineController : UIViewController <BTimelineDelegate, BNavigationDelegate, BUsageDelegate>

@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) BUsageObject *usage;
@property (nonatomic, strong) BCredentialsObject *credentials;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) BDetailedViewType type;

@property (nonatomic, strong) UICollectionViewFlowLayout *viewTimelineLayout;
@property (nonatomic, strong) BTimelineSubview *viewTimeline;
@property (nonatomic, strong) BNavigationView *viewNavigation;

@end
