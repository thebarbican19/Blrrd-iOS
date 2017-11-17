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
            image.contentMode = UIViewContentModeCenter;
            [container addSubview:image];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x, button.bounds.size.height - 14.0, button.bounds.size.width, 9.0)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [[[self.buttons objectAtIndex:i] objectForKey:@"text"] uppercaseString];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"Nunito-ExtraBold" size:8];
            [container addSubview:label];

        }
        
    }
    
}

-(void)selected:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(viewPresentSubviewWithIndex:animated:)]) {
        [self.delegate viewPresentSubviewWithIndex:(int)button.tag animated:true];
        
    }
    
}

@end
