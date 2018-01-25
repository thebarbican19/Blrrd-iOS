//
//  BCameraController.h
//  Blrrd
//
//  Created by Joe Barbour on 13/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <UIImage+BlurEffects.h>

#import "BImageObject.h"

@protocol BCameraDelegate;
@interface BCameraController : UIViewController <AVCapturePhotoCaptureDelegate>

-(void)cameraInitiate;
-(void)cameraTermiate;
-(void)cameraCapture;

@property (nonatomic, strong) id <BCameraDelegate> delegate;
@property (nonatomic, strong) UIView *viewFrame;
@property (nonatomic) UIVisualEffectView *viewBlur;

@property (nonatomic, strong) BImageObject *imagedata;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) AVCapturePhotoOutput *output;
@property (nonatomic, assign) BOOL frontfacing;
@property (nonatomic, assign) BOOL flash;
@property (nonatomic, strong) UIImage *image;

@end

@protocol BCameraDelegate <NSObject>

@optional

-(void)viewHandleImage:(UIImage *)image preview:(BOOL)preview loading:(BOOL)loading camera:(BOOL)camera;

@end
