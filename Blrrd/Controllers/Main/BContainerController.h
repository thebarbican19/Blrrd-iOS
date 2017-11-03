//
//  BContainerController.h
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BQueryObject.h"
#import "BCredentialsObject.h"
#import "BTimelineSubview.h"

@interface BContainerController : UIViewController

@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) BCredentialsObject *credentials;

@property (nonatomic, strong) BTimelineSubview *viewTimeline;
@property (nonatomic, strong) UICollectionViewFlowLayout *viewTimelineLayout;

@property (nonatomic) UIStatusBarStyle statusbarstyle;
@property (nonatomic) BOOL statusbarhidden;

@end
