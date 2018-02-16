//
//  BCanvasView.h
//  Blrrd
//
//  Created by Joe Barbour on 19/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <UIImage+BlurEffects.h>
#import "UCZProgressView.h"
#import "BImageObject.h"

@interface BCanvasView : UIView <UITextViewDelegate> {
    UIImageView *overlay;
    UIImageView *container;
    UCZProgressView *progress;

}

@property (nonatomic, strong) UITextView *caption;
@property (nonatomic, strong) BImageObject *imgobject;

-(void)canvasImage:(UIImage *)image;
-(void)canvasBlurOverlay:(BOOL)enabled;
-(void)canvasPresentKeyboard;
-(void)canvasDismissKeyboard;
-(void)canvasReset;
-(void)canvasDownloadingImageWithProgress:(double)downloaded;

-(BOOL)canvasContainsCaption;
-(BOOL)canvasBlurred;

@end
