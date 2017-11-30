//
//  BCanvasNavigation.h
//  Blrrd
//
//  Created by Joe Barbour on 27/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDStatusLabel.h"

typedef enum {
    BCanvasNavigationTypeCamera,
    BCanvasNavigationTypePick
    
} BCanvasNavigationType;

@protocol BCanvasNavigationDelegate;
@interface BCanvasNavigation : UIView {
    UIView *container;
    UIButton *camera;
    UIButton *gallery;
    UIButton *flash;
    UIButton *discard;
    UIButton *upload;
    GDStatusLabel *header;

}

@property (nonatomic, strong) id <BCanvasNavigationDelegate> delegate;

-(void)title:(NSString *)title;
-(void)actionimage:(NSString *)image buttontag:(NSInteger)tag;
-(void)type:(BCanvasNavigationType)type;

@end

@protocol BCanvasNavigationDelegate <NSObject>

@optional

-(void)cameraReverseToggle;
-(void)cameraFlashToggle;
-(void)cameraPresentGallery;
-(void)cameraDiscard;
-(void)cameraUpload;

@end
