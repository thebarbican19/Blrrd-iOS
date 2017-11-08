//
//  SHSegmentCell.m
//  Shwifty
//
//  Created by Joe Barbour on 20/10/2017.
//  Copyright © 2017 NorthernSpark. All rights reserved.
//

#import "BSegmentCell.h"
#import "BConstants.h"

@implementation BSegmentCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = true;

        self.label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0.0, self.bounds.size.width - 20.0, self.bounds.size.height)];
        //self.label.font =
        self.label.textColor = UIColorFromRGB(0xFFFFFF);
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        
    }
    
    return self;
    
}

@end
