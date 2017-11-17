//
//  BFooterView.m
//  Blrrd
//
//  Created by Joe Barbour on 13/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BFooterView.h"

@implementation BFooterView

-(void)present:(BOOL)loading status:(NSString *)status {
    if (![self.subviews containsObject:self.label]) {
        self.label = [[SAMLabel alloc] initWithFrame:CGRectMake(30.0, 5.0, self.bounds.size.width - 60.0, self.bounds.size.height - 10.0)];
        self.label.font = [UIFont fontWithName:@"Nunito-SemiBold" size:10];
        self.label.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.label.numberOfLines = 2;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.userInteractionEnabled = false;
        self.label.alpha = 0.0;
        self.label.verticalTextAlignment = SAMLabelVerticalTextAlignmentMiddle;
        [self addSubview:self.label];

        self.loader = [[BLMultiColorLoader alloc] initWithFrame:CGRectMake(0.0, 5.0, self.bounds.size.width, self.bounds.size.height - 10.0)];
        self.loader.backgroundColor = [UIColor clearColor];
        self.loader.lineWidth = 2.8;
        self.loader.colorArray = @[self.label.textColor];
        self.loader.userInteractionEnabled = false;
        self.loader.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [self addSubview:self.loader];
        
    }
    
    if (loading) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.label setFrame:CGRectMake(30.0, self.bounds.size.height, self.bounds.size.width - 60.0, self.bounds.size.height - 4.0)];
            [self.label setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            [self.loader startAnimation];
            [UIView animateWithDuration:0.1 animations:^{
                [self.loader setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

            } completion:nil];
            
        }];
        
    }
    else {
        [self.label setAttributedText:[self text:status]];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.loader setTransform:CGAffineTransformMakeScale(0.9, 0.9)];

        } completion:^(BOOL finished) {
            [self.loader stopAnimation];
            [UIView animateWithDuration:0.1 animations:^{
                [self.label setFrame:CGRectMake(30.0, 2.0, self.bounds.size.width - 60.0, self.bounds.size.height - 4.0)];
                [self.label setAlpha:1.0];
                
            } completion:nil];

        }];
        
    }
    
    self.loading = loading;

    
}

-(NSAttributedString *)text:(NSString *)content {
    NSMutableAttributedString *string;
    if (content) {
        string = [[NSMutableAttributedString alloc] initWithString:content.uppercaseString];
        NSRange range = NSMakeRange(0, content.length);
        [string addAttribute:NSKernAttributeName value:@(1.6) range:range];
        
    }
        
    return string;
    
}

@end
