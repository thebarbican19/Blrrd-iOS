//
//  BCameraController.m
//  Blrrd
//
//  Created by Joe Barbour on 13/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BCameraController.h"
#import "BConstants.h"

@interface BCameraController ()

@end

@implementation BCameraController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.imagedata = [BImageObject sharedInstance];
    
    self.viewFrame = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
    self.viewFrame.backgroundColor = [MAIN_BACKGROUND_COLOR colorWithAlphaComponent:0.6];
    [self.view addSubview:self.viewFrame];
    
    self.viewBlur = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.viewBlur.frame = self.viewFrame.bounds;
    self.viewBlur.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.viewFrame addSubview:self.viewBlur];

}

-(CAShapeLayer *)viewCameraMask:(CGRect)fbounds {
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = fbounds;
    mask.fillColor = [UIColor blackColor].CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(5.0, (fbounds.size.height / 2) - (fbounds.size.width / 2), fbounds.size.width - 10.0, fbounds.size.width - 10.0) cornerRadius:9.0];
    [path appendPath:[UIBezierPath bezierPathWithRect:fbounds]];
    [mask setPath:path.CGPath];
    [mask setFillRule:kCAFillRuleEvenOdd];
    
    return mask;
    
}

-(void)cameraInitiate  {
    #if !(TARGET_IPHONE_SIMULATOR)
        NSMutableArray *types = [[NSMutableArray alloc] init];
        [types addObject:AVCaptureDeviceTypeBuiltInWideAngleCamera];
        if (APP_DEVICE_FLOAT >= 10.2) [types addObject:AVCaptureDeviceTypeBuiltInDualCamera];
        if (APP_DEVICE_FLOAT >= 11.1) [types addObject:AVCaptureDeviceTypeBuiltInTrueDepthCamera];

        AVCaptureDeviceDiscoverySession *discovery = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:types mediaType:AVMediaTypeVideo position:self.frontfacing?AVCaptureDevicePositionFront:AVCaptureDevicePositionBack];
        
        for(AVCaptureDevice *camera in discovery.devices) {
            if (camera.position == AVCaptureDevicePositionFront || camera.position == AVCaptureDevicePositionBack) {
                self.device = camera;
                
            }
            
        }
    
        if (self.device) {
            self.session = [[AVCaptureSession alloc] init];
            
            NSError * error;
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
            
            if (!error) {
                self.output = [AVCapturePhotoOutput new];
                
                [self.session setSessionPreset:AVCaptureSessionPresetHigh];
                [self.session addInput:input];
                [self.session startRunning];
                [self.session addOutput:self.output];

                self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
                self.preview.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
                self.preview.frame = self.view.bounds;
                [self.view.layer addSublayer:self.preview];
                [self.view bringSubviewToFront:self.viewFrame];
                [self.viewFrame.layer setMask:[self viewCameraMask:[UIApplication sharedApplication].delegate.window.bounds]];
                

            }
            
        }
    
    #else
    
    #endif
    
}

-(void)cameraTermiate {
    [self.session stopRunning];
    
}

-(void)cameraCapture {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    settings.flashMode = self.flash;
    
    [self.output capturePhotoWithSettings:settings delegate:self];
    
    if (self.output.depthDataDeliveryEnabled) [self.output setDepthDataDeliveryEnabled:true];
    if (self.output.highResolutionCaptureEnabled) [self.output setHighResolutionCaptureEnabled:true];
    
}

-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    [self.session stopRunning];
    if (error) {
        NSLog(@"Error: %@ Reason: %@" ,error.localizedDescription ,error.localizedFailureReason);
        return;
        
    }
    else {
        self.image = [UIImage imageWithData:[photo fileDataRepresentation]];
        if (self.frontfacing) {
            [self setImage:[UIImage imageWithCGImage:self.image.CGImage scale:1.0 orientation: UIImageOrientationLeftMirrored]];

        }
            
        [self.delegate viewHandleImage:self.image preview:true loading:false];
        
    }
    
}


@end
