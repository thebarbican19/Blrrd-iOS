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
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 2.0, self.bounds.size.width - 60.0, self.bounds.size.height - 6.0)];
        label.font = [UIFont fontWithName:@"Nunito-Black" size:18];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Channel";
        [self addSubview:label];
        
        underline = [[UIView alloc] initWithFrame:CGRectMake(label.center.x - 10.0, self.bounds.size.height - 15.0, 20.0, 3.0)];
        underline.backgroundColor = UIColorFromRGB(0x69DCCB);
        underline.clipsToBounds = true;
        underline.layer.cornerRadius = 2;
        [self addSubview:underline];
        
        back =  [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.height, self.bounds.size.height)];
        back.tag = 0;
        back.backgroundColor = [UIColor clearColor];
        [back setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [back addTarget:self.delegate action:@selector(viewNavigationButtonTapped:)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:back];
        
    }
    
}

-(void)navigationTitle:(NSString *)title {
    label.text = title;
    label.backgroundColor = [UIColor purpleColor];

}

@end
