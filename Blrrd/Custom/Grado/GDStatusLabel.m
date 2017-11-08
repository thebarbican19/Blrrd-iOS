//
//  LKStatusLabel.m
//  Lynker
//
//  Created by Joe Barbour on 20/07/2015.
//  Copyright (c) 2015 Lynker. All rights reserved.
//

#import "GDStatusLabel.h"

@implementation GDStatusLabel

-(void)drawRect:(CGRect)rect {
    if (!self.alignment) self.alignment = NSTextAlignmentLeft;
    
    if (![self.subviews containsObject:statusLabel]) {
        statusLabel = [[SAMLabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
        statusLabel.textColor = self.colour;
        statusLabel.verticalTextAlignment = SAMLabelVerticalTextAlignmentMiddle;
        statusLabel.textAlignment = self.alignment;
        statusLabel.font = self.fount;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.numberOfLines = 1;
        if ([self.content isKindOfClass:[NSAttributedString class]]) statusLabel.attributedText = self.content;
        else if ([self.content isKindOfClass:[NSString class]]) statusLabel.text = self.content;
        [self addSubview:statusLabel];
        
        statusLoader = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        statusLoader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        statusLoader.hidesWhenStopped = true;
        statusLoader.backgroundColor = [UIColor clearColor];
        [self addSubview:statusLoader];

        statusGradient = [CAGradientLayer layer];
        statusGradient.frame = self.bounds;
        statusGradient.colors = @[(id)[self.backgroundColor colorWithAlphaComponent:1.0].CGColor,
                                  (id)[self.backgroundColor colorWithAlphaComponent:0.0].CGColor,
                                  (id)[self.backgroundColor colorWithAlphaComponent:0.0].CGColor,
                                  (id)[self.backgroundColor colorWithAlphaComponent:1.0].CGColor];
        statusGradient.startPoint = CGPointMake(0.0, 0.0);
        statusGradient.endPoint = CGPointMake(0.0, 1.0);
        //[self.layer addSublayer:statusGradient];

    }

}

-(void)setText:(id)text animate:(BOOL)animate {
    NSString *check;
    if ([text isKindOfClass:[NSAttributedString class]]) check = [text string];
    else check = text;
    if (![check isEqualToString:statusLabel.text] ) {
        if (animate) {
            statusFrame = statusLabel.frame;
            if (!statusAnimating) {
                statusAnimating = true;
                [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    statusFrame.origin.y =  0.0 - (self.bounds.size.height - 50.0);
                    statusLabel.frame = statusFrame;
                    statusLabel.alpha = 0.0;
                } completion:^(BOOL finished) {
                    statusFrame.origin.y = 0.0 + (self.bounds.size.height - 50.0);
                    statusLabel.frame = statusFrame;
                    if ([text isKindOfClass:[NSAttributedString class]]) statusLabel.attributedText = text;
                    else statusLabel.text = text;
                    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        statusFrame.origin.y = self.bounds.origin.y;
                        statusLabel.frame = statusFrame;
                        statusLabel.alpha = 1.0;

                    } completion:^(BOOL finished) {
                        statusAnimating = false;

                    }];

                }];
                
            }
            else {
                if ([text isKindOfClass:[NSAttributedString class]]) statusLabel.attributedText = text;
                else statusLabel.text = text;
                
            }
            
        }
        else {
            if ([text isKindOfClass:[NSAttributedString class]]) statusLabel.attributedText = text;
            else statusLabel.text = text;
            
        }
        
    }
    
    if ([text isKindOfClass:[NSAttributedString class]]) self.content = [text string];
    else self.content = text;
    
}

-(void)setStatusColour:(UIColor *)colour animate:(BOOL)animate {
    [UIView animateWithDuration:animate?0.2:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        //statusLabel.textColor = colour;
        
    } completion:nil];
}

@end
