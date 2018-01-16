//
//  VDSearchView.m
//  Video Downloader
//
//  Created by Joe Barbour on 09/04/2015.
//  Copyright (c) 2015 NorthernSpark. All rights reserved.
//

#import "BSearchView.h"
#import "BConstants.h"

@implementation BSearchView

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:self.search]) {
        self.search = [[UITextField alloc] initWithFrame:self.bounds];
        self.search.layer.cornerRadius = 0.0;
        self.search.font = [UIFont fontWithName:@"Nunito-Light" size:13];
        self.search.textAlignment = NSTextAlignmentCenter;
        self.search.textColor = [UIColor whiteColor];
        self.search.backgroundColor = UIColorFromRGB(0x090713);
        self.search.delegate = self;
        self.search.keyboardAppearance = UIKeyboardAppearanceDark;
        self.search.placeholder = self.placeholder;
        self.search.autocorrectionType = UITextAutocorrectionTypeNo;
        self.search.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.search.returnKeyType = UIReturnKeyGoogle;
        self.search.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.search.keyboardType = self.keyboard;
        [self addSubview:self.search];
        [self.search setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:self.search.placeholder==nil?@"":self.search.placeholder
                    attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x9BA0A1)}]];

        self.loader = [[BLMultiColorLoader alloc] initWithFrame:CGRectMake(4.0, 8.0, self.search.bounds.size.height, self.search.bounds.size.height - 16.0)];
        self.loader.lineWidth = 2.0;
        self.loader.colorArray = @[UIColorFromRGB(0xEB402C)];
        [self.search addSubview:self.loader];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldKeyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldKeyboardWasShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldKeyboardWasHidden:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldKeyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
        
    }
    
    [self.search setFrame:self.bounds];

}

-(void)textFieldKeyboardWasShow:(NSNotification *)notification {
    [self.delegate searchFieldWasPresented:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size];
    
}

-(void)textFieldKeyboardWasHidden:(NSNotification *)notification {
    [self.delegate searchFieldWasDismissed];
    
}

-(void)textFieldDidChange:(UITextField *)textField {
    if (self.shouldUpdate) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(textFieldDidStopEditing:) object:nil];
        [self performSelector:@selector(textFieldDidStopEditing:) withObject:nil afterDelay:0.5];
        
        if ([self.search.text length] == 0) [self.loader stopAnimation];
        
    }
    
}

-(void)textFieldDidStopEditing:(UITextField *)textField {
    [self.delegate searchFieldWasUpdated:self.search.text];

}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setShouldUpdate:true];
    [self.delegate searchFieldWasUpdated:self.search.text];

}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self.loader stopAnimation];
    [self.delegate searchFieldWasDismissed];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.loader stopAnimation];
    
    return true;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismiss];
    [self.delegate searchFieldWasUpdated:self.search.text];
    [self.delegate searchFieldWasDismissed];
    
    return true;
    
}

-(void)textFieldShouldRefresh {
    [self.delegate searchFieldDidRefreshContent];
    [self.loader startAnimation];

}

-(void)applicationStartedSearching:(NSNotification *)notification {
    [self.loader startAnimation];

}

-(void)applicationEndedSearching:(NSNotification *)notification {
    [self.loader stopAnimation];

}

-(void)textFieldShouldSetContent:(NSString *)content {
    [self setShouldUpdate:false];
    [self.search setText:content];
    
}

-(void)present {
    [self.search becomeFirstResponder];

}

-(void)dismiss {
    [self.search resignFirstResponder];
    
}

@end
