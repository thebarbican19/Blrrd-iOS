//
//  BUserPorfileHeader.m
//  Blrrd
//
//  Created by Joe Barbour on 14/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BUserProfileHeader.h"
#import "BConstants.h"

@implementation BUserProfileHeader

-(void)drawRect:(CGRect)rect {
    self.query = [[BQueryObject alloc] init];
    if (![self.subviews containsObject:profile]) {
        gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = @[(id)[UIColorFromRGB(0x140F26) colorWithAlphaComponent:1.0].CGColor, (id)[UIColorFromRGB(0x140F26) colorWithAlphaComponent:0.8].CGColor];
        gradient.startPoint = CGPointMake(0.0, 0.0);
        gradient.endPoint = CGPointMake(0.0, 1.0);
        [self.layer addSublayer:gradient];
        
        back =  [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, self.bounds.size.height)];
        back.tag = 0;
        back.backgroundColor = [UIColor clearColor];
        [back setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [back addTarget:self.delegate action:@selector(viewNavigationButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:back];

        profile = [[UIImageView alloc] initWithFrame:CGRectMake(50.0, 4.0, self.bounds.size.height - 12.0 ,self.bounds.size.height - 12.0)];
        profile.contentMode = UIViewContentModeScaleAspectFill;
        profile.backgroundColor = [UIColor darkGrayColor];
        profile.layer.cornerRadius = profile.bounds.size.width / 2;
        profile.clipsToBounds = true;
        profile.layer.borderColor = UIColorFromRGB(0x140F26).CGColor;
        profile.layer.borderWidth = 1.4;
        [self addSubview:profile];

        halo = [[UIView alloc] initWithFrame:CGRectMake(profile.frame.origin.x - 2.0, profile.frame.origin.y - 2.0, profile.bounds.size.width + 4.0, profile.bounds.size.height + 4.0)];
        halo.clipsToBounds = true;
        halo.backgroundColor = UIColorFromRGB(0x26CADF);
        halo.layer.cornerRadius = halo.bounds.size.height / 2;
        [self addSubview:halo];
        [self bringSubviewToFront:profile];
        
        username = [[SAMLabel alloc] initWithFrame:CGRectMake(profile.bounds.size.width + 70.0, 7.0, self.bounds.size.width - (profile.bounds.size.width + 120.0), self.bounds.size.height - 14.0)];
        username.backgroundColor = [UIColor clearColor];
        username.textAlignment = NSTextAlignmentLeft;
        username.textColor = [UIColor whiteColor];
        username.font = [UIFont fontWithName:@"Nunito-Bold" size:20];
        username.alpha = 0.0;
        [self addSubview:username];
        
        follow = [[BFollowAction alloc] initWithFrame:CGRectMake(self.bounds.size.width - 46.0, (self.bounds.size.height / 2) - 12.0, 45.0, 24.0)];
        follow.backgroundColor = [UIColor clearColor];
        follow.delegate = self;
        follow.alpha = 0.0;
        follow.style = BFollowActionStyleIcon;
        follow.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [self addSubview:follow];
        
    }
    
}

-(void)setup:(NSDictionary *)data {
    self.data = [[NSDictionary alloc] initWithDictionary:data];
    
    [profile sd_setImageWithURL:[self.data objectForKey:@"photo"] placeholderImage:[UIImage imageNamed:@"profile_avatar_placeholder"]];
    [username setText:[self.data objectForKey:@"username"]];
    
    if ([self.query friendCheck:[self.data objectForKey:@"username"]]) {
        [follow followSetType:BFollowActionTypeFollowed animate:false];
        
    }
    else {
        [follow followSetType:BFollowActionTypeUnfollowed animate:false];

    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [follow setAlpha:1.0];
        [follow setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [username setAlpha:1.0];

    } completion:nil];
    
}

@end
