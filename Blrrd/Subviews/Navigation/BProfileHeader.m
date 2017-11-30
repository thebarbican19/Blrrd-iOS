//
//  BProfileHeader.m
//  Blrrd
//
//  Created by Joe Barbour on 27/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BProfileHeader.h"
#import "BConstants.h"

@implementation BProfileHeader

-(void)drawRect:(CGRect)rect {
    self.credentials = [[BCredentialsObject alloc] init];
    if (![self.subviews containsObject:profile]) {
        profile = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 18.0, self.bounds.size.height - 32.0 ,self.bounds.size.height - 32.0)];
        profile.contentMode = UIViewContentModeScaleAspectFill;
        profile.backgroundColor = [UIColor darkGrayColor];
        profile.layer.cornerRadius = profile.bounds.size.width / 2;
        profile.clipsToBounds = true;
        profile.layer.borderColor = UIColorFromRGB(0x140F26).CGColor;
        profile.layer.borderWidth = 1.4;
        [self addSubview:profile];
        [profile sd_setImageWithURL:self.credentials.userAvatar];
        
        halo = [[UIView alloc] initWithFrame:CGRectMake(profile.frame.origin.x - 2.0, profile.frame.origin.y - 2.0, profile.bounds.size.width + 4.0, profile.bounds.size.height + 4.0)];
        halo.clipsToBounds = true;
        halo.backgroundColor = UIColorFromRGB(0x26CADF);
        halo.layer.cornerRadius = halo.bounds.size.height / 2;
        [self addSubview:halo];
        [self sendSubviewToBack:halo];
        
        username = [[SAMLabel alloc] initWithFrame:CGRectMake(profile.bounds.size.width + 35.0, 20.0, self.bounds.size.width - (profile.bounds.size.width - 75.0), (profile.bounds.size.height / 2))];
        username.backgroundColor = [UIColor clearColor];
        username.textAlignment = NSTextAlignmentLeft;
        username.textColor = [UIColor whiteColor];
        username.font = [UIFont fontWithName:@"Nunito-Bold" size:24];
        username.text = self.credentials.userHandle;
        [self addSubview:username];
        
        email = [[SAMLabel alloc] initWithFrame:CGRectMake(profile.bounds.size.width + 35.0, 56.0, self.bounds.size.width - (profile.bounds.size.width - 75.0), 14.0)];
        email.backgroundColor = [UIColor clearColor];
        email.textAlignment = NSTextAlignmentLeft;
        email.textColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        email.font = [UIFont fontWithName:@"Nunito-Light" size:10];
        email.text = self.credentials.userEmail;
        email.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
        [self addSubview:email];
        
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        gesture.delegate = self;
        gesture.enabled = true;
        [self addGestureRecognizer:gesture];

    }
    
    email.text = self.credentials.userEmail;
    username.text = self.credentials.userHandle;

}

-(void)tapped:(UIGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(viewPresentProfile)]) {
        [self.delegate viewPresentProfile];
        
    }
}

@end
