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

#import "BFollowAction.h"
#import "BQueryObject.h"

@protocol BFriendDelegateCell;
@interface BFriendCell : UITableViewCell <BFollowActionDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id <BFriendDelegateCell> delegate;
@property (nonatomic, strong) UILabel *user;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) BFollowAction *follow;
@property (nonatomic, strong) UITapGestureRecognizer *gesture;
@property (nonatomic, strong) UIImageView *verifyed;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) BQueryObject *query;

-(void)content:(NSDictionary *)item;

@end

@protocol BFriendDelegateCell <NSObject>

@optional

-(void)viewPresentProfile:(NSDictionary *)data;

@end
