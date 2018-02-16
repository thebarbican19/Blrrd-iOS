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
    
    //self.imagerec = [[GoogLeNetPlaces alloc] init];
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.imageobj = [BImageObject sharedInstance];
    self.imageobj.delegate = self;
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.viewPlaceholder = [[GDPlaceholderView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
    self.viewPlaceholder.delegate = self;
    self.viewPlaceholder.backgroundColor = [UIColor clearColor];
    self.viewPlaceholder.textcolor = [UIColor whiteColor];
    self.viewPlaceholder.gesture = true;
    [self.view addSubview:self.viewPlaceholder];
    
    self.viewCapture = [[BCameraController alloc] init];
    self.viewCapture.view.frame = self.viewPlaceholder.bounds;
    self.viewCapture.view.backgroundColor = [UIColor clearColor];
    self.viewCapture.delegate = self;
    [self addChildViewController:self.viewCapture];
    [self.view addSubview:self.viewCapture.view];
    [self.viewCapture cameraInitiate];
    
    self.viewCanvas = [[BCanvasView alloc] initWithFrame:CGRectMake(5.0, (self.view.bounds.size.height / 2) - (self.view.bounds.size.width / 2), self.view.bounds.size.width - 10.0, self.view.bounds.size.width - 10.0)];
    self.viewCanvas.alpha = 0.0;
    self.viewCanvas.layer.cornerRadius = 9.0;
    self.viewCanvas.clipsToBounds = true;
    self.viewCanvas.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewCanvas];

    self.viewNavigation = [[BCanvasNavigation alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 60.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.delegate = self;
    self.viewNavigation.alpha = 1.0;
    [self.view addSubview:self.viewNavigation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewKeyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewKeyboardWasShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewFieldKeyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];

    
    
}

-(void)viewLoadGalleryContents {
    [self.imageobj imageAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self.imageobj imagesFromAlbum:nil completion:^(NSArray *images) {
                
            }];
            
        }
        
    }];
    
}

-(void)textViewKeyboardWasShow:(NSNotification *)notification {
    CGRect keyboardrect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewCanvas setFrame:CGRectMake(5.0, 25.0 + ((self.view.bounds.size.height - (keyboardrect.size.height)) / 2) - (self.view.bounds.size.width / 2), self.view.bounds.size.width - 10.0, self.view.bounds.size.width - 10.0)];
        
    } completion:nil];
    
}

-(void)textViewFieldKeyboardWasHidden:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewCanvas setFrame:CGRectMake(5.0, (self.view.bounds.size.height / 2) - (self.view.bounds.size.width / 2), self.view.bounds.size.width - 10.0, self.view.bounds.size.width - 10.0)];
        
    } completion:nil];

}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    if ([self.viewPlaceholder.key isEqualToString:@"sucsess"]) {
        [self viewTermiateCamera];
        [self.viewCapture cameraInitiate];
        
        
    }
    else  if ([self.viewPlaceholder.key isEqualToString:@"retry"]) {
        [self cameraUpload];
        
    }
    else [self viewAuthorizeCamera:true];
    
}

-(void)viewAuthorizeCamera:(BOOL)authorize {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        [self.viewCapture.view setHidden:false];
        [self.viewCapture cameraInitiate];
        
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (granted){
                    [self.viewCapture.view setHidden:false];
                    [self.viewCapture cameraInitiate];

                }
                else {
                    if (authorize) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                            
                        }];
                        
                    }
                    else {
                        [self.viewCapture.view setHidden:true];
                        [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Canvas_CameraUnauthorized_Title", nil) instructions:NSLocalizedString(@"Canvas_CameraUnauthorized_Body", nil)];

                    }
                    
                }
                
            }];
            
        }];
        
    }
    else {
        if (authorize) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                
            }];
            
        }
        else {
            [self.viewCapture.view setHidden:true];
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

-(void)viewCaptureImage {
    if (self.gallerymode) [self cameraDiscard];
    else {
        [self.viewCapture cameraCapture];
        [self.viewNavigation title:NSLocalizedString(@"Canvas_CameraApproveImage_Title", nil)];
        
    }
   
}

-(void)viewHandleImage:(UIImage *)image preview:(BOOL)preview loading:(BOOL)loading camera:(BOOL)camera {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (camera && self.credentials.appSaveImages) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                
            } completionHandler:nil];
            
        }
        
        /*
        NSError *error;
        UIImage *scaled = [self.imageobj processImageToSize:image size:CGSizeMake(112, 112)];
        CVPixelBufferRef buffer = [self.imageobj processImageCreatePixelBuffer:scaled];
        GoogLeNetPlacesInput *input = [[GoogLeNetPlacesInput alloc] initWithSceneImage:buffer];
        GoogLeNetPlacesOutput *output = [self.imagerec predictionFromFeatures:input error:&error];
        */
        
        self.image = [self.imageobj processImageRemoveOrentation:image];
        self.image = [self.image resizedImageByMagick:@"500"];

        [self.mixpanel track:[NSString stringWithFormat:@"App %@ Image" ,camera?@"Captured New":@"Imported"]];

        [self.viewCapture.viewFrame.layer setMask:nil];
        [self.viewCanvas canvasImage:self.image];
        [UIView animateWithDuration:0.2 animations:^{
            [self.viewCanvas setAlpha:1.0];
            [self.viewCanvas setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [self.viewCapture.viewFrame setBackgroundColor:[MAIN_BACKGROUND_COLOR colorWithAlphaComponent:1.0]];
            [self.viewCanvas canvasBlurOverlay:!preview];
            
        } completion:nil];
        
    }];

    [self.viewNavigation type:BCanvasNavigationTypePick];
    
}

-(void)viewTermiateCamera {
    [self.viewCanvas setAlpha:0.0];
    [self.viewCanvas canvasReset];
    [self.viewGallery.view removeFromSuperview];
    [self.viewCapture cameraTermiate];
    [self.viewCapture.viewFrame setBackgroundColor:[MAIN_BACKGROUND_COLOR colorWithAlphaComponent:0.6]];
    [self.viewCapture.viewFrame.layer setMask:nil];
    [self.viewPlaceholder setKey:nil];
    [self.viewPlaceholder setHidden:true];
    [self.viewNavigation setAlpha:1.0];
    [self.viewNavigation type:BCanvasNavigationTypeCamera];

}

-(void)viewCameraInitiate {
    [self viewTermiateCamera];
    [self.viewNavigation type:BCanvasNavigationTypeCamera];
    [self.viewCapture cameraInitiate];
    
}

-(void)cameraReverseToggle {
    [self viewTermiateCamera];
    [self.viewCapture setFrontfacing:!self.viewCapture.frontfacing];
    [self.viewCapture cameraInitiate];
    
}

-(void)cameraFlashToggle {
    [self viewTermiateCamera];
    [self.viewCapture setFlash:!self.viewCapture.flash];
    [self.viewCapture cameraInitiate];
    [self.viewNavigation actionimage:[UIImage imageNamed:self.viewCapture.flash?@"camera_flash_selected":@"camera_flash"] buttontag:3];
    
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
                        [self.viewCapture.viewFrame.layer setMask:nil];
                        [self.viewNavigation type:BCanvasNavigationTypePick];
                        [self.viewGallery.imageobj imagesRetriveAlbums:^(NSArray *albums) {
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
                [self.viewCapture.viewFrame.layer setMask:nil];
                [self.viewNavigation type:BCanvasNavigationTypePick];
                [self.viewGallery.imageobj imagesRetriveAlbums:^(NSArray *albums) {
                    [self.viewNavigation title:NSLocalizedString(@"Canvas_GalleryDefault_Title", nil)];

                }];
                
                [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self.viewGallery.collectionView setFrame:CGRectMake(0.0, 0.0 , self.view.bounds.size.width, self.viewGallery.collectionView.bounds.size.height)];

                } completion:nil];
                
            }];
            
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                
            }];
            
        }

    }];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.viewGallery.view.bounds;
    gradient.colors = @[(id)[[UIColor clearColor] CGColor],
                        (id)[[UIColor blackColor] CGColor],
                        (id)[[UIColor blackColor] CGColor],
                        (id)[[UIColor clearColor] CGColor]];
    gradient.locations = @[@(0.05), @(0.18), @(0.7), @(0.9)];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(0.0, 1.0);
    [self.viewGallery.view.layer setMask:gradient];
    
    [self.view bringSubviewToFront:self.viewNavigation];
    
}

-(void)cameraDiscard {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewCanvas canvasBlurOverlay:false];
        [self.viewCapture.viewFrame setBackgroundColor:[MAIN_BACKGROUND_COLOR colorWithAlphaComponent:0.6]];
        
        if (self.gallerymode) {
            [self.viewGallery.collectionView setFrame:CGRectMake(0.0, 0.0 - self.viewGallery.collectionView.bounds.size.height, self.view.bounds.size.width, self.viewGallery.collectionView.bounds.size.height)];
            
        }

    } completion:^(BOOL finished) {
        [self.viewGallery.view removeFromSuperview];

    }];
    
    [self setGallerymode:false];
    [self.viewCanvas canvasReset];
    [self.viewNavigation type:BCanvasNavigationTypeCamera];
    [self.viewCapture cameraInitiate];
    
}

-(void)cameraUpload {
    if (self.gallerymode) {
        if (self.viewGallery.selected != nil) {
            [self.viewGallery.imageobj imagesFromAsset:self.viewGallery.selected thumbnail:false completion:^(NSDictionary *data, UIImage *image) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.viewNavigation title:NSLocalizedString(@"Canvas_CameraApproveImage_Title", nil)];
                    [self viewHandleImage:image preview:true loading:false camera:false];
                    
                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        [self.viewGallery.collectionView setFrame:CGRectMake(0.0, 0.0 - self.viewGallery.collectionView.bounds.size.height, self.view.bounds.size.width, self.viewGallery.collectionView.bounds.size.height)];
                        
                    } completion:^(BOOL finished) {
                        [self setGallerymode:false];
                        [self.viewGallery.view removeFromSuperview];
                        
                    }];
                    
                }];
                
            } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self viewHandleImage:nil preview:true loading:true camera:false];
                    [self.viewCanvas canvasDownloadingImageWithProgress:progress];
                    
                }];

            }];
            
        }
        else [self.viewNavigation title:NSLocalizedString(@"Canvas_GalleryNothingSelectedError_Title", nil)];
        
    }
    else if ([self.viewCanvas canvasBlurred] == false && self.gallerymode == false) {
        [self.viewNavigation title:NSLocalizedString(@"Canvas_UploadCaptionError_Title", nil)];
        [self viewHandleImage:self.image preview:false loading:false camera:true];
        [self.viewCanvas canvasPresentKeyboard];

    }
    else if (self.image) {
        if ([self.viewCanvas canvasContainsCaption]) {
            [self.imageobj uploadImageWithCaption:self.image caption:self.viewCanvas.caption.text];
            [self setUploading:true];
            [self.viewPlaceholder setHidden:false];
            [self.viewPlaceholder placeholderLoading:0.05];
            [self.view bringSubviewToFront:self.viewPlaceholder];

            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.viewCanvas setAlpha:0.0];
                [self.viewCanvas setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
                [self.viewNavigation setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [self.viewCanvas canvasReset];;

            }];
            
        }
        else {
            [self.viewNavigation title:NSLocalizedString(@"Canvas_UploadCaptionError_Title", nil)];
            [self.viewCanvas canvasDismissKeyboard];

        }
        
    }
    
}

-(void)imageUploadedBytesWithPercentage:(double)percentage {
    [self.viewPlaceholder placeholderLoading:percentage];

}

-(void)imageUploadedWithErrors:(NSError *)error {
    [self setUploading:false];
    if (error.code != 200) {
        [self.mixpanel track:@"App Image Uploaded With Error" properties:@{@"Error":error.domain==nil?@"Unknown":error.domain}];
        [self.viewPlaceholder setKey:@"retry"];
        [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Canvas_UploadErrorPlaceholder_Title", nil) instructions:error.domain==nil?NSLocalizedString(@"Canvas_UploadErrorPlaceholder_Body", nil):error.domain];
        
    }
    else {
        [self.viewPlaceholder setKey:@"sucsess"];
        [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Canvas_UploadSucsessPlaceholder_Title", nil) instructions:NSLocalizedString(@"Canvas_UploadSucsessPlaceholder_Body", nil)];
        [self.delegate viewRefreshContent];
        [self.mixpanel.people increment:@"Posts" by:@+1];
        [self.mixpanel track:@"App Image Uploaded"];

    }
    
}

@end
