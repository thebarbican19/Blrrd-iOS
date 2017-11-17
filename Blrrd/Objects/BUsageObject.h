//
//  BUsageObject.h
//  Blrrd
//
//  Created by Joe Barbour on 13/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>

@protocol BUsageDelegate;
@interface BUsageObject : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, strong) id <BUsageDelegate> delegate;
@property (nonatomic, strong) CMMotionManager *motion;
@property (nonatomic, strong) NSMutableArray *tracked;
@property (nonatomic, strong) NSDate *lastactive;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) UITapGestureRecognizer *gesture;
@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic, assign) int timeout;

@end

@protocol BUsageDelegate <NSObject>

@optional

-(void)deviceInRestingState;
-(void)deviceInActiveState;

@end
