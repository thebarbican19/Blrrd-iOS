//
//  BFriendsHeader.m
//  Blrrd
//
//  Created by Joe Barbour on 10/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import "BFriendHeader.h"
#import "BConstants.h"

@implementation BFriendHeader

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:container]) {
        container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 10.0, self.bounds.size.width, self.bounds.size.height - 10.0)];
        container.backgroundColor = UIColorFromRGB(0x140F26);
        container.userInteractionEnabled = true;
        [self addSubview:container];
        
        icon = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 10.0, container.bounds.size.height - 20.0, container.bounds.size.height - 20.0)];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.backgroundColor = [UIColor clearColor];
        icon.image = [UIImage imageNamed:@"friends_contacts_icon"];
        [container addSubview:icon];
        
        label = [[SAMLabel alloc] initWithFrame:CGRectMake(container.bounds.size.height + 12.0, 0.0, self.bounds.size.width - (container.bounds.size.height + 76.0), container.bounds.size.height)];
        label.font = [UIFont fontWithName:@"Nunito-Regular" size:14.0];
        label.attributedText = nil;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 2;
        [container addSubview:label];

        accsesory = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 58.0, 2.0, 51.0, container.bounds.size.height)];
        accsesory.contentMode = UIViewContentModeCenter;
        accsesory.userInteractionEnabled = false;
        accsesory.image = [UIImage imageNamed:@"navigation_back"];
        accsesory.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
        [container addSubview:accsesory];
        
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        gesture.delegate = self;
        [container addGestureRecognizer:gesture];

    }
    
}

-(void)headerset:(NSString *)content animated:(BOOL)animated {
    NSLog(@"string: %@ content: %@" ,label.attributedText.string ,content);
    if (![content isEqualToString:label.attributedText.string] || label.attributedText.string == nil) {
        if (animated) {
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [label setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [label setAttributedText:[self format:content]];
                [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [label setAlpha:1.0];

                } completion:nil];
                
            }];
            
        }
        else {
            [label setAttributedText:[self format:content]];

        }
        
    }
         
}

-(void)gesture:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(viewHeaderTapped:)]) {
        [self.delegate viewHeaderTapped:self.type];
        
    }
    
}

-(NSMutableAttributedString *)format:(NSString *)content {
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:content];
    if (content) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
        NSArray *formatMatches = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        for (NSTextCheckingResult *match in formatMatches) {
            [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Nunito-ExtraBold" size:label.font.pointSize] range:NSMakeRange(match.range.location, match.range.length)];
            [formatted addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(match.range.location, match.range.length)];
            
        }
        
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        
    }
    
    return formatted;
    
}

@end
