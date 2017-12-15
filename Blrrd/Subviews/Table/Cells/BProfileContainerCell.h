//
//  BProfileContainerCell.h
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImage+BlurEffects.h>

#import "BProfileImagesController.h"

@protocol BProfileContainerDelegate;
@interface BProfileContainerCell : UITableViewCell <BProfileImagesDelegate>

@property (nonatomic, strong) id <BProfileContainerDelegate> delegate;
@property (nonatomic, strong) BProfileImagesController *collection;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

-(void)setup;

@end

@protocol BProfileContainerDelegate <NSObject>

@optional

-(void)viewPresentProfile;
-(void)viewPresentImageWithData:(NSDictionary *)data;

@end

