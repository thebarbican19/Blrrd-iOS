//
//  BNotificationCell.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImage+BlurEffects.h>
#import <UIImageView+WebCache.h>

@interface BNotificationCell : UITableViewCell

@property (nonatomic, strong) UILabel *status;
@property (nonatomic, strong) UILabel *timestamp;

-(void)content:(NSDictionary *)item;

@end
