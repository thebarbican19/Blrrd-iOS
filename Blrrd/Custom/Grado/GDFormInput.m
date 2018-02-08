//
//  GDFormInput.m
//  Grado Local
//
//  Created by Joe Barbour on 11/08/2017.
//  Copyright © 2017 Grado. All rights reserved.
//

#import "GDFormInput.h"
#import "BConstants.h"

@implementation GDFormInput

-(void)drawRect:(CGRect)rect {
    self.formContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
    self.formContainer.backgroundColor = [UIColor clearColor];
    self.formContainer.clipsToBounds = true;
    [self addSubview:self.formContainer];
    
    self.formLabel = [[GDStatusLabel alloc] initWithFrame:CGRectMake(35.0, self.formContainer.center.y - 140.0, self.bounds.size.width - 70.0, 55.0)];
    self.formLabel.fount = [UIFont fontWithName:@"Nunito-SemiBold" size:14.0];
    self.formLabel.content = nil;
    self.formLabel.colour = UIColorFromRGB(0x69DCCB);
    self.formLabel.backgroundColor = [UIColor clearColor];
    [self.formContainer addSubview:self.formLabel];
    
    self.formInput = [[UITextField alloc] initWithFrame:CGRectMake(35.0, self.formContainer.center.y - 90.0, self.formContainer.bounds.size.width - 70.0, 50.0)];
    self.formInput.textAlignment = NSTextAlignmentLeft;
    self.formInput.textColor = [UIColor whiteColor];
    self.formInput.delegate = self;
    self.formInput.text = self.entry;
    self.formInput.keyboardAppearance = UIKeyboardAppearanceDark;
    self.formInput.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.formInput.autocorrectionType = UITextAutocorrectionTypeNo;
    self.formInput.font =  [UIFont fontWithName:@"Nunito-Light" size:30.0];
    self.formInput.returnKeyType = UIReturnKeyNext;
    if (self.type == GDFormInputTypeEmail) self.formInput.keyboardType = UIKeyboardTypeEmailAddress;
    else if (self.type == GDFormInputTypeUsername) self.formInput.keyboardType = UIKeyboardTypeAlphabet;
    else if (self.type == GDFormInputTypePhone) self.formInput.keyboardType = UIKeyboardTypePhonePad;
    else self.formInput.keyboardType = UIKeyboardTypeDefault;
    if (self.type == GDFormInputTypePassword) self.formInput.secureTextEntry = true;
    else if (self.type == GDFormInputTypePasswordReenter) self.formInput.secureTextEntry = true;
    else self.formInput.secureTextEntry = false;
    [self.formContainer addSubview:self.formInput];
    
    [self textFeildSetup:true animate:false];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldShouldChangeCharacters:) name:UITextFieldTextDidChangeNotification object:nil];
    
}

-(void)textFeildSetup:(BOOL)initate animate:(BOOL)animate {
    if (self.type == GDFormInputTypeUsername) {
        if (self.login) {
            if (initate) [self.formLabel setContent:NSLocalizedString(@"Authentication_FormLoginUsername_Title", nil)];
            else [self.formLabel setText:NSLocalizedString(@"Authentication_FormLoginUsername_Title", nil) animate:animate];
        
        }
        else {
            if (initate) [self.formLabel setContent:NSLocalizedString(@"Authentication_FormUsername_Title", nil)];
            else [self.formLabel setText:NSLocalizedString(@"Authentication_FormUsername_Title", nil) animate:animate];
            
        }
        
        [self.formInput setPlaceholder:NSLocalizedString(@"Authentication_FormUsername_Placeholder", nil)];
        
    }
    else if (self.type == GDFormInputTypeEmail) {
        if (self.login) {
            if (initate) [self.formLabel setContent:NSLocalizedString(@"Authentication_FormEmail_Title", nil)];
            else [self.formLabel setText:NSLocalizedString(@"Authentication_FormEmail_Title", nil) animate:animate];
            
            [self.formInput setPlaceholder:NSLocalizedString(@"Authentication_FormEmail_Placeholder", nil)];
            
        }
        else {
            if (initate) [self.formLabel setContent:NSLocalizedString(@"Authentication_FormEmail_Title", nil)];
            else [self.formLabel setText:NSLocalizedString(@"Authentication_FormEmail_Title", nil) animate:animate];
            
            [self.formInput setPlaceholder:NSLocalizedString(@"Authentication_FormEmail_Placeholder", nil)];
            
        }

    }
    else if (self.type == GDFormInputTypePassword) {
        if (self.login) {
            if (initate) [self.formLabel setContent:NSLocalizedString(@"Authentication_FormPassword_Title", nil)];
            else [self.formLabel setText:NSLocalizedString(@"Authentication_FormPassword_Title", nil) animate:animate];
            
            [self.formInput setPlaceholder:NSLocalizedString(@"Authentication_FormPassword_Placeholder", nil)];

        }
        else {
            if (initate) [self.formLabel setContent:NSLocalizedString(@"Authentication_FormPassword_Title", nil)];
            else [self.formLabel setText:NSLocalizedString(@"Authentication_FormPassword_Title", nil) animate:animate];
            
            [self.formInput setPlaceholder:NSLocalizedString(@"Authentication_FormPassword_Placeholder", nil)];

        }

    }
    else if (self.type == GDFormInputTypePasswordReenter) {
        if (initate) [self.formLabel setContent:NSLocalizedString(@"Authentication_FormRePassword_Title", nil)];
        else [self.formLabel setText:NSLocalizedString(@"Authentication_FormRePassword_Title", nil) animate:animate];

        [self.formInput setPlaceholder:NSLocalizedString(@"Authentication_FormPassword_Placeholder", nil)];
        
    }
    else if (self.type == GDFormInputTypePhone) {
        if (initate) [self.formLabel setContent:NSLocalizedString(@"Authentication_FormPhone_Title", nil)];
        else [self.formLabel setText:NSLocalizedString(@"Authentication_FormPhone_Title", nil) animate:animate];
        
        [self.formInput setPlaceholder:NSLocalizedString(@"Authentication_FormPhone_Placeholder", nil)];
        
    }
    
    [self.formInput setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:self.formInput.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.8 alpha:0.4]}]];
    
    if (initate) [self setEntry:nil];
    
}

-(void)textFieldDidShow:(NSNotification*)notification {
    keyboard =  [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.formContainer setFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height - keyboard.size.height)];
        [self.formLabel setFrame:CGRectMake(35.0, self.formContainer.center.y - 140.0, self.bounds.size.width - 70.0, 55.0)];
        [self.formInput setFrame:CGRectMake(35.0, self.formContainer.center.y - 90.0, self.formContainer.bounds.size.width - 70.0, 50.0)];
        
    }];
    
    [self.delegate formPresentedKeyboard:keyboard.size.height];
    
}

-(void)textFieldDidHide:(NSNotification*)notification {
    keyboard =  [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.formContainer setFrame:CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height)];
        [self.formLabel setFrame:CGRectMake(35.0, self.formContainer.center.y - 140.0, self.bounds.size.width - 70.0, 55.0)];
        [self.formInput setFrame:CGRectMake(35.0, self.formContainer.center.y - 90.0, self.formContainer.bounds.size.width - 70.0, 50.0)];
        
    }];
    
    [self.delegate formDismissedKeyboard];
    
}

-(void)textFieldShouldChangeCharacters:(NSNotification*)notification {
    UITextField *field = (UITextField *)notification.object;
    
    [NSRunLoop cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(textFieldValidate:) withObject:field afterDelay:0.3];
    
}

-(void)textFeildBecomeFirstResponder:(NSDictionary *)data {
    NSLog(@"textFeildBecomeFirstResponder %@", data)
    self.data = [[NSMutableDictionary alloc] initWithDictionary:data];
    
    [self textFeildSetup:false animate:false];
    [self.formInput becomeFirstResponder];
    
    if (self.formInput.text.length > 3) {
        [self performSelector:@selector(textFieldValidate:) withObject:self.formInput afterDelay:0.3];
        
    }

}

-(void)textFeildSetTitle:(NSString *)title {
    [self.formLabel setText:title animate:true];
    
}

-(void)textFeildValidateCheck {
    if (self.validated == false) {
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
        [shake setDuration:0.1];
        [shake setRepeatCount:2];
        [shake setAutoreverses:true];
        [shake setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.formLabel.center.x - 3,self.formLabel.center.y)]];
        [shake setToValue:[NSValue valueWithCGPoint:CGPointMake(self.formLabel.center.x + 3, self.formLabel.center.y)]];
        [self.formLabel.layer addAnimation:shake forKey:@"position"];
        
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate formKeyboardReturnPressed];
    [self textFieldValidate:self.formInput];
    
    return true;
    
}

-(void)textFieldValidate:(UITextField *)textField {
    self.entry = textField.text;
    if (!self.login) {
        if (self.type == GDFormInputTypeUsername) {
            if (textField.text.length > 3) {
                if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_USERNAME] evaluateWithObject:textField.text]) {
                    [self setValidated:true];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_UsernameOkay_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0x69DCCB) animate:true];

                }
                else {
                    [self setValidated:false];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_UsernameInvalid_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0xFF5656) animate:true];

                }
                
            }
            else {
                [self setValidated:false];
                [self textFeildSetup:false animate:true];
                
            }
            
        }
        else if (self.type == GDFormInputTypeEmail) {
            if (textField.text.length > 4) {
                if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_EMAIL] evaluateWithObject:textField.text]) {
                    [self setValidated:true];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_EmailOkay_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0x69DCCB) animate:true];

                }
                else {
                    [self setValidated:false];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_EmailInvalid_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0xFF5656) animate:true];
                    
                }
                
                
            }
            else {
                [self setValidated:false];
                [self textFeildSetup:false animate:true];

            }

        }
        else if (self.type == GDFormInputTypePassword) {
            if (textField.text.length > 2) {
                if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_PASSWORD] evaluateWithObject:textField.text]) {
                    [self setValidated:true];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_PasswordOkay_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0x69DCCB) animate:true];

                }
                else {
                    [self setValidated:false];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_PasswordUnsecure_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0xFF5656) animate:true];

                }
                
            }
            else {
                [self setValidated:false];
                [self textFeildSetup:false animate:true];
                
            }
            
        }
        else if (self.type == GDFormInputTypePasswordReenter) {
            NSLog(@"tezt %@" ,self.data);
            if (textField.text.length > 2) {
                if ([[self.data objectForKey:@"password"] isEqualToString:textField.text]) {
                    [self setValidated:true];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_RePasswordOkay_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0x69DCCB) animate:true];

                }
                else {
                    [self setValidated:false];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_RePasswordUnmatched_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0xFF5656) animate:true];

                }
            }
            else {
                [self setValidated:false];
                [self textFeildSetup:false animate:true];
                
            }
            
        }
        else if (self.type == GDFormInputTypePhone) {
            if (textField.text.length > 3) {
                if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_PHONE] evaluateWithObject:textField.text]) {
                    [self setValidated:true];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_PhoneOkay_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0x69DCCB) animate:true];
                    
                }
                else {
                    [self setValidated:false];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_EmailInvalid_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0xFF5656) animate:true];
                    
                }
                
            }
            
        }
        
    }
    else {
        if (self.type == GDFormInputTypeEmail) {
            if (textField.text.length > 3) {
                if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_EMAIL] evaluateWithObject:textField.text]) {
                    [self setValidated:true];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_EmailOkay_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0x69DCCB) animate:true];

                }
                else {
                    [self setValidated:false];
                    [self.formLabel setText:NSLocalizedString(@"Authenticate_EmailInvalid_Error", nil) animate:true];
                    [self.formLabel setStatusColour:UIColorFromRGB(0xFF5656) animate:true];

                }
                
            }
            else {
                [self setValidated:false];
                [self textFeildSetup:false animate:true];
                
            }
            
        }
        else if (textField.text.length > 3) {
            [self setValidated:true];
            [self.formLabel setText:NSLocalizedString(@"Authenticate_RePasswordOkay_Error", nil) animate:true];
            
        }
        
    }
    
    
}


@end
