//
//  GDPlaceholderView.h
//  Grado
//
//  Created by Joe Barbour on 17/12/2015.
//  Copyright © 2015 NorthernSpark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMLabel.h"

@protocol GDPlaceholderDelegate;
@interface GDPlaceholderView : UIView {
    CABasicAnimation *placeholderAnimation;
    SAMLabel *placeholderTitle;
    UIImageView *placeholderImage;
    UIView *placeholderContainer;
    UITapGestureRecognizer *placeholderGesture;
    
}

@property (nonatomic, strong) id <GDPlaceholderDelegate> delegate;
@property (nonatomic ,strong) NSString *text;
@property (nonatomic ,strong) NSString *instructions;
@property (nonatomic) BOOL gesture;
@property (nonatomic, strong) UIColor *textcolor;
@property (nonatomic, strong) NSString *key;

-(void)placeholderUpdateTitle:(NSString *)title instructions:(NSString *)instructions;
-(void)placeholderLoading:(BOOL)loading;
-(void)placeholderUpdateImage:(UIImage *)image animate:(BOOL)animate;
-(void)placeholderResizeFrame;
-(void)placeholderUpdateColor:(UIColor *)color animate:(BOOL)animate;

@end

@protocol GDPlaceholderDelegate <NSObject>

@optional

-(void)viewContentRefresh:(UIRefreshControl *)refresh;

@end

