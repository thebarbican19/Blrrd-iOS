//
//  BTabbarView.m
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BTabbarView.h"
#import "BConstants.h"

@implementation BTabbarView

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:container]) {
        container = [[UIView alloc] initWithFrame:self.bounds];
        container.backgroundColor = UIColorFromRGB(0x181426);
        [self addSubview:container];
        
        hairline = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, container.bounds.size.width, 0.5)];
        hairline.backgroundColor = UIColorFromRGB(0x23232B);
        [container addSubview:hairline];
        [container sendSubviewToBack:hairline];

        for (int i = 0;i < self.buttons.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(((self.bounds.size.width / self.buttons.count) * i), 0.0, self.bounds.size.width / self.buttons.count, self.bounds.size.height)];
            button.backgroundColor = [UIColor clearColor];
            button.tag = i;
            button.clipsToBounds = false;
            [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:button];
            
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(button.frame.origin.x, i==1?-5.0:4.0,  button.bounds.size.width, button.bounds.size.height + (i==1?10.0:-18.0))];
            image.image = [UIImage imageNamed:[[self.buttons objectAtIndex:i] objectForKey:@"image"]];
            image.backgroundColor = [UIColor clearColor];
            image.tag = i;
            image.contentMode = UIViewContentModeCenter;
            [container addSubview:image];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x, button.bounds.size.height - 14.0, button.bounds.size.width, 9.0)];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = i;
            label.text = [[[self.buttons objectAtIndex:i] objectForKey:@"text"] uppercaseString];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"Nunito-ExtraBold" size:8];
            [container addSubview:label];

        }
        
    }
    
}

-(void)selected:(UIButton *)button {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.autoreverses = true;
    animation.repeatCount = 1;
    
    for (UIView *subview in container.subviews) {
        if (subview.tag == 0 || subview.tag == 2) animation.toValue = [NSNumber numberWithFloat:0.92];
        else animation.toValue = [NSNumber numberWithFloat:1.05];

        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *image = (UIImageView *)subview;
            if (button.tag == subview.tag) {
                [image.layer addAnimation:animation forKey:nil];
                
            }

        }
        
    }
    
    if ([self.delegate respondsToSelector:@selector(viewPresentSubviewWithIndex:animated:)]) {
        [self.delegate viewPresentSubviewWithIndex:(int)button.tag animated:true];
        
    }
    
}

-(void)viewUpdateWithTheme:(BTabbarViewTheme)theme {
    for (UIView *subview in container.subviews) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if (theme == BTabbarViewThemeDefault) {
                if ([subview isKindOfClass:[UILabel class]]) {
                    [(UILabel *)subview setAlpha:1.0];

                }
                
                if ([subview isKindOfClass:[UIImageView class]]) {
                    [(UIImageView *)subview setAlpha:1.0];
                    [(UIImageView *)subview setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                    
                    if (subview.tag == 0 || subview.tag == 2) {
                        CGRect imageframe = [(UIImageView *)subview frame];
                        imageframe.origin.y = 4.0;
                        
                        [(UIImageView *)subview setFrame:imageframe];
                        
                    }

                }
                
            }
            else {
                if ([subview isKindOfClass:[UILabel class]]) {
                    [(UILabel *)subview setAlpha:0.0];

                }
                
                if ([subview isKindOfClass:[UIImageView class]]) {
                    if (subview.tag == 0 || subview.tag == 2) {
                        [(UIImageView *)subview setAlpha:0.7];
                        [(UIImageView *)subview setTransform:CGAffineTransformMakeScale(0.6, 0.6)];
                        
                        CGRect imageframe = [(UIImageView *)subview frame];
                        imageframe.origin.y = 14.0;
                        
                        [(UIImageView *)subview setFrame:imageframe];

                    }
                    else {
                        [(UIImageView *)subview setTransform:CGAffineTransformMakeScale(1.1, 1.1)];

                    }
                    
                }
                
            }
            
        } completion:nil];
        
    }
    
    if (theme == BTabbarViewThemeDefault) {
        [container setBackgroundColor:UIColorFromRGB(0x181426)];
        [hairline setHidden:false];

    }
    else {
        [container setBackgroundColor:[UIColor clearColor]];
        [hairline setHidden:true];
        
    }
    
}

@end
