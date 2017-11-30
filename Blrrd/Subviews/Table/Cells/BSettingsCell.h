//
//  BSettingsCell.h
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMLabel.h"

@interface BSettingsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet SAMLabel *name;
@property (nonatomic, strong) IBOutlet SAMLabel *variable;
@property (nonatomic, strong) IBOutlet UISwitch *toggle;
@property (nonatomic, strong) IBOutlet UIImageView *accessory;

@end
