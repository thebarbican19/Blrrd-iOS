//
//  ContentPicker.m
//  Cas Consultancy iOS6
//
//  Created by Joe Barbour on 30/09/2014.
//  Copyright (c) 2014 NorthernSpark. All rights reserved.
//

#import "GDActionSheet.h"
#import "BConstants.h"

@implementation GDActionSheet

#define MAIN_MODAL_RADIUS 8.0
#define MAIN_MODAL_HEADER 90.0
#define MAIN_MODAL_PADDING 12.0

-(void)presentActionAlert {
    if (!self.viewColour) self.viewColour = [UIColor whiteColor];
    if (!self.textColour) self.textColour = [UIColor whiteColor];
    if (!self.textFont) self.textFont = [UIFont fontWithName:@"Nunito-Black" size:13.0];
    if (!self.buttonHeight) self.buttonHeight = 50;
    if (!self.cancelColour) self.cancelColour = [UIColor whiteColor];
    if (!self.cancelText) self.cancelText = NSLocalizedString(@"ActionSheetTitleCancel", nil);
    
    if (IS_IPHONE_X) {
        self.safearea = [UIApplication sharedApplication].keyWindow.window.safeAreaInsets.bottom + APP_STATUSBAR_HEIGHT;
        
    }

    self.buttonHeight = 60;
    self.height = (int)self.buttons.count + 1;
    
    self.mainBackground = [[UIView alloc] initWithFrame:self.bounds];
    self.mainBackground.backgroundColor = [UIColor clearColor];
    
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height, self.bounds.size.width, (self.buttonHeight * self.height) + 100.0)];
    self.mainView.backgroundColor = [UIColor clearColor];
    self.mainView.alpha = 0.0;
    self.mainView.layer.cornerRadius = 3.0;
    self.mainView.layer.masksToBounds = true;
    self.mainView.layer.shadowOffset = CGSizeMake(0.0, 0.5);
    self.mainView.layer.shadowRadius = 2.5;
    self.mainView.layer.shadowOpacity = 0.3;
    
    self.mainGradient = [CAGradientLayer layer];
    self.mainGradient.frame = self.mainBackground.bounds;
    self.mainGradient.colors = @[(id)[UIColorFromRGB(0x140F26) colorWithAlphaComponent:0.2].CGColor, (id)[UIColorFromRGB(0x140F26) colorWithAlphaComponent:0.9].CGColor];
    self.mainGradient.startPoint = CGPointMake(0.0, -0.2);
    self.mainGradient.endPoint = CGPointMake(0.0, 1.0);
    [self.mainBackground.layer addSublayer:self.mainGradient];
    
    self.mainHairline = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.mainHeader.bounds.size.height - 0.5, self.mainView.bounds.size.width, 0.5)];
    self.mainHairline.backgroundColor = [UIColor purpleColor];
    self.mainHairline.hidden = self.header?false:true;
    [self.mainView addSubview:self.mainHairline];
    
    [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
    [[UIApplication sharedApplication].delegate.window addSubview:self.mainBackground];
    [[UIApplication sharedApplication].delegate.window addSubview:self.mainView];

    self.mainGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalWindow:)];
    self.mainGesture.delegate = self;
    [self.mainBackground addGestureRecognizer:self.mainGesture];
    
    for (UIView *subview in self.mainView.subviews) {
        [subview removeFromSuperview];
        
    }
    
    if (self.buttons.count > 0) {
        for (int i = 0;i < self.buttons.count; i++) {
            UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(
                                    MAIN_MODAL_PADDING,
                                    MAIN_MODAL_PADDING + (self.buttonHeight * i) + 20.0,
                                    self.mainView.bounds.size.width - (MAIN_MODAL_PADDING * 2),
                                    self.buttonHeight - 10.0)];
            actionButton.backgroundColor = [UIColor greenColor];
            actionButton.tag = i;
            actionButton.titleLabel.font = self.textFont;
            actionButton.tag = i;
            actionButton.alpha = 0.0;
            actionButton.layer.cornerRadius = MAIN_MODAL_RADIUS;
            actionButton.layer.masksToBounds = true;
            actionButton.layer.shadowOffset = CGSizeMake(0.0, 0.5);
            actionButton.layer.shadowRadius = 2.5;
            actionButton.layer.shadowOpacity = 0.3;
            actionButton.backgroundColor = self.warningAction?UIColorFromRGB(0x69DCCB):UIColorFromRGB(0x69DCCB);
            [actionButton setTitleColor:self.warningAction?[UIColor whiteColor]:self.textColour forState:UIControlStateNormal];
            [actionButton setTitle:[[[self.buttons objectAtIndex:i] objectForKey:@"title"] uppercaseString] forState:UIControlStateNormal];
            [actionButton addTarget:self action:@selector(buttonTappedWithIndex:)forControlEvents:UIControlEventTouchDown];
            [self.mainView addSubview:actionButton];
            
        }
        
    }
    
    UIButton *dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_MODAL_PADDING,
                                                                         MAIN_MODAL_PADDING + (self.buttonHeight * self.buttons.count) + 20.0,
                                                                         self.bounds.size.width - (MAIN_MODAL_PADDING * 2),
                                                                         self.buttonHeight - 10.0)];
    dismissButton.titleLabel.font = self.textFont;
    dismissButton.backgroundColor = self.warningAction?[UIColor whiteColor]:UIColorFromRGB(0xFFFFFF);
    dismissButton.alpha = 0.0;
    dismissButton.layer.cornerRadius = MAIN_MODAL_RADIUS;
    dismissButton.layer.masksToBounds = true;
    dismissButton.layer.shadowOffset = CGSizeMake(0.0, 0.5);
    dismissButton.layer.shadowRadius = 2.5;
    dismissButton.tag = 99;
    dismissButton.layer.shadowOpacity = 0.3;
    [dismissButton setTitleColor:self.warningAction?UIColorFromRGB(0x140F26):UIColorFromRGB(0x140F26) forState:UIControlStateNormal];
    [dismissButton setTitle:self.cancelText.uppercaseString forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissModalWindow:)forControlEvents:UIControlEventTouchDown];
    [self.mainView addSubview:dismissButton];

    mainFrame = self.mainView.frame;
    mainFrame.origin.y = self.bounds.size.height - ((self.buttonHeight * self.height) + (self.safearea + MAIN_MODAL_PADDING));
    [UIView animateWithDuration:0.3 animations:^{
        self.mainBackground.backgroundColor = [UIColor clearColor];
        self.mainView.alpha = 1.0;
        self.mainView.frame = mainFrame;
        
    } completion:nil];
    
    for (UIView *action in self.mainView.subviews) {
        if ([action isKindOfClass:[UIButton class]]) {
            if (action.tag == 99) {
                [UIView animateWithDuration:UIAccessibilityIsReduceMotionEnabled()?0.0:0.2 delay:(self.buttons.count * 0.08) options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
                    [action setAlpha:1.0];
                    [action setFrame:CGRectMake(MAIN_MODAL_PADDING,
                                                MAIN_MODAL_PADDING + (self.buttonHeight * self.buttons.count),
                                                self.bounds.size.width - (MAIN_MODAL_PADDING * 2),
                                                self.buttonHeight - 10.0)];
                    
                } completion:nil];
                
            }
            else {
                [UIView animateWithDuration:UIAccessibilityIsReduceMotionEnabled()?0.0:0.2 delay:(action.tag * 0.08) options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
                    [action setAlpha:1.0];
                    [action setFrame:CGRectMake(MAIN_MODAL_PADDING,
                                                MAIN_MODAL_PADDING + (self.buttonHeight * action.tag),
                                                self.mainView.bounds.size.width - (MAIN_MODAL_PADDING * 2),
                                                self.buttonHeight - 10.0)];
                    
                } completion:nil];
                
            }
            
        }
        
    }
    
    if (self.presentAction) [self.delegate actionSheetWasPresented:true];
    
}

-(void)buttonTappedWithIndex:(UIButton *)button {
    mainFrame = self.mainView.frame;
    mainFrame.size.height = (self.buttonHeight * self.height) + 100.0;
    mainFrame.origin.y = self.bounds.size.height;

    [UIView animateWithDuration:UIAccessibilityIsReduceMotionEnabled()?0.0:0.15 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.mainBackground setBackgroundColor:[UIColor clearColor]];
        [self.mainView setAlpha:0.0];
        [self.mainView setFrame:mainFrame];

    } completion:^(BOOL finished){
        [self.mainView removeFromSuperview];
        [self.mainBackground removeFromSuperview];
        [self removeFromSuperview];
        [self.delegate actionSheetTappedButton:self index:button.tag];

    }];
    
    if (self.presentAction) [self.delegate actionSheetWasPresented:false];

}

-(void)dismissModalWindow:(UIButton *)button {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
    
    [UIView animateWithDuration:UIAccessibilityIsReduceMotionEnabled()?0.0:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.mainBackground setBackgroundColor:[UIColor clearColor]];
        [self.mainView setAlpha:0.0];
        [self.mainView setFrame:CGRectMake(0.0, self.bounds.size.height, self.bounds.size.width, self.buttonHeight * self.height)];
        
    } completion:^(BOOL finished){
        [self.mainBackground removeFromSuperview];
        [self.mainView removeFromSuperview];
        [self removeFromSuperview];
        
        if (self.cancelAction) [self.delegate actionSheetTappedButton:self index:99];
        
    }];
    
    if (self.presentAction) [self.delegate actionSheetWasPresented:false];
    
}

@end
