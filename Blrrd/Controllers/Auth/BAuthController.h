//
//  BAuthController.h
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BQueryObject.h"
#import "BCredentialsObject.h"
#import "BAutheticateFormCell.h"
#import "BAuthenticationHeader.h"
#import "GDPlaceholderView.h"

@interface BAuthController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, BAutheticateCellDelegate, BAuthenticationHeaderDelegate, GDPlaceholderDelegate> {
    UITableView *viewForm;
    BAuthenticationHeader *viewHeader;
    GDPlaceholderView *viewPlaceholder;
    CGSize viewKeyboard;
    UIButton *viewAction;

}

@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) NSMutableArray *formdata;
@property (nonatomic, assign) BOOL validated;
@property (nonatomic, assign) BOOL login;

@property (nonatomic) UIStatusBarStyle statusbarstyle;
@property (nonatomic) BOOL statusbarhidden;

@end
