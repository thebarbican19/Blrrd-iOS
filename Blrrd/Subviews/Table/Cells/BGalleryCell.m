//
//  BGalleryCell.m
//  Blrrd
//
//  Created by Joe Barbour on 28/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BGalleryCell.h"
#import "BConstants.h"

@implementation BGalleryCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.container = [[UIImageView alloc] initWithFrame:self.bounds];
        self.container.backgroundColor = [UIColor clearColor];
        self.container.contentMode = UIViewContentModeScaleAspectFill;
        self.container.image = nil;
        [self.contentView addSubview:self.container];
        
        self.overlay = [[UIImageView alloc] initWithFrame:self.bounds];
        self.overlay.backgroundColor = [UIColorFromRGB(0x69DCCB) colorWithAlphaComponent:0.7];
        self.overlay.contentMode = UIViewContentModeCenter;
        self.overlay.image = [UIImage imageNamed:@"camera_gallery_item_selected"];
        self.overlay.alpha = 0.0;
        self.overlay.transform = CGAffineTransformMakeScale(1.15, 1.15);
        [self.container addSubview:self.overlay];
        
    }
    
    return self;
    
}

@end
