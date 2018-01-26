//
//  BUserPorfileHeader.h
//  Blrrd
//
//  Created by Joe Barbour on 14/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>

#import "SAMLabel.h"
#import "BQueryObject.h"
#import "BFollowAction.h"

@protocol BUserProfileHeaderDelegate;
@interface BUserProfileHeader : UIView <BFollowActionDelegate> {
    UIImageView *profile;
    UIView *halo;
    UIView *hairline;
    SAMLabel *username;
    SAMLabel *lastactive;
    UIButton *back;
    CAGradientLayer *gradient;
    BFollowAction *follow;
    UIButton *action;

}

@property (nonatomic, strong) id <BUserProfileHeaderDelegate> delegate;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) NSDictionary *data;

-(void)setup:(NSDictionary *)data;

@end

@protocol BUserProfileHeaderDelegate <NSObject>

@optional

-(void)viewNavigationButtonTapped:(UIButton *)button;

@end
