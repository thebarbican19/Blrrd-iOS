//
//  BTabbarView.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BTabbarViewThemeDefault,
    BTabbarViewThemeTransparent
    
} BTabbarViewTheme;

@protocol BTabbarDelegate;
@interface BTabbarView : UIView {
    UIView *frame;
    UIView *container;
    UIView *hairline;

}

@property (nonatomic, strong) id <BTabbarDelegate> delegate;
@property (nonatomic, strong) NSArray *buttons;

-(void)viewUpdateWithTheme:(BTabbarViewTheme)theme;

@end

@protocol BTabbarDelegate <NSObject>

@optional

-(void)viewPresentSubviewWithIndex:(int)index animated:(BOOL)animated;

@end
