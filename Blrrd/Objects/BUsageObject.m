//
//  BUsageObject.m
//  Blrrd
//
//  Created by Joe Barbour on 13/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BUsageObject.h"
#import "BConstants.h"

@implementation BUsageObject

-(instancetype)init {
    self = [super init];
    if (self) {
        [self.motion stopDeviceMotionUpdates];
        
        if (self.timeout == 0) self.timeout = 3;
        if (![self.motion isGyroActive]) {
            self.motion = [[CMMotionManager alloc] init];
            self.motion.accelerometerUpdateInterval = 1.0;
            self.queue = [[NSOperationQueue alloc] init];
            
            /*
            self.tappedgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applicationAccelerometerManager:)];
            self.tappedgesture.cancelsTouchesInView = false;
            [self.view addGestureRecognizer:self.tappedgesture];
             */
            
            if ([self.motion isAccelerometerAvailable]) {
                self.lastactive = [NSDate date];
                self.active = true;
                
                if (self.tracked == nil) self.tracked = [[NSMutableArray alloc] init];
                
                [self.motion startDeviceMotionUpdates];
                [self.motion startAccelerometerUpdatesToQueue:self.queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                    float x = self.motion.accelerometerData.acceleration.x;
                    float y = self.motion.accelerometerData.acceleration.y;
                    float z = self.motion.accelerometerData.acceleration.z;
                                        
                    [self.tracked addObject:[NSNumber numberWithFloat:fabsf(x) + fabsf(y) + fabsf(z)]];
                    
                    if (self.tracked.count > 2) {
                        float last = [[self.tracked objectAtIndex:self.tracked.count - 3] floatValue];
                        float newest = [[self.tracked objectAtIndex:self.tracked.count - 1] floatValue];
                        if (fabs(last - newest) > 0.009) {
                            if ([self.delegate respondsToSelector:@selector(deviceInRestingState)] && !self.active) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.delegate deviceInActiveState];
                                    
                                });
                                
                            }
                            
                            self.lastactive = [NSDate date];
                            self.active = true;

                        }
                        
                        if ([self.lastactive compare:[NSDate dateWithTimeIntervalSinceNow:-self.timeout]] == NSOrderedAscending && self.active) {
                            if ([self.delegate respondsToSelector:@selector(deviceInRestingState)]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.delegate deviceInRestingState];
                                    
                                });
                                
                            }
                            
                            self.active = false;
                            
                        }
                        
                    }
                    
                    if (self.tracked.count > 5) [self.tracked removeObjectAtIndex:0];
                    
                }];
                
            }
            
        }
        
    }
    return self;
    
}

@end
