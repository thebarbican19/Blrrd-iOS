//
//  BFooterView.h
//  Blrrd
//
//  Created by Joe Barbour on 13/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BLMultiColorLoader.h"
#import "SAMLabel.h"

@interface BFooterView : UIView

@property (nonatomic, strong) BLMultiColorLoader *loader;
@property (nonatomic, strong) SAMLabel *label;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL noformatting;

-(void)present:(BOOL)loading status:(NSString *)status;

@end
