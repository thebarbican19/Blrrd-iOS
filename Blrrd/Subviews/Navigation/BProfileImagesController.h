//
//  BProfileImagesController.h
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BQueryObject.h"

@protocol BProfileImagesDelegate;
@interface BProfileImagesController : UICollectionViewController

@property (nonatomic, strong) id <BProfileImagesDelegate> delegate;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, assign) int limitimages;

-(void)setup;

@end

@protocol BProfileImagesDelegate <NSObject>

@optional

-(void)viewPresentProfile;
-(void)viewPresentImageWithData:(NSDictionary *)data;

@end


