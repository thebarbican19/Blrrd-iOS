//
//  BCanvasView.m
//  Blrrd
//
//  Created by Joe Barbour on 19/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BCanvasView.h"
#import "BConstants.h"

@implementation BCanvasView

-(void)drawRect:(CGRect)rect {
    container = [[UIImageView alloc] initWithFrame:self.bounds];
    container.image = nil;
    container.alpha = 0.0;
    container.contentMode = UIViewContentModeScaleAspectFill;
    container.clipsToBounds = true;
    container.layer.cornerRadius = 9.0;
    container.backgroundColor = [UIColor clearColor];
    [self addSubview:container];
    
    overlay = [[UIImageView alloc] initWithFrame:container.bounds];
    overlay.image = nil;
    overlay.alpha = 0.0;
    overlay.contentMode = container.contentMode;
    [container addSubview:overlay];
    
    self.caption = [[UITextView alloc] initWithFrame:CGRectMake(8.0, 8.0, container.bounds.size.width - 16.0, container.bounds.size.height - 16.0)];
    self.caption.backgroundColor = [UIColor clearColor];
    self.caption.text = nil;
    self.caption.alpha = 0.0;
    //caption.placeholder = NSLocalizedString(@"Canvas_Caption_Text", nil);
    //caption.placeholderTextColor = [UIColor colorWithWhite:0.95 alpha:0.6];
    //caption.isExpandable = true;
    //caption.maximumLineCount = 4;
    self.caption.keyboardAppearance = UIKeyboardAppearanceDark;
    self.caption.delegate = self;
    self.caption.textAlignment = NSTextAlignmentCenter;
    self.caption.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.caption.font = [UIFont fontWithName:@"Nunito-SemiBold" size:22];
    self.caption.returnKeyType = UIReturnKeyDone;
    self.caption.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.caption.layer.shadowColor = [UIColorFromRGB(0x000000) colorWithAlphaComponent:0.2].CGColor;
    [container addSubview:self.caption];
    
    progress = [[UCZProgressView alloc] initWithFrame:CGRectMake((self.bounds.size.width / 2) - 25.0, (self.bounds.size.height / 2) - 25.0, 50.0, 50.0)];
    progress.radius = 30.0;
    progress.alpha = 0.0;
    progress.transform = CGAffineTransformMakeScale(0.9, 0.9);
    progress.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    progress.backgroundColor = [UIColor clearColor];
    progress.tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    progress.progress = 1.0;
    [container addSubview:progress];
    //[caption addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];

}

-(void)canvasImage:(UIImage *)image {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (image == nil) [container setAlpha:0.0];
        else [container setAlpha:1.0];

    } completion:nil];
    
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [container setImage:image];
        [overlay setImage:image];
        
    } completion:nil];
    
}

-(void)canvasBlurOverlay:(BOOL)enabled {
    [UIView animateWithDuration:0.3 delay:0.0 options:enabled?UIViewAnimationOptionCurveEaseIn:UIViewAnimationOptionCurveEaseIn animations:^{
        if (enabled) {
            [self.caption setAlpha:1.0];
            [overlay setAlpha:1.0];
            [overlay setImage:[UIImage ty_imageByApplyingBlurToImage:container.image withRadius:60.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.15] saturationDeltaFactor:1.0 maskImage:nil]];
            
        }
        else {
            [self.caption setAlpha:0.0];
            [overlay setAlpha:0.0];
            
        }
        
    } completion:nil];
    
}

-(void)canvasPresentKeyboard {
    [self canvasBlurOverlay:true];
    [self.caption becomeFirstResponder];
    
}

-(void)canvasDismissKeyboard {
    [self.caption resignFirstResponder];
    
}

-(void)canvasReset {
    [self canvasBlurOverlay:false];
    [self canvasDismissKeyboard];
    
    [overlay setImage:nil];
    [container setImage:nil];
    [self.caption setText:nil];

}

-(void)canvasDownloadingImageWithProgress:(double)downloaded {
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (downloaded > 0.0 && downloaded < 1.0) {
            [progress setAlpha:1.0];
            [progress setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            
        }
        else {
            [progress setAlpha:0.5];
            [progress setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        }
        
    } completion:nil];
    
    [progress setProgress:downloaded animated:true];
    [overlay setImage:[UIImage ty_imageByApplyingBlurToImage:container.image withRadius:60.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.15] saturationDeltaFactor:1.0 maskImage:nil]];

}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return false;
        
    }
    
    return true;
    
}

-(BOOL)canvasContainsCaption {
    if (self.caption.text.length > 2) return true;
    else return false;
    
}

-(BOOL)canvasBlurred {
    if (overlay.alpha > 0) return true;
    else return false;
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *tv = object;
    CGFloat topCorrect = (tv.bounds.size.height - tv.contentSize.height * tv.zoomScale) / 2.0;
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentInset = UIEdgeInsetsMake(topCorrect ,0.0 ,0.0, 0.0);
    
}


@end
