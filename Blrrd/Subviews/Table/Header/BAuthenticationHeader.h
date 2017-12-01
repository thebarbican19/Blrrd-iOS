//
//  BAuthenticationHeader.h
//  Blrrd
//
//  Created by Joe Barbour on 01/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BAuthenticationHeaderDelegate;
@interface BAuthenticationHeader : UIView {
    CAGradientLayer *gradient;
    UIImageView *logo;
    UIView *container;
    UIButton *signupaction;
    UIButton *loginaction;
    UIImageView *arrow;

}

@property (nonatomic, strong) id <BAuthenticationHeaderDelegate> delegate;

-(void)resize;

@end

@protocol BAuthenticationHeaderDelegate <NSObject>

@optional

-(void)viewShowLoginForm;
-(void)viewShowSignupForm;

@end

