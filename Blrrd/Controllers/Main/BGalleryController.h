//
//  BGalleryController.h
//  Blrrd
//
//  Created by Joe Barbour on 28/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BImageObject.h"

@interface BGalleryController : UICollectionViewController

-(void)viewLoadImages;

@property (nonatomic, strong) BImageObject *imageobj;
@property (nonatomic, strong) NSMutableArray *gallery;
@property (nonatomic, strong) PHAsset *selected;

@end
