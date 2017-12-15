//
//  BNavigationView.h
//  Blrrd
//
//  Created by Joe Barbour on 17/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BNavigationDelegate;
@interface BNavigationView : UIView {
    UILabel *label;
    UIView *underline;
    CAGradientLayer *gradient;
    UIButton *back;
    UIButton *action;

}

@property (nonatomic, strong) id <BNavigationDelegate> delegate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id rightbutton;

-(void)navigationTitle:(NSString *)title;
-(void)navigationRightButton:(id)buton;

@end

@protocol BNavigationDelegate <NSObject>

@optional

-(void)viewNavigationButtonTapped:(UIButton *)button;

@end

