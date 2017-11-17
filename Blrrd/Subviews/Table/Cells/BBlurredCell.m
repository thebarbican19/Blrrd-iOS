//
//  BBlurredCell.m
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BBlurredCell.h"
#import "BConstants.h"

@implementation BBlurredCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.mixpanel = [Mixpanel sharedInstance];
    self.query = [[BQueryObject alloc] init];
    if (self) {
        self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 26.0 ,26.0)];
        self.avatar.contentMode = UIViewContentModeScaleAspectFill;
        self.avatar.image = nil;
        self.avatar.backgroundColor = [UIColor darkGrayColor];
        self.avatar.layer.cornerRadius = self.avatar.bounds.size.width / 2;
        self.avatar.clipsToBounds = true;
        self.avatar.layer.borderColor = UIColorFromRGB(0x140F26).CGColor;
        self.avatar.layer.borderWidth = 0.8;
        [self.contentView addSubview:self.avatar];
        
        self.avatarbackground = [[UIView alloc] initWithFrame:CGRectMake(self.avatar.frame.origin.x - 1.0, self.avatar.frame.origin.y - 1.0, self.avatar.bounds.size.width + 2.0, self.avatar.bounds.size.height + 2.0)];
        self.avatarbackground.clipsToBounds = true;
        self.avatarbackground.backgroundColor = UIColorFromRGB(0x26CADF);
        self.avatarbackground.layer.cornerRadius = self.avatarbackground.bounds.size.height / 2;
        [self.contentView addSubview:self.avatarbackground];
        [self.contentView sendSubviewToBack:self.avatarbackground];
        
        self.user = [[SAMLabel alloc] initWithFrame:CGRectMake(32.0, -2.0, self.bounds.size.width - 60.0 ,16.0)];
        self.user.numberOfLines = 1;
        self.user.textAlignment = NSTextAlignmentLeft;
        self.user.text = nil;
        self.user.textColor = [UIColor whiteColor];
        self.user.font = [UIFont fontWithName:@"Nunito-SemiBold" size:16];
        [self addSubview:self.user];
        
        self.timestamp = [[SAMLabel alloc] initWithFrame:CGRectMake(32.0, 15.0, self.bounds.size.width - 60.0 ,10.0)];
        self.timestamp.numberOfLines = 1;
        self.timestamp.textAlignment = NSTextAlignmentLeft;
        self.timestamp.text = nil;
        self.timestamp.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        self.timestamp.font = [UIFont fontWithName:@"Nunito-Bold" size:8];
        [self addSubview:self.timestamp];
        
        self.time = [[GDStatusLabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 55.0, 0.0, 50.0, 28.0)];
        self.time.numberOfLines = 1;
        self.time.hidden = false;
        self.time.colour = [UIColor whiteColor];
        self.time.fount = [UIFont fontWithName:@"Nunito-Bold" size:14];
        self.time.alignment = NSTextAlignmentRight;
        self.time.backgroundColor = [UIColor clearColor];
        self.time.userInteractionEnabled = false;
        [self addSubview:self.time];
        
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 32.0, self.bounds.size.width, self.bounds.size.height - 34.0)];
        self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
        self.container.userInteractionEnabled = true;
        self.container.clipsToBounds = true;
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
        self.subtitle.font = [UIFont fontWithName:@"Nunito-SemiBold" size:22];
        self.subtitle.shadowOffset = CGSizeMake(0.0, 1.0);
        self.subtitle.shadowColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:0.2];
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
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:[self.userdata objectForKey:@"photo"]]];
    [self.time setText:self.timeformatted animate:false];
    [self.timestamp setText:[self time:[content objectForKey:@"last_viewtime_datetime"]]];

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
        if (self.timer.isValid) {
            [self.timer invalidate];
            [self setTimeviewed:0];
            [self.query postTime:self.content secondsadded:self.timeviewed completion:^(NSError *error) {
                if (error.code == 200) {
                    [self.mixpanel track:@"Image Revealed" properties:@{@"Image":[self.content objectForKey:@"publicpath"],
                                                                        @"ID":[self.content objectForKey:@"id"],
                                                                        @"User":[self.content objectForKey:@"username"]}];
                    
                }
                
            }];
            

        }
        
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

-(NSString *)time:(NSString *)timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[formatter dateFromString:timestamp] toDate:[NSDate date] options:0];
    
    NSDateFormatter *formatted = [[NSDateFormatter alloc] init];
    formatted.dateFormat = @"d MMMM YYYY";

    if (components.day > 7) {
        return [formatted stringFromDate:[formatter dateFromString:timestamp]];
        
    }
    else if (components.day > 0) {
        return [NSString stringWithFormat:@"%d %@ ago" ,(int)components.day, components.day==1?@"day":@"days"];
        
    }
    else if (components.hour > 0) {
        return [NSString stringWithFormat:@"%d %@ ago" ,(int)components.hour, components.hour==1?@"hour":@"hour"];
        
    }
    else if (components.minute > 0) {
        return [NSString stringWithFormat:@"%d %@ ago" ,(int)components.minute, components.minute==1?@"minute":@"minutes"];
        
    }
    else {
        return nil;
        
    }
    
}

@end
