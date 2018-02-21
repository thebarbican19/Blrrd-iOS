//
//  BProfileHeader.m
//  Blrrd
//
//  Created by Joe Barbour on 27/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BProfileHeader.h"
#import "BConstants.h"
#import "BProfileCell.h"

@implementation BProfileHeader

-(void)drawRect:(CGRect)rect {
    self.credentials = [[BCredentialsObject alloc] init];
    self.query = [[BQueryObject alloc] init];
    if (![self.subviews containsObject:profile]) {
        self.backgroundColor = UIColorFromRGB(0x181426);

        hairline = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height - 0.5, self.bounds.size.width, 0.5)];
        hairline.backgroundColor = UIColorFromRGB(0x23232B);
        [self addSubview:hairline];

        profile = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 18.0, 120.0 - 32.0 ,120.0 - 32.0)];
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
        [self sendSubviewToBack:halo];

        username = [[SAMLabel alloc] initWithFrame:CGRectMake(profile.bounds.size.width + 35.0, 20.0, self.bounds.size.width - (profile.bounds.size.width - 75.0), (profile.bounds.size.height / 2))];
        username.backgroundColor = [UIColor clearColor];
        username.textAlignment = NSTextAlignmentLeft;
        username.textColor = [UIColor whiteColor];
        username.font = [UIFont fontWithName:@"Nunito-Bold" size:24];
        username.text = nil;
        [self addSubview:username];
        
        handle = [[SAMLabel alloc] initWithFrame:CGRectMake(profile.bounds.size.width + 35.0, 56.0, self.bounds.size.width - (profile.bounds.size.width - 75.0), 14.0)];
        handle.backgroundColor = [UIColor clearColor];
        handle.textAlignment = NSTextAlignmentLeft;
        handle.textColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        handle.font = [UIFont fontWithName:@"Nunito-Light" size:10];
        handle.text = [NSString stringWithFormat:@"@%@" ,self.credentials.userHandle];
        handle.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
        [self addSubview:handle];
        
        verifyed = [[UIImageView alloc] initWithFrame:CGRectMake(handle.frame.origin.x + [handle.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, handle.bounds.size.width) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:handle.font} context:nil].size.width + 4.0, handle.frame.origin.y + 1.0, 13.0 ,13.0)];
        verifyed.contentMode = UIViewContentModeScaleAspectFill;
        verifyed.layer.cornerRadius = verifyed.bounds.size.width / 2;
        verifyed.clipsToBounds = true;
        verifyed.hidden = !self.credentials.userVerifyed;
        verifyed.image = [UIImage imageNamed:@"profile_verifyed_icon"];
        verifyed.backgroundColor = [UIColor clearColor];
        [self addSubview:verifyed];
        [self bringSubviewToFront:verifyed];
        
        timeviewed = [[SAMLabel alloc] initWithFrame:CGRectMake(profile.bounds.size.width + 35.0, 80.0, 200.0, 16.0)];
        timeviewed.backgroundColor = [UIColor clearColor];
        timeviewed.layer.cornerRadius = 3.0;
        timeviewed.clipsToBounds = true;
        timeviewed.textAlignment = NSTextAlignmentLeft;
        timeviewed.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        timeviewed.font = [UIFont fontWithName:@"Nunito-SemiBold" size:9];
        timeviewed.verticalTextAlignment = SAMLabelVerticalTextAlignmentMiddle;
        [self addSubview:timeviewed];
        
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        gesture.delegate = self;
        gesture.enabled = true;
        [self addGestureRecognizer:gesture];
        
        settings = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 62.0, (self.bounds.size.height / 2) * 0, 45.0, self.bounds.size.height / 2)];
        settings.backgroundColor = [UIColor clearColor];
        settings.hidden = !self.owner;
        [settings setImage:[UIImage imageNamed:@"profile_settings_icon"] forState:UIControlStateNormal];
        [settings addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settings];
        
        friends = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 62.0, (self.bounds.size.height / 2) * 1, 45.0, self.bounds.size.height / 2)];
        friends.backgroundColor = [UIColor clearColor];
        friends.hidden = !self.owner;
        [friends setImage:[UIImage imageNamed:@"profile_friends_icon"] forState:UIControlStateNormal];
        [friends addTarget:self action:@selector(profile:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:friends];

    }
    
    [profile sd_setImageWithURL:self.credentials.userAvatar placeholderImage:[UIImage imageNamed:@"profile_avatar_placeholder"]];
    [handle setText:[NSString stringWithFormat:@"@%@" ,self.credentials.userHandle]];
    [timeviewed setAttributedText:self.format];
    [verifyed setFrame:CGRectMake(handle.frame.origin.x + [handle.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, handle.bounds.size.width) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:handle.font} context:nil].size.width + 4.0, handle.frame.origin.y + 1.0, 13.0 ,13.0)];
    [self name];
    
}

-(void)name {
    if (self.credentials.userFullname == nil) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration = 0.9;
        animation.toValue = [NSNumber numberWithFloat:0.1];
        animation.fromValue = [NSNumber numberWithFloat:0.2];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.autoreverses = true;
        animation.repeatCount = HUGE_VALF;
        
        [username.layer removeAnimationForKey:@"emptydisplay"];
        [username.layer addAnimation:animation forKey:@"emptydisplay"];
        [username setText:NSLocalizedString(@"Profile_HeaderPlaceholder_Text", nil)];
        
    }
    else {
        [username setText:self.credentials.userFullname];
        [username setAlpha:1.0];

    }
    
}

-(void)tapped:(UIGestureRecognizer *)gesture {
    if (self.credentials.userFullname == nil) {
        if ([self.delegate respondsToSelector:@selector(viewEditor:)]) {
            [self.delegate viewEditor:@"display"];
            
        }
        
    }
    else {
        if ([self.delegate respondsToSelector:@selector(viewPresentProfile)]) {
            [self.delegate viewPresentProfile];
            
        }
        
    }
    
}

-(void)settings:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(viewPresentSettings)]) {
        [self.delegate viewPresentSettings];
        
    }
    
}

-(void)profile:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(viewPresentProfile)]) {
        [self.delegate viewPresentFriends];
        
    }
    
}


-(NSMutableAttributedString *)format {
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Profile_TimeViewed_Body", nil),  self.credentials.userTotalTimeFormatted];
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:text];
    if (text) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
        NSArray *formatMatches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in formatMatches) {
            [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Nunito-Black" size:timeviewed.font.pointSize] range:NSMakeRange(match.range.location, match.range.length)];
            [formatted addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(match.range.location, match.range.length)];
            
        }
        
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        
    }
    
    return formatted;
    
}

@end
