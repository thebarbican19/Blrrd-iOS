//
//  BCanvasController.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <UIImage+BlurEffects.h>

#import "GDPlaceholderView.h"
#import "GPUImage.h"
#import "BCanvasNavigation.h"
#import "BImageObject.h"
#import "BGalleryController.h"

@interface BCanvasController : UIViewController <GDPlaceholderDelegate, BCanvasNavigationDelegate, BImageObjectDelegate, UITextViewDelegate>

@property (nonatomic, strong) GDPlaceholderView *viewPlaceholder;
@property (nonatomic, strong) BCanvasNavigation *viewNavigation;
@property (nonatomic, strong) UIImageView *viewContainer;
@property (nonatomic, strong) UIImageView *viewOverlay;
@property (nonatomic, strong) UITextView *viewCaption;
@property (nonatomic, strong) BGalleryController *viewGallery;
@property (nonatomic, strong) UICollectionViewFlowLayout *viewGalleryLayout;
@property (nonatomic, strong) UIView *viewFrame;
@property (nonatomic, strong) UCZProgressView *viewProgress;

@property (nonatomic, strong) BImageObject *imageobj;
@property (nonatomic) UIImage *image;
@property (nonatomic) AVCaptureStillImageOutput *output;
@property (nonatomic, strong) NSDictionary *outputsettings;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic, assign) BOOL frontfacing;
@property (nonatomic, assign) BOOL flash;
@property (nonatomic, assign) BOOL gallerymode;
@property (nonatomic, assign) BOOL uploading;
@property (nonatomic) UIVisualEffectView *blur;

-(void)viewAuthorizeCamera:(BOOL)authorize;
-(void)viewCameraInitiate;
-(void)viewTermiateCamera;
-(void)viewCaptureImage;

@end
