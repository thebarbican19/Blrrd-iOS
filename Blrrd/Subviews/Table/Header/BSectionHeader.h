//
//  BSectionHeader.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSectionHeader : UIView {
    UILabel *label;
    UIView *underline;
    CAGradientLayer *gradient;
    
}

@property (nonatomic, strong) NSString *name;

@end
