//
//  BAutheticateFormCell.h
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMLabel.h"

@protocol BAutheticateCellDelegate;
@interface BAutheticateFormCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) id <BAutheticateCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet SAMLabel *label;
@property (nonatomic, strong) IBOutlet UITextField *input;

@end

@protocol BAutheticateCellDelegate <NSObject>

@optional

-(void)textFieldDidReturn:(UITextField *)textField;

@end
