//
//  BProfileCell.h
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>
#import <UIImage+BlurEffects.h>

#import "BCredentialsObject.h"

@interface BProfileCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *seconds;
@property (nonatomic, strong) UIImageView *image;

@property (nonatomic, strong) BCredentialsObject *credentials;

-(void)content:(NSDictionary *)content;

@end
