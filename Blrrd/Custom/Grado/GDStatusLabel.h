//
//  LKStatusLabel.h
//  Lynker
//
//  Created by Joe Barbour on 20/07/2015.
//  Copyright (c) 2015 Lynker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMLabel.h"

@interface GDStatusLabel : UILabel {
    SAMLabel *statusLabel;
    UIActivityIndicatorView *statusLoader;
    CGRect statusFrame;
    CGSize statusSize;
    BOOL statusAnimating;
    CAGradientLayer *statusGradient;
    
}

-(void)setText:(id)text animate:(BOOL)animate;
-(void)setStatusColour:(UIColor *)colour animate:(BOOL)animate;

@property (nonatomic, strong) UIColor *colour;
@property (nonatomic, strong) UIFont *fount;
@property (nonatomic, strong) id content;
@property (nonatomic, assign) NSTextAlignment alignment;

@end
