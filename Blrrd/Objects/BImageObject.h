//
//  BImageObject.h
//  Blrrd
//
//  Created by Joe Barbour on 28/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Mixpanel.h>
#import <Photos/Photos.h>
#import <CoreImage/CoreImage.h>

#import "BCredentialsObject.h"
#import "BQueryObject.h"

@protocol BImageObjectDelegate;
@interface BImageObject : NSObject <NSURLSessionTaskDelegate>

@property (nonatomic, strong) id <BImageObjectDelegate> delegate;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) Mixpanel *mixpanel;

-(UIImage *)processImageScaleToScreen:(UIImage *)image;
-(UIImage *)processImageRemoveOrentation:(UIImage*)image;
-(UIImage *)processImageCompress:(UIImage *)image quality:(float)quality;
-(UIImage *)processImageCropWithFrame:(UIImage *)image rect:(CGRect)rect;

-(void)imageAuthorization:(void (^)(PHAuthorizationStatus status))completion;
-(void)imageReturnLatestImage:(void (^)(UIImage *image))completion;
-(void)imagesFromAlbum:(NSString *)album completion:(void (^)(NSArray *images))completion;
-(void)imagesFromAsset:(PHAsset *)asset thumbnail:(BOOL)thumbnail completion:(void (^)(NSDictionary *data, UIImage *image))completion;
-(void)imagesRetriveAlbums:(void (^)(NSArray *albums))completion;

-(void)uploadImageWithCaption:(UIImage *)image caption:(NSString *)caption;

@end

@protocol BImageObjectDelegate <NSObject>

@optional

-(void)imageUploadedBytesWithPercentage:(double)percentage;
-(void)imageUploadedWithErrors:(NSError *)error;

@end

