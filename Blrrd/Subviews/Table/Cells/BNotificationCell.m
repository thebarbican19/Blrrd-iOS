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
    if (self) {
        self.status = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 0.0, self.bounds.size.width - 16.0 , self.bounds.size.height - 14.0)];
        self.status.clipsToBounds = true;
        self.status.textAlignment = NSTextAlignmentLeft;
        self.status.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        self.status.font = [UIFont fontWithName:@"Nunito-Regular" size:14];
        [self.contentView addSubview:self.status];
        
        self.timestamp = [[UILabel alloc] initWithFrame:CGRectMake(19.0, self.bounds.size.height - 14.0, self.bounds.size.width - 16.0 ,8.0)];
        self.timestamp.clipsToBounds = true;
        self.timestamp.textAlignment = NSTextAlignmentLeft;
        self.timestamp.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        self.timestamp.font = [UIFont fontWithName:@"Nunito-ExtraBold" size:8];
        [self.contentView addSubview:self.timestamp];
        
        self.image = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - (self.bounds.size.height + 10.0), 2.0, self.bounds.size.height - 4.0, self.bounds.size.height - 4.0)];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.image = nil;
        self.image.clipsToBounds = true;
        self.image.layer.cornerRadius = 4.0;
        [self.contentView addSubview:self.image];

    }
    
    return self;
    
}

-(void)content:(NSDictionary *)item {
    [self.timestamp setText:[self time:[item objectForKey:@"posted_datetime"]]];
    [self.status setAttributedText:[self format:item]];
    [self.image sd_setImageWithURL:[item objectForKey:@"publicpath"]];
    
}

-(NSString *)time:(NSDate *)timestamp {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:timestamp toDate:[NSDate date] options:0];
    
    NSDateFormatter *formatted = [[NSDateFormatter alloc] init];
    formatted.dateFormat = @"d MMMM YYYY";
    
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

-(NSMutableAttributedString *)format:(NSDictionary *)content {
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"Profile_NotificationViewed_Body", nil) ,[content objectForKey:@"username"] ,[self seconds:[[content objectForKey:@"seconds"] intValue]]];
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
