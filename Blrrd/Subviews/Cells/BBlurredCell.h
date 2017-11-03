//
//  BBlurredCell.h
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImage+BlurEffects.h>
#import <UIImageView+WebCache.h>
#import <Mixpanel.h>
#import "SAMLabel.h"

@interface BBlurredCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic ,strong) Mixpanel *mixpanel;
@property (nonatomic ,strong) NSMutableDictionary *content;

@property (nonatomic ,strong) UIView *container;
@property (nonatomic ,strong) UIImageView *image;
@property (nonatomic ,strong) UIImageView *overlay;
@property (nonatomic ,strong) SAMLabel *subtitle;
@property (nonatomic ,strong) UILongPressGestureRecognizer *gesture;

-(void)content:(NSDictionary *)content index:(NSIndexPath *)index;
-(void)reveal:(UILongPressGestureRecognizer *)gesture;
-(void)backgroundoffset:(CGPoint)offset;

@end
