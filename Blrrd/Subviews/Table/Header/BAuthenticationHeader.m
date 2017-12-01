//
//  BAuthenticationHeader.m
//  Blrrd
//
//  Created by Joe Barbour on 01/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BAuthenticationHeader.h"
#import "BConstants.h"

@implementation BAuthenticationHeader

-(void)drawRect:(CGRect)rect {
    gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - 12.0);
    gradient.colors = @[(id)UIColorFromRGB(0x16D1BD).CGColor,
                        (id)UIColorFromRGB(0x27CAE1).CGColor];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(0.0, 1.0);
    [self.layer addSublayer:gradient];
    [self setBackgroundColor:[UIColor clearColor]];
    
    logo = [[UIImageView alloc] initWithFrame:CGRectMake((self.bounds.size.width / 2) - 70.0, (self.bounds.size.height / 2) - 84.0, 140.0, 140)];
    logo.contentMode = UIViewContentModeCenter;
    logo.backgroundColor = [UIColor clearColor];
    logo.image = [UIImage imageNamed:@"auth_logo"];
    [self addSubview:logo];

    container = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height - 60.0, self.bounds.size.width, 50.0)];
    container.backgroundColor = [UIColor clearColor];
    [self addSubview:container];
    
    arrow = [[UIImageView alloc] initWithFrame:CGRectMake((container.bounds.size.width / 2) * 0, container.bounds.size.height - 6.0, container.bounds.size.width / 2, container.bounds.size.height - 10.0)];
    arrow.contentMode = UIViewContentModeTop;
    arrow.image = [UIImage imageNamed:@"auth_segment_arrow"];
    [container addSubview:arrow];

    signupaction = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, container.bounds.size.width / 2, container.bounds.size.height - 10.0)];
    signupaction.backgroundColor = [UIColor clearColor];
    [signupaction setTag:1];
    [signupaction.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:12]];
    [signupaction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signupaction setTitle:NSLocalizedString(@"Authentication_SignupButton_Title", nil) forState:UIControlStateNormal];
    [signupaction addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:signupaction];
    
    loginaction = [[UIButton alloc] initWithFrame:CGRectMake((container.bounds.size.width / 2) * 1, 0.0, container.bounds.size.width / 2, container.bounds.size.height - 10.0)];
    loginaction.backgroundColor = [UIColor clearColor];
    [loginaction.titleLabel setFont:[UIFont fontWithName:@"Nunito-Black" size:12]];
    [loginaction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginaction setTag:2];
    [loginaction setTitle:NSLocalizedString(@"Authentication_LoginButton_Title", nil) forState:UIControlStateNormal];
    [loginaction addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:loginaction];

}

-(void)action:(UIButton *)button {
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [arrow setFrame:CGRectMake(button.frame.origin.x, container.bounds.size.height - 6.0, container.bounds.size.width / 2, container.bounds.size.height - 10.0)];

    } completion:nil];
    
    if (button.tag == 1) {
        if ([self.delegate respondsToSelector:@selector(viewShowSignupForm)]) {
            [self.delegate viewShowSignupForm];
            
        }
        
    }
    else {
        if ([self.delegate respondsToSelector:@selector(viewShowLoginForm)]) {
            [self.delegate viewShowLoginForm];
            
        }
    }

}

-(void)resize {
    if (self.bounds.size.height < 220.0) {
        [logo setTransform:CGAffineTransformMakeScale(0.3, 0.3)];

    }
    else {
        [logo setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

    }
    
    [logo setFrame:CGRectMake((self.bounds.size.width / 2) - 70.0, (self.bounds.size.height / 2) - 84.0, 140.0, 140)];
    [gradient setFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - 12.0)];
    [container setFrame:CGRectMake(0.0, self.bounds.size.height - 60.0, self.bounds.size.width, 50.0)];

}

@end
