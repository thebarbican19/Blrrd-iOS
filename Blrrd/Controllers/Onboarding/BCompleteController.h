//
//  BCompleteController.h
//  Blrrd
//
//  Created by Joe Barbour on 14/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BCredentialsObject.h"
#import "BQueryObject.h"

#import "BLMultiColorLoader.h"
#import "SAMLabel.h"

@interface BCompleteController : UIViewController

@property (nonatomic, retain) Mixpanel *mixpanel;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, assign) BOOL login;

@property (nonatomic, strong) UIImageView *viewIcon;
@property (nonatomic, strong) SAMLabel *viewInstructions;
@property (nonatomic, strong) UIButton *viewAction;
@property (nonatomic, strong) BLMultiColorLoader *viewLoader;

@end
