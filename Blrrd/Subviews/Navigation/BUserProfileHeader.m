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

        halo = [[UIView alloc] initWithFrame:CGRectMake(profile.frame.origin.x - 2.5, profile.frame.origin.y - 2.5, profile.bounds.size.width + 5.0, profile.bounds.size.height + 5.0)];
        halo.clipsToBounds = true;
        halo.backgroundColor = UIColorFromRGB(0x26CADF);
        halo.layer.cornerRadius = halo.bounds.size.height / 2;
        [self addSubview:halo];
        [self bringSubviewToFront:profile];
        
        username = [[SAMLabel alloc] initWithFrame:CGRectMake(profile.bounds.size.width + 70.0, 10.0, self.bounds.size.width - (profile.bounds.size.width - 120.0), (profile.bounds.size.height / 2))];
        username.backgroundColor = [UIColor clearColor];
        username.textAlignment = NSTextAlignmentLeft;
        username.textColor = [UIColor whiteColor];
        username.font = [UIFont fontWithName:@"Nunito-Bold" size:20];
        [self addSubview:username];
        
        lastactive = [[SAMLabel alloc] initWithFrame:CGRectMake(profile.bounds.size.width + 70.0, 36.0, self.bounds.size.width - (profile.bounds.size.width - 120.0), 14.0)];
        lastactive.backgroundColor = [UIColor clearColor];
        lastactive.textAlignment = NSTextAlignmentLeft;
        lastactive.textColor = [UIColor colorWithWhite:0.9 alpha:0.8];
        lastactive.font = [UIFont fontWithName:@"Nunito-Light" size:10];
        lastactive.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
        [self addSubview:lastactive];
        
        verifyed = [[UIImageView alloc] initWithFrame:CGRectZero];
        verifyed.contentMode = UIViewContentModeScaleAspectFill;
        verifyed.layer.cornerRadius = verifyed.bounds.size.width / 2;
        verifyed.clipsToBounds = true;
        verifyed.hidden = true;
        verifyed.backgroundColor = [UIColor clearColor];
        verifyed.image = [UIImage imageNamed:@"profile_verifyed_icon"];
        [self addSubview:verifyed];
        [self bringSubviewToFront:verifyed];
        
        action = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 46.0, (self.bounds.size.height / 2) - 12.0, 45.0, 24.0)];
        action.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [action setTag:1];
        [action addTarget:self.delegate action:@selector(viewNavigationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [action setImage:[UIImage imageNamed:@"timeline_options_action"] forState:UIControlStateNormal];
        [self addSubview:action];
        /*
        follow = [[BFollowAction alloc] initWithFrame:CGRectMake(self.bounds.size.width - 46.0, (self.bounds.size.height / 2) - 12.0, 45.0, 24.0)];
        follow.backgroundColor = [UIColor clearColor];
        follow.delegate = self;
        follow.alpha = 0.0;
        follow.style = BFollowActionStyleIcon;
        follow.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [self addSubview:follow];
        */
        
    }
    
}

-(void)setup:(NSDictionary *)data {
    self.data = [[NSDictionary alloc] initWithDictionary:data];

    [profile sd_setImageWithURL:[self.data objectForKey:@"avatar"] placeholderImage:[UIImage imageNamed:@"profile_avatar_placeholder"]];
    if ([[self.data objectForKey:@"displayname"] length] > 0) {
        [username setText:[self.data objectForKey:@"displayname"]];
        [lastactive setText:[NSString stringWithFormat:NSLocalizedString(@"Friend_StatusWithUsername_Text", nil), [self.data objectForKey:@"username"] ,[self time:[self.data objectForKey:@"lastactive"]]]];
    
    }
    else {
        [username setText:[self.data objectForKey:@"username"]];
        [lastactive setText:[NSString stringWithFormat:NSLocalizedString(@"Friend_StatusWithLastActive_Text", nil) ,[self time:[self.data objectForKey:@"lastactive"]]]];

    }
    [verifyed setHidden:![[self.data objectForKey:@"promoted"] boolValue]];
    [verifyed setFrame:CGRectMake(lastactive.frame.origin.x + [lastactive.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, lastactive.bounds.size.width) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:lastactive.font} context:nil].size.width + 6.0, lastactive.frame.origin.y + 1.0, 14.0 ,14.0)];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [username setAlpha:1.0];

    } completion:nil];
    
}

-(NSString *)time:(NSString *)timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    if ([[formatter dateFromString:timestamp] isKindOfClass:[NSDate class]]) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[formatter dateFromString:timestamp] toDate:[NSDate date] options:0];
        
        NSDateFormatter *formatted = [[NSDateFormatter alloc] init];
        formatted.dateFormat = @"d MMMM YYYY";
        formatted.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        formatted.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        if (components.day > 7) {
            return [formatted stringFromDate:[formatter dateFromString:timestamp]];
            
        }
        else if (components.day > 0) {
            return [NSString stringWithFormat:NSLocalizedString(@"Timestamp_Format", nil) ,(int)components.day, components.day==1?NSLocalizedString(@"Timestamp_Day", nil):NSLocalizedString(@"Timestamp_Days", nil)];
            
        }
        else if (components.hour > 0) {
            return [NSString stringWithFormat:NSLocalizedString(@"Timestamp_Format", nil) ,(int)components.hour, components.hour==1?NSLocalizedString(@"Timestamp_Hour", nil):NSLocalizedString(@"Timestamp_Hours", nil)];
            
        }
        else if (components.minute > 0) {
            return [NSString stringWithFormat:NSLocalizedString(@"Timestamp_Format", nil) ,(int)components.minute, components.minute==1?NSLocalizedString(@"Timestamp_Minute", nil):NSLocalizedString(@"Timestamp_Minutes", nil)];
            
        }
        else if (components.second > 0) {
            return [NSString stringWithFormat:NSLocalizedString(@"Timestamp_Format", nil) ,(int)components.minute, components.minute==1?NSLocalizedString(@"Timestamp_Second", nil):NSLocalizedString(@"Timestamp_Seconds", nil)];
        }
        else {
            return [formatted stringFromDate:[formatter dateFromString:timestamp]];
            
        }
        
    }
    else return NSLocalizedString(@"Profile_UnknownTimetampPlaceholder_Text", nil);
    
}

@end
