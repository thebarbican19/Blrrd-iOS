//
//  SHSegmentControl.h
//  Shwifty
//
//  Created by Joe Barbour on 22/09/2017.
//  Copyright © 2017 NorthernSpark. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BSegmentType) {
    BSegmentTypeUnderline,
    BSegmentTypeBox
    
};

@protocol BSegmentDelegate;
@interface BSegmentControl : UIView {
    UIView *underline;
    UIView *rectangle;
    UIView *container;
    CAGradientLayer *gradient;
    UIVisualEffectView *effect;

}

@property (nonatomic, strong) id <BSegmentDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *fontselected;
@property (nonatomic, assign) float padding;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) UIColor *background;
@property (nonatomic, strong) UIColor *textcolor;
@property (nonatomic, strong) UIColor *selecedtextcolor;
@property (nonatomic, assign) BSegmentType type;
@property (nonatomic, assign) BOOL scrolling;

@end

@protocol BSegmentDelegate <NSObject>

@optional

-(void)segmentViewWasTapped:(BSegmentControl *)segment index:(NSUInteger)index;

@end
