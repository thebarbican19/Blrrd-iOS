//
//  BSettingsCell.m
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BSettingsCell.h"
#import "BConstants.h"

@implementation BSettingsCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.name = [[SAMLabel alloc] initWithFrame:CGRectMake(20.0, 20.0, self.bounds.size.width - 40.0 , 18.0)];
        self.name.text = @"Title";
        self.name.clipsToBounds = true;
        self.name.textColor = [UIColor whiteColor];
        self.name.font = [UIFont fontWithName:@"Nunito-SemiBold" size:14];
        self.name.clipsToBounds = true;
        self.name.layer.cornerRadius = 5.0;
        [self.contentView addSubview:self.name];
        
        self.toggle = [[UISwitch alloc] initWithFrame:CGRectMake(self.bounds.size.width - 58.0, 0.0, 51.0, 31.0)];
        self.toggle.tintColor = [UIColor lightGrayColor];
        self.toggle.onTintColor = UIColorFromRGB(0x69DCCB);
        [self.contentView addSubview:self.toggle];
        
        self.accessory = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 58.0, 0.0, 51.0, self.bounds.size.height)];
        self.accessory.contentMode = UIViewContentModeCenter;
        self.accessory.userInteractionEnabled = false;
        self.accessory.image = [UIImage imageNamed:@"navigation_back"];
        self.accessory.layer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f);
        [self.contentView addSubview:self.accessory];
        
    }
    
    return self;
    
}

@end
