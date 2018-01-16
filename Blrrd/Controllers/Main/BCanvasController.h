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
#import <UIImage+ResizeMagick.h>
#import "GDPlaceholderView.h"
#import "GPUImage.h"
#import "BCanvasNavigation.h"
#import "BImageObject.h"
#import "BGalleryController.h"
#import "BCredentialsObject.h"
#import "BCameraController.h"
#import "BCanvasView.h"

@protocol BCanvasDelegate;
@interface BCanvasController : UIViewController <GDPlaceholderDelegate, BCanvasNavigationDelegate, BImageObjectDelegate, BCameraDelegate, UITextViewDelegate>

@property (nonatomic, strong) id <BCanvasDelegate> delegate;
@property (nonatomic, strong) GDPlaceholderView *viewPlaceholder;
@property (nonatomic, strong) BCanvasNavigation *viewNavigation;
@property (nonatomic, strong) BCanvasView *viewCanvas;
@property (nonatomic, strong) BGalleryController *viewGallery;
@property (nonatomic, strong) BCameraController *viewCapture;
@property (nonatomic, strong) UICollectionViewFlowLayout *viewGalleryLayout;
@property (nonatomic, strong) UCZProgressView *viewProgress;

//@property (nonatomic, strong) GoogLeNetPlaces *imagerec;
@property (nonatomic, strong) BImageObject *imageobj;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic) UIImage *image;
@property (nonatomic, strong) NSDictionary *outputsettings;

@property (nonatomic, assign) BOOL gallerymode;
@property (nonatomic, assign) BOOL uploading;

-(void)viewAuthorizeCamera:(BOOL)authorize;
-(void)viewTermiateCamera;
-(void)viewCaptureImage;

@end

@protocol BCanvasDelegate <NSObject>

@optional

-(void)viewRefreshContent;

@end

