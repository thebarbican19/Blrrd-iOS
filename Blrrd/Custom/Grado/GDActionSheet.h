//
//  ContentPicker.h
//  Cas Consultancy iOS6
//
//  Created by Joe Barbour on 30/09/2014.
//  Copyright (c) 2014 NorthernSpark. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GDActionSheetDelegate;
@interface GDActionSheet : UIView <UIGestureRecognizerDelegate> {
    CGRect mainFrame;
}

@property (nonatomic, strong) id <GDActionSheetDelegate> delegate;
@property (nonatomic) UIView *mainView;
@property (nonatomic) UIView *mainBackground;
@property (nonatomic) UILabel *mainHeader;
@property (nonatomic) UIView *mainHairline;
@property (nonatomic) CAGradientLayer *mainGradient;
@property (nonatomic) UITapGestureRecognizer *mainGesture;

@property (nonatomic) NSString *header;
@property (nonatomic) NSArray *buttons;
@property (nonatomic) NSString *key;
@property (nonatomic) int height;
@property (nonatomic) int buttonHeight;
@property (nonatomic) NSIndexPath *indexPath;
@property (nonatomic ,strong) UIColor *textColour;
@property (nonatomic ,strong) UIFont *textFont;
@property (nonatomic ,strong) UIColor *viewColour;
@property (nonatomic ,strong) UIColor *cancelColour;
@property (nonatomic ,strong) NSString *cancelText;
@property (nonatomic) BOOL cancelAction;
@property (nonatomic) BOOL presentAction;
@property (nonatomic) BOOL warningAction;
@property (nonatomic ,strong) NSString *data;
@property (nonatomic) float safearea;

-(void)presentActionAlert;
-(void)dismissModalWindow:(UIButton *)button;

@end

@protocol GDActionSheetDelegate <NSObject>

@optional

-(void)actionSheetTappedButton:(GDActionSheet *)action index:(NSInteger)index;
-(void)actionSheetWasPresented:(BOOL)visible;

@end
