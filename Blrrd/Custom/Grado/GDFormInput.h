//
//  GDFormInput.h
//  Grado Local
//
//  Created by Joe Barbour on 11/08/2017.
//  Copyright © 2017 Grado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDStatusLabel.h"

typedef NS_ENUM(NSInteger, GDFormInputType) {
    GDFormInputTypePassword,
    GDFormInputTypePasswordReenter,
    GDFormInputTypeUsername,
    GDFormInputTypeEmail
    
};

@protocol GDFormInputDelegate;
@interface GDFormInput : UIView <UITextFieldDelegate> {
    CGRect keyboard;
    
}

@property (nonatomic, strong) id <GDFormInputDelegate> delegate;
@property (nonatomic) GDFormInputType type;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic) BOOL login;
@property (nonatomic) BOOL validated;
@property (nonatomic) NSString *entry;

@property (nonatomic, strong) GDStatusLabel *formLabel;
@property (nonatomic, strong) UITextField *formInput;
@property (nonatomic, strong) UIView *formContainer;

-(void)textFeildValidateCheck;
-(void)textFeildBecomeFirstResponder:(NSDictionary *)data;
-(void)textFeildSetTitle:(NSString *)title;

@end

@protocol GDFormInputDelegate <NSObject>

@optional

-(void)formPresentedKeyboard:(float)height;
-(void)formDismissedKeyboard;
-(void)formKeyboardReturnPressed;

@end

