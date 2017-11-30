//
//  SHSegmentControl.m
//  Shwifty
//
//  Created by Joe Barbour on 22/09/2017.
//  Copyright © 2017 NorthernSpark. All rights reserved.
//

#import "BSegmentControl.h"
#import "BConstants.h"

@implementation BSegmentControl

-(void)drawRect:(CGRect)rect {    
    if (!self.font) self.font = [UIFont fontWithName:@"Avenir-Light" size:16];
    if (!self.fontselected) self.fontselected = [UIFont fontWithName:@"Avenir-Heavy" size:16];
    if (!self.background) self.background = [UIColor clearColor];
    if (!self.textcolor) self.textcolor = [UIColor whiteColor];
    if (!self.selecedtextcolor) self.selecedtextcolor = [UIColor redColor];
    if (self.padding == 0) self.padding = 50.0;
    if (self.index > self.buttons.count) self.index = 0;

    if (![self.subviews containsObject:container]) {
        self.backgroundColor = self.background;

        container = [[UIView alloc] initWithFrame:self.bounds];
        container.backgroundColor = [self.background colorWithAlphaComponent:0.1];
        [self addSubview:container];
        
        effect = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        effect.frame = container.bounds;
        effect.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [container addSubview:effect];
        
        if (self.type == BSegmentTypeUnderline) {
            underline = [[UIView alloc] initWithFrame:CGRectMake(5.0, container.bounds.size.height - 2.0, self.bounds.size.width / self.buttons.count - 10.0, 2.0)];
            underline.backgroundColor = [UIColor clearColor];
            underline.clipsToBounds = true;
            [container addSubview:underline];
            
        }
        else {
            rectangle = [[UIView alloc] initWithFrame:CGRectMake(5.0, 5.0, (self.bounds.size.width / self.buttons.count) - 10.0, container.bounds.size.height - 10.0)];
            rectangle.backgroundColor = self.selecedtextcolor;
            rectangle.clipsToBounds = true;
            rectangle.layer.cornerRadius = self.layer.cornerRadius - 5.0;
            rectangle.alpha = 1.0;
            [container addSubview:rectangle];
            
        }
        
        gradient = [CAGradientLayer layer];
        gradient.frame = self.type==BSegmentTypeUnderline?underline.bounds:rectangle.bounds;
        gradient.colors = @[(id)UIColorFromRGB(0x16D1BD).CGColor, (id)UIColorFromRGB(0x27CAE1).CGColor];
        gradient.startPoint = CGPointMake(0.0, 0.0);
        gradient.endPoint = CGPointMake(0.0, 1.0);
        [self.type==BSegmentTypeUnderline?underline.layer:rectangle.layer addSublayer:gradient];
        
        for (int i = 0;i < self.buttons.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(((self.bounds.size.width / self.buttons.count) * i) + 5.0, 2.0, (self.bounds.size.width / self.buttons.count) - 10.0, self.bounds.size.height - 4.0)];
            button.backgroundColor = [UIColor clearColor];
            button.tag = i;
            [button setClipsToBounds:true];
            [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
            [container addSubview:button];
            
        }
        
    }
    
    for (UIView *action in container.subviews) {
        if ([action isKindOfClass:[UIButton class]]) {
            [self selected:(UIButton *)action];
            break;
            
        }
        
    }
    
    [container setFrame:self.bounds];

}

-(CGSize)buttonsize:(NSString *)label {
    CGRect rect;
    if (label != nil) rect = [label boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
    else rect = CGRectZero;
        
    return CGSizeMake(rect.size.width + self.padding, self.bounds.size.height);
    
}

-(void)selected:(UIButton *)button {
    [UIView animateWithDuration:0.7 delay:0.05 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [rectangle setFrame:CGRectMake(button.frame.origin.x, rectangle.frame.origin.y, rectangle.bounds.size.width, rectangle.bounds.size.height)];
        [underline setFrame:CGRectMake(button.frame.origin.x, underline.frame.origin.y, underline.bounds.size.width, underline.bounds.size.height)];

    } completion:nil];
    
    for (UIView *action in container.subviews) {
        if ([action isKindOfClass:[UIButton class]]) {
            NSString *image = [NSString stringWithFormat:@"%@%@" ,[self.buttons objectAtIndex:action.tag] ,button.tag==action.tag?@"_selected":@""];
            [(UIButton *)action setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
            
        }
        
    }
    
    [self.delegate segmentViewWasTapped:self index:button.tag];

}

@end
