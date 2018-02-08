//
//  BNotificationCell.m
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BNotificationCell.h"
#import "BConstants.h"

@implementation BNotificationCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.credentials = [[BCredentialsObject alloc] init];
    if (self) {
        self.status = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.height, 0.0, self.bounds.size.width - self.bounds.size.height, self.bounds.size.height - 14.0)];
        self.status.clipsToBounds = true;
        self.status.textAlignment = NSTextAlignmentLeft;
        self.status.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        self.status.font = [UIFont fontWithName:@"Nunito-Regular" size:14];
        [self.contentView addSubview:self.status];
        
        self.timestamp = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.height, self.bounds.size.height - 14.0, self.bounds.size.width - self.bounds.size.height ,8.0)];
        self.timestamp.clipsToBounds = true;
        self.timestamp.textAlignment = NSTextAlignmentLeft;
        self.timestamp.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        self.timestamp.font = [UIFont fontWithName:@"Nunito-ExtraBold" size:8];
        [self.contentView addSubview:self.timestamp];
        
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(2.0, 2.0, self.bounds.size.height - 4.0, self.bounds.size.height - 4.0)];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.image = nil;
        self.image.clipsToBounds = true;
        self.image.layer.cornerRadius = 4.0;
        [self.contentView addSubview:self.image];

    }
    
    return self;
    
}

-(void)content:(NSDictionary *)item type:(BNotificationCellType)type {
    if ([[item objectForKey:@"timestamp"] isKindOfClass:[NSDate class]]) {
        [self.timestamp setText:[self time:[item objectForKey:@"timestamp"]]];

    }
    else {
        [self.timestamp setText:@"Unknown Date"];

    }
    
    [self.status setAttributedText:[self format:item type:type]];
    [self.image sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@content/image.php?id=%@&tok=%@" ,APP_HOST_URL ,[item objectForKey:@"imageurl"], self.credentials.authToken]]];
    
}

-(NSString *)time:(NSDate *)timestamp {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:timestamp toDate:[NSDate date] options:0];
    
    NSDateFormatter *formatted = [[NSDateFormatter alloc] init];
    formatted.dateFormat = @"d MMMM YYYY";
    formatted.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    formatted.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    if (components.day > 7) {
        return [formatted stringFromDate:timestamp];
        
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
    else {
        return nil;
        
    }
    
}

-(NSMutableAttributedString *)format:(NSDictionary *)content type:(BNotificationCellType)type {
    NSString *body;
    NSString *text;
    if (type == BNotificationCellTypeAllTime) {
        NSString *totalsecs = [self seconds:[[content objectForKey:@"totalsecs"] intValue]];
        NSString *newsecs = [NSString stringWithFormat:@"+%d " ,[[content objectForKey:@"seconds"] intValue]];
        body = NSLocalizedString(@"Profile_NotificationBasic_Body", nil);
        text = [NSString stringWithFormat:body, totalsecs ,newsecs];
        
    }
    else {
        NSString *username ;
        if ([[[content objectForKey:@"user"] objectForKey:@"username"] length] > 1) username = [[content objectForKey:@"user"] objectForKey:@"username"];
        else username = NSLocalizedString(@"Profile_UnknownUserPlaceholder_Text", nil);
        body = NSLocalizedString(@"Profile_NotificationDetailed_Body", nil);
        text = [NSString stringWithFormat:body, username];
        
    }
    
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:text];
    if (text) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
        NSArray *formatMatches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        int matchint = 0;
        for (NSTextCheckingResult *match in formatMatches) {
            [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Nunito-Bold" size:self.status.font.pointSize] range:NSMakeRange(match.range.location, match.range.length)];
            [formatted addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(match.range.location, match.range.length)];
            if (matchint == 0) {
                [formatted addAttributes:@{@"tappable":@(true), @"type":@"profile"} range:NSMakeRange(match.range.location, match.range.length)];
                
            }
            
            matchint ++;

        }
        
        NSRegularExpression *plusregex = [NSRegularExpression regularExpressionWithPattern:@"[+](\\d{0,2})\\s(\\w{0,8})*" options:0 error:nil];
        NSArray *formatplus = [plusregex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in formatplus) {
            [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Nunito-Black" size:self.status.font.pointSize - 2] range:NSMakeRange(match.range.location, match.range.length)];
            [formatted addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x69DCCB) range:NSMakeRange(match.range.location, match.range.length)];

            
        }
        
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        
    }
    
    return formatted;
    
}

-(NSString *)seconds:(int)seconds {
    if (seconds == 1) return [NSString stringWithFormat:@"%d second" ,seconds];
    else if (seconds < 60) return [NSString stringWithFormat:@"%d seconds" ,seconds];
    else if (seconds < 120) return [NSString stringWithFormat:@"%d minute" ,seconds / 60 % 60];
    return [NSString stringWithFormat:@"%d minutes" ,seconds / 60 % 60];
    
}

@end
