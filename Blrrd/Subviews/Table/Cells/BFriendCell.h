//
//  BFriendCell.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImage+BlurEffects.h>
#import <UIImageView+WebCache.h>

@interface BFriendCell : UITableViewCell

@property (nonatomic, strong) UILabel *user;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIButton *request;

-(void)content:(NSDictionary *)item;

@end
