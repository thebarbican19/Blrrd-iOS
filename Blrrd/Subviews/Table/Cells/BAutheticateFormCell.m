//
//  BAutheticateFormCell.m
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BAutheticateFormCell.h"
#import "BConstants.h"

@implementation BAutheticateFormCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[SAMLabel alloc] initWithFrame:CGRectMake(20.0, 0.0, self.bounds.size.width - 40.0 , 10.0)];
        self.label.text = @"Title";
        self.label.clipsToBounds = true;
        self.label.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        self.label.font = [UIFont fontWithName:@"Nunito-Black" size:10];
        self.label.clipsToBounds = true;
        [self.contentView addSubview:self.label];
        
        self.input = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 14.0, self.bounds.size.width - 20.0, self.bounds.size.height - 14.0)];
        self.input.font = [UIFont fontWithName:@"Nunito-SemiBold" size:14];
        self.input.clipsToBounds = true;
        self.input.textColor = MAIN_BACKGROUND_COLOR;
        self.input.layer.cornerRadius = 5.0;
        self.input.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 18.0, 20.0)];
        self.input.leftViewMode = UITextFieldViewModeAlways;
        self.input.layer.shadowRadius = 1.0;
        self.input.layer.shadowOffset = CGSizeMake(0.0, 0.2);
        self.input.layer.shadowColor = [UIColor blackColor].CGColor;
        self.input.backgroundColor = [UIColor whiteColor];
        self.input.delegate = self;
        self.input.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.input.autocorrectionType = UITextAutocorrectionTypeNo;
        self.input.keyboardAppearance = UIKeyboardAppearanceDark;
        [self.contentView addSubview:self.input];

    }
    
    return self;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldDidReturn:)]) {
        [self.delegate textFieldDidReturn:textField];
        
    }
    
    return true;
}

@end
