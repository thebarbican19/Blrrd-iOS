//
//  VDSearchView.h
//  Video Downloader
//
//  Created by Joe Barbour on 09/04/2015.
//  Copyright (c) 2015 NorthernSpark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLMultiColorLoader.h"

@protocol BSearchViewDelegate;
@interface BSearchView : UIView <UITextFieldDelegate> {
    UIButton *searchRightButton;
    
}

@property (nonatomic, strong) id <BSearchViewDelegate> delegate;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) BOOL loaderRequired;
@property (nonatomic) BOOL refreshRequired;
@property (nonatomic) UIKeyboardType keyboard;
@property (nonatomic) bool shouldUpdate;
@property (nonatomic, strong) UITextField *search;
@property (nonatomic, strong) BLMultiColorLoader *loader;

-(void)dismiss;
-(void)present;

@end

@protocol BSearchViewDelegate <NSObject>

@optional

-(void)searchFieldWasPresented:(CGSize)keyboard;
-(void)searchFieldWasUpdated:(NSString *)query;
-(void)searchFieldWasDismissed;
-(void)searchFieldDidRefreshContent;
-(void)searchFieldReturnKeyPressed;

@end
