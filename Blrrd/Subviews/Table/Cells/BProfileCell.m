//
//  BProfileCell.m
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BProfileCell.h"

@implementation BProfileCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [[UIImageView alloc] initWithFrame:self.bounds];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.image = nil;
        [self.contentView addSubview:self.image];
        
        self.seconds = [[UILabel alloc] initWithFrame:self.image.bounds];
        self.seconds.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.4];
        self.seconds.clipsToBounds = true;
        self.seconds.textAlignment = NSTextAlignmentCenter;
        self.seconds.textColor = [UIColor whiteColor];
        self.seconds.font = [UIFont fontWithName:@"Nunito-Bold" size:15];
        [self.contentView addSubview:self.seconds];
        
    }
    
    return self;
    
}

-(void)content:(NSDictionary *)content {
    [self image:[NSURL URLWithString:[content objectForKey:@"publicpath"]]];
    [self timeformatted:[[content objectForKey:@"sectotal"] intValue]];
    
}

-(void)image:(NSURL *)url {
    [self.image sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (image.CGImage != NULL && image.CGImage != nil) {
                [self.image setImage:image];
                
            }
            
        } completion:nil];
        
    }];
    
}

-(void)timeformatted:(int)second {
    if (second < 60) self.seconds.text = [NSString stringWithFormat:@"%01ds" ,second % 60];
    else self.seconds.text = [NSString stringWithFormat:@"%01dm" ,second / 60 % 60];
}


@end
