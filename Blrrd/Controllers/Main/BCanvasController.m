//
//  BCanvasController.m
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BCanvasController.h"
#import "BConstants.h"

@interface BCanvasController ()

@end

@implementation BCanvasController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageobj = [[BImageObject alloc] init];
    self.imageobj.delegate = self;
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.viewPlaceholder = [[GDPlaceholderView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
    self.viewPlaceholder.delegate = self;
    self.viewPlaceholder.backgroundColor = [UIColor clearColor];
    self.viewPlaceholder.textcolor = [UIColor whiteColor];
    self.viewPlaceholder.gesture = true;
    [self.view addSubview:self.viewPlaceholder];
    
    self.viewFrame = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
    self.viewFrame.backgroundColor = [MAIN_BACKGROUND_COLOR colorWithAlphaComponent:0.6];
    [self.view addSubview:self.viewFrame];
    
    self.blur = [[UIVisualEffectView alloc] initWithEffect: [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.blur.frame = self.viewFrame.bounds;
    self.blur.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.viewFrame addSubview:self.blur];
    
    self.viewContainer = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, (self.view.bounds.size.height / 2) - (self.view.bounds.size.width / 2), self.view.bounds.size.width - 10.0, self.view.bounds.size.width - 10.0)];
    self.viewContainer.image = nil;
    self.viewContainer.alpha = 0.0;
    self.viewContainer.contentMode = UIViewContentModeCenter;
    self.viewContainer.clipsToBounds = true;
    self.viewContainer.layer.cornerRadius = 9.0;
    [self.view addSubview:self.viewContainer];

    self.viewOverlay = [[UIImageView alloc] initWithFrame:self.viewContainer.bounds];
    self.viewOverlay.image = nil;
    self.viewOverlay.alpha = 0.0;
    self.viewOverlay.contentMode = UIViewContentModeCenter;
    [self.viewContainer addSubview:self.viewOverlay];
    
    self.viewCaption = [[UITextView alloc] initWithFrame:CGRectMake(8.0, 8.0, self.viewContainer.bounds.size.width - 16.0, self.viewContainer.bounds.size.height - 16.0)];
    self.viewCaption.backgroundColor = [UIColor clearColor];
    self.viewCaption.text = nil;
    self.viewCaption.alpha = 0.0;
    self.viewCaption.keyboardAppearance = UIKeyboardAppearanceDark;
    self.viewCaption.delegate = self;
    self.viewCaption.textAlignment = NSTextAlignmentCenter;
    self.viewCaption.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.viewCaption.font = [UIFont fontWithName:@"Nunito-SemiBold" size:22];
    self.viewCaption.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.viewCaption.layer.shadowColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:0.2].CGColor;
    [self.viewCaption addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [self.viewContainer addSubview:self.viewCaption];

    self.viewNavigation = [[BCanvasNavigation alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 60.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.delegate = self;
    self.viewNavigation.alpha = 1.0;
    [self.view addSubview:self.viewNavigation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewKeyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewKeyboardWasShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewFieldKeyboardWasHidden:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewFieldKeyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
    
}

-(void)textViewKeyboardWasShow:(NSNotification *)notification {
    CGRect keyboardrect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewContainer setFrame:CGRectMake(5.0, 25.0 + ((self.view.bounds.size.height - (keyboardrect.size.height)) / 2) - (self.view.bounds.size.width / 2), self.view.bounds.size.width - 10.0, self.view.bounds.size.width - 10.0)];
        
    } completion:nil];
    
}

-(void)textViewFieldKeyboardWasHidden:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewContainer setFrame:CGRectMake(5.0, (self.view.bounds.size.height / 2) - (self.view.bounds.size.width / 2), self.view.bounds.size.width - 10.0, self.view.bounds.size.width - 10.0)];
        
    } completion:nil];

}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    if ([self.viewPlaceholder.key isEqualToString:@"sucsess"]) {
        [self viewTermiateCamera];
        [self viewCameraInitiate];
        
        
    }
    else  if ([self.viewPlaceholder.key isEqualToString:@"retry"]) {
        [self cameraUpload];
        
    }
    else [self viewAuthorizeCamera:true];
    
}

-(void)viewAuthorizeCamera:(BOOL)authorize {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        [self.viewFrame setHidden:false];
        [self viewCameraInitiate];
        
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (granted){
                    [self.viewFrame setHidden:false];
                    [self viewCameraInitiate];
                    
                }
                else {
                    if (authorize) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        
                    }
                    else {
                        [self.viewFrame setHidden:true];
                        [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Canvas_CameraUnauthorized_Title", nil) instructions:NSLocalizedString(@"Canvas_CameraUnauthorized_Body", nil)];

                    }
                    
                }
                
            }];
            
        }];
        
    }
    else {
        if (authorize) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }
        else {
            [self.viewFrame setHidden:true];
            [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Canvas_CameraUnauthorized_Title", nil) instructions:NSLocalizedString(@"Canvas_CameraUnauthorized_Body", nil)];

        }
        
    }
    
    [self.imageobj imageAuthorization:^(PHAuthorizationStatus status) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
                [self.viewNavigation actionimage:[UIImage imageNamed:@"camera_gallery_disabled"] buttontag:2];
                
            }
            else {
                [self.viewNavigation actionimage:[UIImage imageNamed:@"camera_gallery"] buttontag:2];
        
            }
            
        }];
        
    }];
    
}

-(void)viewCameraInitiate {
    NSArray* sublayers = [NSArray arrayWithArray:self.view.layer.sublayers];
    for (CALayer *layer in sublayers) {
        if ([layer.name isEqualToString:@"liveVideoLayer"]) [layer removeFromSuperlayer];
        
    }
    
    [self.viewFrame.layer setMask:[self viewCameraMask:[UIApplication sharedApplication].delegate.window.bounds]];
    [self.viewNavigation setAlpha:1.0];
    [self.viewNavigation type:BCanvasNavigationTypeCamera];
    
    #if !(TARGET_IPHONE_SIMULATOR)
        if (self.session.isRunning) [self.session stopRunning];
    
        self.session = [[AVCaptureSession alloc] init];
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;

        NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *device = [cameras objectAtIndex:self.frontfacing];
        if (device.hasFlash) {
            [device lockForConfiguration:nil];
            [device setFlashMode:self.flash?AVCaptureFlashModeOn:AVCaptureFlashModeOff];
            [device unlockForConfiguration];
            
        }
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!deviceInput)  NSLog(@"PANIC: no media input");
    
        if ([self.session canAddInput:deviceInput]) [self.session addInput:deviceInput];
    
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = [UIApplication sharedApplication].delegate.window.bounds;
        previewLayer.name = @"liveVideoLayer";
        [self.view.layer insertSublayer:previewLayer atIndex:0];
    
        self.output = [[AVCaptureStillImageOutput alloc] init];
        self.outputsettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.output setOutputSettings:self.outputsettings];
        [self.session addOutput:self.output];
        [self.session startRunning];
    
    #else
        [self.viewPlaceholder placeholderUpdateTitle:@"Camera Disabled" instructions:@"camera does not work in simulator"];
        [self.viewFrame setHidden:true];

    #endif
    
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

-(void)viewCaptureImage {
    if (self.gallerymode) [self cameraDiscard];
    else {
        if (self.session.isRunning) {
            AVCaptureConnection *videoConnection = nil;
            for (AVCaptureConnection *connection in self.output.connections) {
                for (AVCaptureInputPort *port in connection.inputPorts) {
                    if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                        videoConnection = connection;
                        break;
                        
                    }
                    
                }
                
                if (videoConnection) break;
                
            }
            
            [self.output captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                if (imageDataSampleBuffer) {
                    [self.session stopRunning];
                    [self.viewNavigation title:NSLocalizedString(@"Canvas_CameraApproveImage_Title", nil)];
                    [self viewHandleImage:[UIImage imageWithData:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer]]];
                    
                }
                
            }];
            
        }
        
    }
    
}

-(void)viewHandleImage:(UIImage *)image {
    if (!self.gallerymode && self.credentials.appSaveImages) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            
        } completionHandler:nil];
        
    }
    
    self.image = [self.imageobj processImageRemoveOrentation:image];
    self.image = [UIImage imageWithCGImage:self.image.CGImage
                                     scale:self.image.scale
                               orientation:UIImageOrientationUpMirrored];
    self.image = [self.imageobj processImageScaleToScreen:self.image];
    
    [self.viewFrame.layer setMask:nil];
    [self.viewContainer setImage:self.image];
    [self.viewContainer setAlpha:1.0];
    [self.viewOverlay setImage:[UIImage ty_imageByApplyingBlurToImage:self.image withRadius:60.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.15] saturationDeltaFactor:1.0 maskImage:nil]];
    [self.viewNavigation type:BCanvasNavigationTypePick];
    
}

-(void)viewTermiateCamera {
    [self.viewContainer setAlpha:0.0];
    [self.session stopRunning];
    [self.session removeOutput:self.output];
    [self.viewGallery.view removeFromSuperview];
    [self.viewFrame setBackgroundColor:[MAIN_BACKGROUND_COLOR colorWithAlphaComponent:0.6]];
    [self.viewPlaceholder setKey:nil];
    [self.viewPlaceholder setHidden:true];
    [self.viewNavigation setAlpha:1.0];
    [self.viewOverlay setAlpha:0.0];
    [self.viewCaption setAlpha:0.0];
    [self.viewCaption setText:nil];

}

-(void)cameraReverseToggle {
    [self viewTermiateCamera];
    [self setFrontfacing:!self.frontfacing];
    [self viewCameraInitiate];
    
}

-(void)cameraFlashToggle {
    [self viewTermiateCamera];
    [self setFlash:!self.flash];
    [self viewCameraInitiate];
    [self.viewNavigation actionimage:[UIImage imageNamed:self.flash?@"camera_flash_selected":@"camera_flash"] buttontag:3];
    
}

-(void)cameraPresentGallery {
    self.gallerymode = true;
    
    self.viewGalleryLayout = [[UICollectionViewFlowLayout alloc] init];
    self.viewGalleryLayout.minimumLineSpacing = 9.0;
    self.viewGalleryLayout.sectionInset = UIEdgeInsetsMake(self.viewNavigation.bounds.size.height + APP_STATUSBAR_HEIGHT + 8.0, 8.0, 8.0, 8.0);
    self.viewGalleryLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.viewGallery = [[BGalleryController alloc] initWithCollectionViewLayout:self.viewGalleryLayout];
    self.viewGallery.collectionView.frame = CGRectMake(0.0, 0.0 - (self.view.bounds.size.height - (MAIN_TABBAR_HEIGHT + 20.0)) , self.view.bounds.size.width, self.view.bounds.size.height - (MAIN_TABBAR_HEIGHT + 20.0));
    self.viewGallery.collectionView.backgroundColor = [UIColor clearColor];
    [self addChildViewController:self.viewGallery];
    [self.view addSubview:self.viewGallery.view];
    [self.viewGallery.imageobj imageAuthorization:^(PHAuthorizationStatus atuhstatus) {
        if (atuhstatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus newatuhstatus) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (newatuhstatus == PHAuthorizationStatusAuthorized) {
                        [self.viewGallery viewLoadImages];
                        [self.viewFrame.layer setMask:nil];
                        [self.viewNavigation type:BCanvasNavigationTypePick];
                        [self.viewGallery.imageobj imagesRetriveAlbums:^(NSArray *albums) {
                            //if (albums.count > 0) [self.viewNavigation title:albums.firstObject];
                            [self.viewNavigation title:NSLocalizedString(@"Canvas_GalleryDefault_Title", nil)];
                            
                        }];

                        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                            [self.viewGallery.collectionView setFrame:CGRectMake(0.0, 0.0 , self.view.bounds.size.width, self.viewGallery.collectionView.bounds.size.height)];

                        } completion:nil];
                
                    }
                    else [self.viewNavigation actionimage:[UIImage imageNamed:@"camera_gallery_disabled"] buttontag:2];
                    
                }];
                
            }];
            
        }
        else if (atuhstatus == PHAuthorizationStatusAuthorized) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewGallery viewLoadImages];
                [self.viewFrame.layer setMask:nil];
                [self.viewNavigation type:BCanvasNavigationTypePick];
                [self.viewGallery.imageobj imagesRetriveAlbums:^(NSArray *albums) {
                    //if (albums.count > 0) [self.viewNavigation title:albums.firstObject];
                    [self.viewNavigation title:NSLocalizedString(@"Canvas_GalleryDefault_Title", nil)];

                }];
                
                [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self.viewGallery.collectionView setFrame:CGRectMake(0.0, 0.0 , self.view.bounds.size.width, self.viewGallery.collectionView.bounds.size.height)];

                } completion:nil];
                
            }];
            
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
        }

    }];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.viewGallery.view.bounds;
    gradient.colors = @[(id)[[UIColor clearColor] CGColor],
                        (id)[[UIColor blackColor] CGColor],
                        (id)[[UIColor blackColor] CGColor],
                        (id)[[UIColor clearColor] CGColor]];
    gradient.locations = @[@(0.05), @(0.25), @(0.7), @(0.9)];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(0.0, 1.0);
    [self.viewGallery.view.layer setMask:gradient];
    
    [self.view bringSubviewToFront:self.viewNavigation];
    
}
             

-(void)cameraDiscard {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewOverlay setAlpha:0.0];
        [self.viewCaption setAlpha:0.0];
        [self.viewFrame setBackgroundColor:[MAIN_BACKGROUND_COLOR colorWithAlphaComponent:0.6]];
        
        if (self.gallerymode) {
            [self.viewGallery.collectionView setFrame:CGRectMake(0.0, 0.0 - self.viewGallery.collectionView.bounds.size.height, self.view.bounds.size.width, self.viewGallery.collectionView.bounds.size.height)];
            
        }

    } completion:^(BOOL finished) {
        [self.viewGallery.view removeFromSuperview];

    }];
    
    [self setGallerymode:false];
    [self.viewCaption resignFirstResponder];
    [self.viewNavigation type:BCanvasNavigationTypeCamera];
    [self viewTermiateCamera];
    [self viewCameraInitiate];
    
}

-(void)cameraUpload {
    if (self.gallerymode) {
        if (self.viewGallery.selected != nil) {
            [self.viewGallery.imageobj imagesFromAsset:self.viewGallery.selected thumbnail:false completion:^(NSDictionary *data, UIImage *image) {
                if (image) [self viewHandleImage:image];
            
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.viewGallery.collectionView setFrame:CGRectMake(0.0, 0.0 - self.viewGallery.collectionView.bounds.size.height, self.view.bounds.size.width, self.viewGallery.collectionView.bounds.size.height)];

                } completion:^(BOOL finished) {
                    [self setGallerymode:false];
                    [self.viewGallery.view removeFromSuperview];
                    [self cameraUpload];
                    
                }];
                
            }];
            
        }
        else [self.viewNavigation title:NSLocalizedString(@"Canvas_GalleryNothingSelectedError_Title", nil)];
        
    }
    else if (self.viewOverlay.alpha == 0.0 && !self.gallerymode) {
        [self.viewNavigation title:NSLocalizedString(@"Canvas_UploadCaptionError_Title", nil)];
        [self.viewCaption setText:nil];
        [self.viewCaption becomeFirstResponder];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewOverlay setAlpha:1.0];
            [self.viewCaption setAlpha:1.0];
            [self.viewFrame setBackgroundColor:[MAIN_BACKGROUND_COLOR colorWithAlphaComponent:1.0]];
            
        } completion:nil];
        
    }
    else if (self.image) {
        if (self.viewCaption.text.length > 2) {
            [self.imageobj uploadImageWithCaption:self.image caption:self.viewCaption.text];
            [self.viewCaption resignFirstResponder];
            [self setUploading:true];
            [self.viewPlaceholder setHidden:false];
            [self.viewPlaceholder placeholderLoading:0.01];
            [self.view bringSubviewToFront:self.viewPlaceholder];

            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.viewContainer setAlpha:0.0];
                [self.viewContainer setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
                [self.viewNavigation setAlpha:0.0];
                
            } completion:nil];
            
        }
        else {
            [self.viewNavigation title:NSLocalizedString(@"Canvas_UploadCaptionError_Title", nil)];
            
        }
        
    }
    
}

-(void)imageUploadedBytesWithPercentage:(double)percentage {
    NSLog(@"imageUploadedBytesWithPercentage %f" ,percentage);
    [self.viewPlaceholder placeholderLoading:percentage];

}

-(void)imageUploadedWithErrors:(NSError *)error {
    NSLog(@"imageUploadedWithErrors; %@" ,error)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
        [self setUploading:false];
        if (error.code != 200) {
            [self.viewPlaceholder setKey:@"retry"];
            [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Canvas_UploadErrorPlaceholder_Title", nil) instructions:error.domain==nil?NSLocalizedString(@"Canvas_UploadErrorPlaceholder_Body", nil):error.domain];
            
        }
        else {
            [self.viewPlaceholder setKey:@"sucsess"];
            [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Canvas_UploadSucsessPlaceholder_Title", nil) instructions:NSLocalizedString(@"Canvas_UploadSucsessPlaceholder_Body", nil)];

        }
        
    });

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = (tv.bounds.size.height - tv.contentSize.height * tv.zoomScale)/2.0;
    topCorrect = (topCorrect < 0.0?0.0:topCorrect);
    tv.contentInset = UIEdgeInsetsMake(topCorrect, 0.0, 0.0 ,0.0);
    
}

@end
