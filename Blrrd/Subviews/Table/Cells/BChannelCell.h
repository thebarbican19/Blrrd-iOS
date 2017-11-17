//
//  BChannelCell.h
//  Blrrd
//
//  Created by Joe Barbour on 14/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImage+BlurEffects.h>
#import <UIImageView+WebCache.h>

#import "SAMLabel.h"

@interface BChannelCell : UICollectionViewCell

@property (nonatomic ,strong) UIView *container;
@property (nonatomic ,strong) UIImageView *image;
@property (nonatomic ,strong) UIImageView *overlay;
@property (nonatomic ,strong) SAMLabel *channel;

-(void)content:(NSDictionary *)content index:(NSIndexPath *)index;

@end
