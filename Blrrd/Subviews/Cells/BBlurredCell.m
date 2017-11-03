//
//  BBlurredCell.m
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BBlurredCell.h"

@implementation BBlurredCell

-(void)dealloc {
    NSLog(@"dealloc %@" ,self.subtitle.text);
    
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {        
        self.container = [[UIView alloc] initWithFrame:self.bounds];
        self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
        self.container.clipsToBounds = true;
        self.container.userInteractionEnabled = true;
        self.container.layer.cornerRadius = 8.0;
        [self.contentView addSubview:self.container];
        
        self.image = [[UIImageView alloc] initWithFrame:self.container.bounds];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.image = nil;
        self.image.transform = CGAffineTransformMakeScale(1.15, 1.15);
        [self.container addSubview:self.image];
        
        self.overlay = [[UIImageView alloc] initWithFrame:self.container.bounds];
        self.overlay.contentMode = UIViewContentModeScaleAspectFill;
        self.overlay.image = nil;
        [self.container addSubview:self.overlay];
        
        self.subtitle = [[SAMLabel alloc] initWithFrame:CGRectMake(20.0, 20.0, self.container.bounds.size.width - 40.0, self.container.bounds.size.height - 40.0)];
        self.subtitle.numberOfLines = 3;
        self.subtitle.textAlignment = NSTextAlignmentCenter;
        self.subtitle.text = nil;
        self.subtitle.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        self.subtitle.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
        [self.container addSubview:self.subtitle];

        self.gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(reveal:)];
        self.gesture.minimumPressDuration = 0.3;
        [self.container addGestureRecognizer:self.gesture];
        
    }
    
    return self;
    
}

-(void)content:(NSDictionary *)content index:(NSIndexPath *)index {
    [self.subtitle setText:[content objectForKey:@"name"]];
    [self blur:[NSURL URLWithString:[content objectForKey:@"publicpath"]]];
    
}

-(void)blur:(NSURL *)url {
    [self.image sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (image.CGImage != NULL && image.CGImage != nil) {
                [self.overlay setImage:[UIImage ty_imageByApplyingBlurToImage:image withRadius:40.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.15] saturationDeltaFactor:1.0 maskImage:nil]];
                [self.image setImage:image];
                
            }
            
        } completion:nil];
        
    }];
    
}
                        
-(void)reveal:(UILongPressGestureRecognizer *)gesture {
    [UIView animateWithDuration:gesture==nil?0.2:0.4 delay:0.05 options:(gesture==nil?UIViewAnimationOptionCurveEaseIn:UIViewAnimationOptionCurveEaseOut) animations:^{
        if (gesture != nil) {
            [self.subtitle setAlpha:0.0];
            [self.overlay setAlpha:0.0];
            [self.image setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            
        }
        else {
            [self.subtitle setAlpha:1.0];
            [self.overlay setAlpha:1.0];
            [self.image setTransform:CGAffineTransformMakeScale(1.15, 1.15)];
            
        }
             
    } completion:nil];

}

@end
