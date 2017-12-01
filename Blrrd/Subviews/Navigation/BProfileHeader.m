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
        
        settings = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 62.0, 22.0, 45.0, 45.0)];
        settings.backgroundColor = [UIColor clearColor];
        settings.hidden = !self.owner;
        [settings setImage:[UIImage imageNamed:@"profile_settings_icon"] forState:UIControlStateNormal];
        [settings addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settings];

    }
    
    [email setText:self.credentials.userEmail];
    [username setText:self.credentials.userHandle];
    [timeviewed setAttributedText:self.format];
    
}

-(void)tapped:(UIGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(viewPresentProfile)]) {
        [self.delegate viewPresentProfile];
        
    }
    
}

-(void)settings:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(viewPresentSettings)]) {
        [self.delegate viewPresentSettings];
        
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
