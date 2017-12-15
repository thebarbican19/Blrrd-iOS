//
//  BNavigationView.m
//  Blrrd
//
//  Created by Joe Barbour on 17/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BNavigationView.h"
#import "BConstants.h"

@implementation BNavigationView

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:label]) {
        gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = @[(id)[UIColorFromRGB(0x140F26) colorWithAlphaComponent:1.0].CGColor, (id)[UIColorFromRGB(0x140F26) colorWithAlphaComponent:0.8].CGColor];
        gradient.startPoint = CGPointMake(0.0, 0.0);
        gradient.endPoint = CGPointMake(0.0, 1.0);
        [self.layer addSublayer:gradient];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 2.0, self.bounds.size.width - 180.0, self.bounds.size.height - 6.0)];
        label.font = [UIFont fontWithName:@"Nunito-Black" size:18];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = nil;
        label.alpha = 0.0;
        label.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [self addSubview:label];
        
        underline = [[UIView alloc] initWithFrame:CGRectMake(label.center.x - 10.0, self.bounds.size.height - 10.0, 20.0, 3.0)];
        underline.backgroundColor = UIColorFromRGB(0x69DCCB);
        underline.clipsToBounds = true;
        underline.layer.cornerRadius = 2;
        underline.alpha = 0.0;
        [self addSubview:underline];
        
        back =  [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.height, self.bounds.size.height)];
        back.tag = 0;
        back.backgroundColor = [UIColor clearColor];
        [back setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [back addTarget:self.delegate action:@selector(viewNavigationButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:back];
        
        action = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - 90.0, 0.0, 80.0, self.bounds.size.height)];
        action.tag = 1;
        action.backgroundColor = [UIColor clearColor];
        action.alpha = self.rightbutton==nil?0.0:1.0;
        [action.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:10]];
        [action setTitleColor:UIColorFromRGB(0x69DCCB) forState:UIControlStateNormal];
        if ([self.rightbutton isKindOfClass:[NSString class]]) {
            [action setTitle:[(NSString *)self.rightbutton uppercaseString] forState:UIControlStateNormal];
            
        }
        else if ([self.rightbutton isKindOfClass:[UIImage class]]) {
            [action setImage:self.rightbutton forState:UIControlStateNormal];
            
        }
        [action addTarget:self.delegate action:@selector(viewNavigationButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:action];
    
    }
    
}

-(void)navigationTitle:(NSString *)title {
    if (![label.text isEqualToString:title]) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [label setAlpha:0.0];
            [label setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
            
        } completion:^(BOOL finished) {
            [label setText:title];
            [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [label setAlpha:1.0];
                [label setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                
            } completion:nil];
            
        }];
   
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [underline setFrame:CGRectMake(label.center.x - 10.0, self.bounds.size.height - 10.0, 20.0, 3.0)];
            [underline setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [underline setFrame:CGRectMake(label.center.x - 10.0, self.bounds.size.height - 15.0, 20.0, 3.0)];
                [underline setAlpha:1.0];
                
            } completion:nil];
            
        }];
        
    }
    
}

-(void)navigationRightButton:(NSString *)buton {
    if (buton == nil) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [action setAlpha:0.0];
            [action setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
            
        } completion:nil];
        
    }
    else {
        [self setRightbutton:buton];
        if ([self.rightbutton isKindOfClass:[NSString class]]) {
            [action setTitle:[(NSString *)self.rightbutton uppercaseString] forState:UIControlStateNormal];
            
        }
        else if ([self.rightbutton isKindOfClass:[UIImage class]]) {
            [action setImage:self.rightbutton forState:UIControlStateNormal];
            
        }
        
    }
    
}

@end
