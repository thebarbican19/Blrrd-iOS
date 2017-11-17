//
//  BCanvasController.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDPlaceholderView.h"

@interface BCanvasController : UIViewController <GDPlaceholderDelegate>

@property (nonatomic, strong) GDPlaceholderView *placeholder;

-(void)viewInitiateCamera;
-(void)viewTermiateCamera;

@end
