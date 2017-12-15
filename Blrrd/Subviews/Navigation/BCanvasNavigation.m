//
//  BCanvasNavigation.m
//  Blrrd
//
//  Created by Joe Barbour on 27/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BCanvasNavigation.h"

@implementation BCanvasNavigation

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:container]) {
        container = [[UIView alloc] initWithFrame:self.bounds];
        container.backgroundColor = [UIColor clearColor];
        [self addSubview:container];
        
        camera = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, container.bounds.size.height, container.bounds.size.height)];
        camera.backgroundColor = [UIColor clearColor];
        camera.tag = 1;
        [camera setImage:[UIImage imageNamed:@"camera_reverse"] forState:UIControlStateNormal];
        [camera addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:camera];

        gallery = [[UIButton alloc] initWithFrame:CGRectMake((container.bounds.size.width / 2) - (container.bounds.size.height / 2), 0.0, container.bounds.size.height, container.bounds.size.height)];
        gallery.backgroundColor = [UIColor clearColor];
        gallery.tag = 2;
        gallery.hidden = false;
        gallery.clipsToBounds = true;
        gallery.layer.borderWidth = 0.0;
        gallery.layer.borderColor = [UIColor whiteColor].CGColor;
        gallery.layer.cornerRadius = gallery.bounds.size.height / 2;
        [gallery setImage:[UIImage imageNamed:@"camera_gallery"] forState:UIControlStateNormal];
        [gallery addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:gallery];
        
        flash = [[UIButton alloc] initWithFrame:CGRectMake(container.bounds.size.width - container.bounds.size.height, 0.0, container.bounds.size.height, container.bounds.size.height)];
        flash.backgroundColor = [UIColor clearColor];
        flash.tag = 3;
        [flash setImage:[UIImage imageNamed:@"camera_flash"] forState:UIControlStateNormal];
        [flash addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:flash];
        
        discard = [[UIButton alloc] initWithFrame:CGRectMake(0.0 - container.bounds.size.height, 0.0, container.bounds.size.height, container.bounds.size.height)];
        discard.backgroundColor = [UIColor clearColor];
        discard.tag = 4;
        discard.alpha = 0.0;
        [discard setImage:[UIImage imageNamed:@"camera_close"] forState:UIControlStateNormal];
        [discard addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:discard];
        
        header = [[GDStatusLabel alloc] initWithFrame:CGRectMake(container.bounds.size.height, 0.0, container.bounds.size.width - (container.bounds.size.height * 2), container.bounds.size.height)];
        header.fount = [UIFont fontWithName:@"Nunito-Bold" size:14];
        header.colour = [UIColor colorWithWhite:1.0 alpha:0.8];
        header.alignment = NSTextAlignmentCenter;
        header.content = nil;
        [container addSubview:header];
        
        upload = [[UIButton alloc] initWithFrame:CGRectMake(container.bounds.size.width, 0.0, container.bounds.size.height, container.bounds.size.height)];
        upload.backgroundColor = [UIColor clearColor];
        upload.tag = 5;
        upload.alpha = 0.0;
        [upload setImage:[UIImage imageNamed:@"camera_done"] forState:UIControlStateNormal];
        [upload addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:upload];
        
    }
    
}

-(void)title:(NSString *)title {
    [header setText:title animate:true];
    
}

-(void)actionimage:(UIImage *)image buttontag:(NSInteger)tag {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        for (UIView *subview in container.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *selected = (UIButton *)subview;
                if (subview.tag == tag) {
                    [selected setImage:image forState:UIControlStateNormal];
                    if (image.hasAlpha) [selected.layer setBorderWidth:0];
                    else [selected.layer setBorderWidth:0.6];

                }
                
            }
            
        }
        
    } completion:nil];
    
}

-(void)type:(BCanvasNavigationType)type {
    CGRect camerarect = camera.frame;
    CGRect galleryrect = gallery.frame;
    CGRect flashrect = flash.frame;
    CGRect discardrect = discard.frame;
    CGRect uploadrect = upload.frame;
    if (type == BCanvasNavigationTypePick) {
        camerarect.origin.y = -container.bounds.size.height;
        galleryrect.origin.y = -container.bounds.size.height;
        flashrect.origin.y = -container.bounds.size.height;
        discardrect.origin.x = 0.0;
        uploadrect.origin.x = container.bounds.size.width - container.bounds.size.height;

        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [camera setFrame:camerarect];
            [camera setAlpha:0.0];
            [gallery setFrame:galleryrect];
            [gallery setAlpha:0.0];
            [flash setFrame:flashrect];
            [flash setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [discard setFrame:discardrect];
                [discard setAlpha:1.0];
                [upload setFrame:uploadrect];
                [upload setAlpha:1.0];
                [header setAlpha:1.0];

            } completion:nil];
            
        }];
        
    }
    else {
        camerarect.origin.y = 0.0;
        galleryrect.origin.y = 0.0;
        flashrect.origin.y = 0.0;
        discardrect.origin.x = 0.0 - container.bounds.size.height;
        uploadrect.origin.x = container.bounds.size.width;
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [discard setFrame:discardrect];
            [discard setAlpha:0.0];
            [upload setFrame:uploadrect];
            [upload setAlpha:0.0];
            [header setAlpha:0.0];

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [camera setFrame:camerarect];
                [camera setAlpha:1.0];
                [gallery setFrame:galleryrect];
                [gallery setAlpha:1.0];
                [flash setFrame:flashrect];
                [flash setAlpha:1.0];
                
            } completion:nil];
            
        }];
        
    }
    
}

-(void)tapped:(UIButton *)button {
    if (button.tag == 1) {
        if ([self.delegate respondsToSelector:@selector(cameraReverseToggle)]) {
            [self.delegate cameraReverseToggle];
            
        }
        
    }
    
    if (button.tag == 2) {
        if ([self.delegate respondsToSelector:@selector(cameraPresentGallery)]) {
            [self.delegate cameraPresentGallery];
            
        }
        
    }
    
    if (button.tag == 3) {
        if ([self.delegate respondsToSelector:@selector(cameraFlashToggle)]) {
            [self.delegate cameraFlashToggle];
            
        }
        
    }
    
    if (button.tag == 4) {
        if ([self.delegate respondsToSelector:@selector(cameraDiscard)]) {
            [self.delegate cameraDiscard];
            
        }
        
    }
    
    if (button.tag == 5) {
        if ([self.delegate respondsToSelector:@selector(cameraUpload)]) {
            [self.delegate cameraUpload];
            
        }
        
    }
    
}

@end
