//
//  BImageObject.m
//  Blrrd
//
//  Created by Joe Barbour on 28/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BImageObject.h"
#import "BConstants.h"

@implementation BImageObject

+(BImageObject *)sharedInstance {
    static BImageObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BImageObject alloc] init];
        
        
    });
    
    return sharedInstance;
    
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.credentials = [[BCredentialsObject alloc] init];
        self.mixpanel = [Mixpanel sharedInstance];
        self.query = [[BQueryObject alloc] init];

    }
    return self;
    
}

-(UIImage *)processImageScaleToScreen:(UIImage *)image {
    float scale = [UIApplication sharedApplication].delegate.window.bounds.size.width / image.size.width;
    float height = image.size.height * scale;
    float width = image.size.width * scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

-(UIImage *)processImageToSize:(UIImage *)image size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
    
}

-(UIImage *)processImageCropWithFrame:(UIImage *)image rect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    return [UIImage imageWithCGImage:imageRef];
    
}

-(UIImage *)processImageRemoveOrentation:(UIImage*)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
    
}

-(UIImage *)processImageCompress:(UIImage *)image quality:(float)quality {
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = quality;
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
            
        }
        else if(imgRatio > maxRatio){
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
            
        }
        
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
}



-(CVPixelBufferRef)processImageCreatePixelBuffer:(UIImage *)original {
    CGImageRef image = original.CGImage;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
    
}

-(void)imageAuthorization:(void (^)(PHAuthorizationStatus status))completion {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
            completion(authorizationStatus);
            
        }];
        
    }
    else completion([PHPhotoLibrary authorizationStatus]);
    
}

-(void)imageReturnLatestImage:(void (^)(UIImage *image))completion {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    PHFetchResult *fetch = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];

    [self imagesFromAsset:fetch.firstObject thumbnail:true completion:^(NSDictionary *data, UIImage *image) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completion(image);
            
        }];

    } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
    }];
    
}

-(void)imagesFromAlbum:(NSString *)album completion:(void (^)(NSArray *images))completion {
    if (self.output.count == 0) {
        self.output = [[NSMutableArray alloc] init];
   
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
    
        PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.output addObject:obj];

        }];
    
    }
    
    completion(self.output);
    
    
}

-(void)imagesFromAsset:(PHAsset *)asset thumbnail:(BOOL)thumbnail completion:(void (^)(NSDictionary *data, UIImage *image))completion withProgressHandler:(PHAssetImageProgressHandler)process {
    PHImageRequestOptions  *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.synchronous = true;
    options.networkAccessAllowed = true;
    options.version = PHImageRequestOptionsVersionCurrent;
    options.progressHandler =  ^(double progress,NSError *error,BOOL* stop, NSDictionary* dict) {
        NSLog(@"progress %lf",progress);  //never gets called
        
    };
    
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset targetSize:CGSizeMake(thumbnail?100.0:asset.pixelWidth, thumbnail?100.0:asset.pixelHeight) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage* image, NSDictionary *info) {
        if ([[info valueForKey:PHImageResultIsInCloudKey] boolValue]) {
            [manager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (downloadFinined) {
                    completion(info, [UIImage imageWithData:imageData]);
                    NSLog(@"Image downloaded %@" ,info);
                    
                }
                else {
                    NSLog(@"Image downloading icloud %@" ,info);
                    
                }
                
            }];
            
        }
        else {
            completion(info, image);
    
        }
        
    }];
    
}

-(void)imagesRetriveAlbums:(void (^)(NSArray *albums))completion {
    PHFetchOptions *options = [PHFetchOptions new];
    //options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    if (self.output == nil) {
        self.output = [[NSMutableArray alloc] init];
        
        PHFetchResult *albums = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:options];
        [albums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.output addObject:collection.localizedTitle];
                
            }];
            
        }];
        
    }
    
    completion(self.output);
    
}

-(void)uploadImageWithCaption:(UIImage *)image caption:(NSString *)caption {
    NSMutableString *formatdata = [[NSMutableString alloc] init];
    [formatdata appendString:[UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:0]];
    NSString *endpoint = [NSString stringWithFormat:@"%@content/upload.php" ,APP_HOST_URL];
    NSString *endpointmethod = @"POST";
    NSDictionary *endpointparams = @{@"caption":caption, @"file":formatdata};
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request addValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"blappversion"];
    [request addValue:APP_LANGUAGE forHTTPHeaderField:@"bllanguage"];
    if (self.credentials.authToken) [request addValue:self.credentials.authToken forHTTPHeaderField:@"blbearer"];
    [request setHTTPMethod:endpointmethod];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:endpointparams options:NSJSONWritingPrettyPrinted error:nil]];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionUploadTask *task = [session uploadTaskWithStreamedRequest:request];
    
    [task resume];
    
}

-(void)uploadRemove:(NSDictionary *)post completion:(void (^)(NSError *error))completion {
    NSString *endpoint = [NSString stringWithFormat:@"%@content/upload.php" ,APP_HOST_URL];
    NSString *endpointmethod = @"DELETE";
    NSLog(@"post delete %@" ,post)
    NSDictionary *endpointparams = @{@"postid":[post objectForKey:@"postid"]};
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request addValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"blappversion"];
    [request addValue:APP_LANGUAGE forHTTPHeaderField:@"bllanguage"];
    if (self.credentials.authToken) [request addValue:self.credentials.authToken forHTTPHeaderField:@"blbearer"];
    [request setHTTPMethod:endpointmethod];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:endpointparams options:NSJSONWritingPrettyPrinted error:nil]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *status = (NSHTTPURLResponse *)response;
        if (status.statusCode == 200) {
            if (data.length > 0 && !error) {
                NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
                NSLog(@"removed %@" ,output);
                completion([NSError errorWithDomain:[output objectForKey:@"status"] code:[[output objectForKey:@"error_code"] intValue] userInfo:nil]);
                
            }

        }
        else {
            if (error) completion(error);
            else completion([NSError errorWithDomain:@"unknown error" code:status.statusCode userInfo:nil]);
            
        }

    }];
    
    [task resume];
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    CGFloat progress = (float)totalBytesSent/totalBytesExpectedToSend;
    NSLog(@"downloaded %d%%", (int)(100.0 * progress));
    
    if ([self.delegate respondsToSelector:@selector(imageUploadedBytesWithPercentage:)]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.delegate imageUploadedBytesWithPercentage:progress];
        
        }];
        
    }
    
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSDictionary *output = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] firstObject];
    if ([[output objectForKey:@"error_code"] intValue] == 200) {
        if ([self.delegate respondsToSelector:@selector(imageUploadedWithErrors:)]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.query cacheDestroy:@"following"];
                [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
                    [self.delegate imageUploadedBytesWithPercentage:1.0];
                    [self.delegate imageUploadedWithErrors:[NSError errorWithDomain:@"no errors" code:200 userInfo:nil]];
                    
                }];
                
            }];
            
        }
        
    }
    else {
        if ([self.delegate respondsToSelector:@selector(imageUploadedWithErrors:)]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSError *error = [NSError errorWithDomain:[output objectForKey:@"status"] code:[[output objectForKey:@"error_code"] intValue] userInfo:nil];
                [self.delegate imageUploadedWithErrors:error];
                
            }];
            
        }
        
    }
        
}



@end
