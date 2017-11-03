//
//  BTimelineSubview.h
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBlurredCell.h"

@interface BTimelineSubview : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, strong) BBlurredCell *activecell;

@end
