//
//  BBlurredCell.m
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BBlurredCell.h"

@implementation BBlurredCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.mixpanel = [Mixpanel sharedInstance];
    if (self) {
        self.avatar = [[KVNBoundedImageView alloc] initWithFrame:CGRectMake(0.0, 4.0, 20.0 ,20.0)];
        self.avatar.boundingBoxScheme = BoundingBoxSchemeLargest;
        self.avatar.boundingEnabled = true;
        self.avatar.boundingPadding = 10.0;
        self.avatar.animated = true;
        self.avatar.contentMode = UIViewContentModeScaleAspectFill;
        self.avatar.image = nil;
        self.avatar.backgroundColor = [UIColor lightGrayColor];
        self.avatar.layer.cornerRadius = self.avatar.bounds.size.width / 2;
        [self.contentView addSubview:self.avatar];
        
        self.user = [[SAMLabel alloc] initWithFrame:CGRectMake(25.0, 0.0, self.bounds.size.width - 60.0 ,28.0)];
        self.user.numberOfLines = 1;
        self.user.textAlignment = NSTextAlignmentLeft;
        self.user.text = nil;
        self.user.textColor = [UIColor whiteColor];
        self.user.font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
        [self addSubview:self.user];
        
        self.time = [[GDStatusLabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 55.0, 0.0, 50.0, 28.0)];
        self.time.numberOfLines = 1;
        self.time.hidden = false;
        self.time.colour = [UIColor whiteColor];
        self.time.fount =  [UIFont fontWithName:@"Arial-BoldMT" size:12];
        self.time.alignment = NSTextAlignmentRight;
        self.time.backgroundColor = [UIColor clearColor];
        self.time.userInteractionEnabled = false;
        [self addSubview:self.time];
        
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 30.0, self.bounds.size.width, self.bounds.size.height)];
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
        self.gesture.minimumPressDuration = 0.1;
        [self.container addGestureRecognizer:self.gesture];
        
    }
    
    return self;
    
}

-(void)content:(NSDictionary *)content index:(NSIndexPath *)index {
    self.content = [[NSMutableDictionary alloc] initWithDictionary:content];
    self.userdata = [[content objectForKey:@"userdata"] firstObject];
    self.existingtimeviewed = [[self.content objectForKey:@"sectotal"] intValue];

    [self.subtitle setText:[content objectForKey:@"name"]];
    [self.user setText:[[self.userdata objectForKey:@"username"] lowercaseString]];
    [self.avatar setImageFromURL:[NSURL URLWithString:[self.userdata objectForKey:@"photo"]] placeholder:nil];
    [self.time setText:self.timeformatted animate:false];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self blur:[NSURL URLWithString:[content objectForKey:@"publicpath"]]];
        
    });
    
}

-(void)blur:(NSURL *)url {
    [self.image sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (image.CGImage != NULL && image.CGImage != nil) {
                [self.overlay setImage:[UIImage ty_imageByApplyingBlurToImage:image withRadius:60.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.15] saturationDeltaFactor:1.0 maskImage:nil]];
                [self.image setImage:image];
                
            }
            
        } completion:nil];
        
    }];
    
}

-(void)givetime:(NSTimer *)timer {
    if (timer != nil) {
        [self setExistingtimeviewed:self.existingtimeviewed+1];
        [self setTimeviewed:self.timeviewed+1];
        [self.time setText:self.timeformatted animate:true];
        [self.content setObject:[NSNumber numberWithInt:self.existingtimeviewed] forKey:@"sectotal"];

    }
    
    if (self.timeviewed > 35) [self reveal:nil];
    
}

-(NSString *)timeformatted {
    if (self.existingtimeviewed < 60) return [NSString stringWithFormat:@"%01ds" ,self.existingtimeviewed % 60];
    else return [NSString stringWithFormat:@"%01dm %01ds" ,self.existingtimeviewed / 60 % 60, self.existingtimeviewed % 60];
}
                        
-(void)reveal:(UILongPressGestureRecognizer *)gesture {
    if (gesture == nil) {
        [self.timer invalidate];
        [self.mixpanel track:@"Image Revealed" properties:@{@"Image":[self.content objectForKey:@"publicpath"],
                                                            @"ID":[self.content objectForKey:@"id"],
                                                            @"User":[self.content objectForKey:@"username"]}];
        
    }
    else if (gesture.state == UIGestureRecognizerStateBegan) {
        [self setTimeviewed:0];
        [self.mixpanel timeEvent:@"Image Revealed"];
        if ([self.delegate respondsToSelector:@selector(collectionViewRevealed:)]) {
            [self.delegate collectionViewRevealed:self];
            
        }
        
        if (self.timer.isValid == false) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(givetime:) userInfo:nil repeats:true];
            
        }

    }
    
    
    [UIView animateWithDuration:gesture==nil?0.2:0.4 delay:0.0 options:(gesture==nil?UIViewAnimationOptionCurveEaseIn:UIViewAnimationOptionCurveEaseOut) animations:^{
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
