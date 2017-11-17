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
        self.status = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 0.0, self.bounds.size.width - 16.0 , self.bounds.size.height - 6.0)];
        self.status.clipsToBounds = true;
        self.status.textAlignment = NSTextAlignmentLeft;
        self.status.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        self.status.font = [UIFont fontWithName:@"Nunito-Regular" size:14];
        [self.contentView addSubview:self.status];
        
        self.timestamp = [[UILabel alloc] initWithFrame:CGRectMake(19.0, self.bounds.size.height - 12.0, self.bounds.size.width - 16.0 ,8.0)];
        self.timestamp.clipsToBounds = true;
        self.timestamp.textAlignment = NSTextAlignmentLeft;
        self.timestamp.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        self.timestamp.font = [UIFont fontWithName:@"Nunito-ExtraBold" size:8];
        [self.contentView addSubview:self.timestamp];
        
    }
    
    return self;
    
}

-(void)content:(NSDictionary *)item {
    [self.timestamp setText:[self time:[item objectForKey:@"posted_datetime"]]];
    [self.status setAttributedText:[self format:item]];
    
}

-(NSString *)time:(NSString *)timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[formatter dateFromString:timestamp] toDate:[NSDate date] options:0];
    
    NSDateFormatter *formatted = [[NSDateFormatter alloc] init];
    formatted.dateFormat = @"d MMMM YYYY";
    
    if (components.day > 7) {
        return [formatted stringFromDate:[formatter dateFromString:timestamp]];
        
    }
    else if (components.day > 0) {
        return [NSString stringWithFormat:@"%d %@ ago" ,(int)components.day, components.day==1?@"day":@"days"];
        
    }
    else if (components.hour > 0) {
        return [NSString stringWithFormat:@"%d %@ ago" ,(int)components.hour, components.hour==1?@"hour":@"hour"];
        
    }
    else if (components.minute > 0) {
        return [NSString stringWithFormat:@"%d %@ ago" ,(int)components.minute, components.minute==1?@"minute":@"minutes"];
        
    }
    else {
        return nil;
        
    }
    
}

-(NSMutableAttributedString *)format:(NSDictionary *)content {
    NSString *text = [NSString stringWithFormat:@"*%@* viewed your post for *%@*" ,[content objectForKey:@"username"] ,[self seconds:[[content objectForKey:@"seconds"] intValue]]];
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:text];
    if (text) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
        NSArray *formatMatches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *match in formatMatches) {
            [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Nunito-Bold" size:self.status.font.pointSize] range:NSMakeRange(match.range.location, match.range.length)];
            [formatted addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(match.range.location, match.range.length)];

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
