//
//  GDPlaceholderView.m
//  Grado
//
//  Created by Joe Barbour on 17/12/2015.
//  Copyright © 2015 NorthernSpark. All rights reserved.
//

#import "GDPlaceholderView.h"
#import "BConstants.h"

@implementation GDPlaceholderView

-(void)drawRect:(CGRect)rect {
    if (!self.textcolor) self.textcolor = UIColorFromRGB(0x32353A);
    
    if (![placeholderTitle isDescendantOfView:self.superview]) {
        placeholderContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, (self.bounds.size.height / 3) * 2)];
        placeholderContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:placeholderContainer];
        
        placeholderTitle = [[SAMLabel alloc] initWithFrame:CGRectMake(15.0,
                                                                      20.0,
                                                                      self.bounds.size.width - 30.0,
                                                                      self.bounds.size.height - 40.0)];
        placeholderTitle.verticalTextAlignment = UIControlContentVerticalAlignmentCenter;
        placeholderTitle.textAlignment = NSTextAlignmentCenter;
        placeholderTitle.numberOfLines = 5;
        placeholderTitle.font = [UIFont fontWithName:@"Nunito-Black" size:30];
        placeholderTitle.textColor = self.textcolor;
        placeholderTitle.text = nil;
        placeholderTitle.alpha = 1.0;
        placeholderTitle.backgroundColor = [UIColor clearColor];
        placeholderTitle.userInteractionEnabled = false;
        [self addSubview:placeholderTitle];
        
        placeholderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(placeholderGesture:)];
        placeholderGesture.numberOfTapsRequired = 1;
        placeholderGesture.enabled = self.gesture;
        [self addGestureRecognizer:placeholderGesture];
        
        placeholderProgressBackdrop = [[UCZProgressView alloc] initWithFrame:CGRectMake((self.bounds.size.width / 2) - 25.0, (self.bounds.size.height / 2) - 25.0, 50.0, 50.0)];
        placeholderProgressBackdrop.radius = 40.0;
        placeholderProgressBackdrop.alpha = 0.0;
        placeholderProgressBackdrop.transform = CGAffineTransformMakeScale(1.0, 1.0);
        placeholderProgressBackdrop.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        placeholderProgressBackdrop.tintColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        placeholderProgressBackdrop.progress = 1.0;
        [self addSubview:placeholderProgressBackdrop];

        placeholderProgress = [[UCZProgressView alloc] initWithFrame:placeholderProgressBackdrop.frame];
        placeholderProgress.showsText = false;
        placeholderProgress.backgroundColor = [UIColor clearColor];
        placeholderProgress.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        placeholderProgress.indeterminate = self.spinner;
        placeholderProgress.radius = placeholderProgressBackdrop.radius;
        placeholderProgress.alpha = 0.0;
        placeholderProgress.tintColor = [UIColor colorWithWhite:1.0 alpha:0.9];
        placeholderProgress.transform = placeholderProgressBackdrop.transform;
        [self addSubview:placeholderProgress];
        
    }
    
}

-(void)placeholderUpdateColor:(UIColor *)color animate:(BOOL)animate {
    [UIView animateWithDuration:animate?0.4:0.0 delay:animate?0.0:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setTextcolor:color];
        [placeholderTitle setTextColor:self.textcolor];
        
    } completion:nil];
    
}

-(void)placeholderUpdateTitle:(NSString *)title instructions:(NSString *)instructions {
    self.text = title!=nil?title:@"";
    self.instructions = instructions!=nil?instructions:@"";

    dispatch_async(dispatch_get_main_queue(), ^{
        if (![placeholderTitle.attributedText isEqual:[self format:title subtitle:instructions]]) {
            [placeholderTitle setAttributedText:[self format:title subtitle:instructions]];

        }
        else {
            [placeholderTitle setAttributedText:[self format:title subtitle:instructions]];
            
        }
        
        [placeholderTitle setFrame:CGRectMake(15.0, 20.0, self.bounds.size.width - 30.0, self.bounds.size.height - 40.0)];
        [self placeholderLoading:0];
        
    });
    

}

-(void)placeholderUpdateImage:(UIImage *)image animate:(BOOL)animate {
    if (image) {
        [UIView transitionWithView:self duration:animate?0.5:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [placeholderImage setImage:image];
            
        } completion:nil];
        
    }
    
}

-(void)placeholderResizeFrame {
    [placeholderTitle setFrame:CGRectMake(15.0, 20.0, self.bounds.size.width - 30.0, self.bounds.size.height - 40.0)];
    [placeholderImage setFrame:CGRectMake(placeholderContainer.center.x - 70.0, placeholderContainer.center.y - 70.0, 140.0,  140.0)];
    
}

-(void)placeholderLoading:(double)progress {
    CGRect titleframe = placeholderTitle.frame;
    if (progress > 0) titleframe.origin.y += 20.0;
    else titleframe.origin.y = 20.0;
    [UIView animateWithDuration:0.2 animations:^{
        if (progress > 0) {
            [placeholderTitle setFrame:titleframe];
            [placeholderTitle setAlpha:0.0];
        
        }
        else {
            [placeholderProgress setAlpha:0.0];
            [placeholderProgress setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
            [placeholderProgressBackdrop setAlpha:0.0];
            [placeholderProgressBackdrop setTransform:CGAffineTransformMakeScale(0.9, 0.9)];

        }
    
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            if (progress > 0) {
                [placeholderProgress setAlpha:1.0];
                [placeholderProgress setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                [placeholderProgressBackdrop setAlpha:1.0];
                [placeholderProgressBackdrop setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                
            }
            else {
                [placeholderTitle setFrame:titleframe];
                [placeholderTitle setAlpha:1.0];
                
            }
            
        } completion:nil];
        
    }];
    
    if (progress && self.spinner == false) [placeholderProgress setProgress:progress animated:true];
    
}

-(void)placeholderGesture:(UITapGestureRecognizer *)gesture {
    placeholderAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    placeholderAnimation.duration = 0.1;
    placeholderAnimation.toValue = [NSNumber numberWithFloat:1.05];
    placeholderAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    placeholderAnimation.autoreverses = true;
    placeholderAnimation.repeatCount = 1;

    if ([self.delegate respondsToSelector:@selector(viewContentRefresh:)]) {
        [self.delegate viewContentRefresh:nil];

    }
    
}

-(NSAttributedString *)format:(NSString *)title subtitle:(NSString *)subtitle {
    NSString *text;
    if (subtitle) text = [NSString stringWithFormat:@"%@\n%@" ,title, subtitle];
    else text = title.uppercaseString;
    
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:text];
    if (subtitle) {
        [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Nunito-Regular" size:12.0] range:NSMakeRange(title.length + 1, subtitle.length)];
        [formatted addAttribute:NSForegroundColorAttributeName value:[self.textcolor colorWithAlphaComponent:0.6] range:NSMakeRange(title.length + 1, subtitle.length)];
        
    }
    
    return formatted;
    
}

@end
