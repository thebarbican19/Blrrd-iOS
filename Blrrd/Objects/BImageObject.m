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
    float scale = [UIApplication sharedApplication].delegate.window.bounds.size.height / image.size.height;
    float height = image.size.height * scale;
    float width = image.size.width * scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
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
        completion(image);

    }];
    
}

-(void)imagesFromAlbum:(NSString *)album completion:(void (^)(NSArray *images))completion {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    
    NSMutableArray *output = [[NSMutableArray alloc] init];
    PHFetchResult *fetch = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    if (fetch.count > 0) {
        for (PHAsset *asset in fetch) {
            if (asset.location) [output addObject:asset];
            
        }
        
    }
    
    completion(output);
    
    
}

-(void)imagesFromAsset:(PHAsset *)asset thumbnail:(BOOL)thumbnail completion:(void (^)(NSDictionary *data, UIImage *image))completion {
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset targetSize:CGSizeMake(thumbnail?100.0:asset.pixelWidth, thumbnail?100.0:asset.pixelHeight) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage* image, NSDictionary *info) {
        completion(info, image);
        
    }];
    
}

-(void)imagesRetriveAlbums:(void (^)(NSArray *albums))completion {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    PHFetchOptions *options = [PHFetchOptions new];
    options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:options];
    [albums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
        [output addObject:collection.localizedTitle];
        
    }];
    
    completion(output);
    
}

-(void)uploadImageWithCaption:(UIImage *)image caption:(NSString *)caption {
    NSDateFormatter *formatdate = [[NSDateFormatter alloc] init];
    [formatdate setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    NSMutableString *formatdata = [[NSMutableString alloc] init];
    [formatdata appendString:@"data:image/jpeg;base64,"];
    [formatdata appendString:[UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:0]];
    NSString *formatid = [NSString stringWithFormat:@"%d" ,(int)[[NSDate date] timeIntervalSince1970]];
    NSString *endpoint = [NSString stringWithFormat:@"%@postsApi/addPost/" ,APP_HOST_URL];
    NSString *endpointmethod = @"POST";
    NSDictionary *endpointparams = @{@"username":self.credentials.userHandle,
                                     @"name":caption,
                                     @"last_sectotal":@(0),
                                     @"sectotal":@(0),
                                     @"channel":@"",
                                     @"foto":formatdata,
                                     @"fontSize":@"12",
                                     @"posted_datetime":[formatdate stringFromDate:[NSDate date]],
                                     @"id":formatid,
                                     @"comments":@[]};
    
    NSLog(@"json: %@" ,endpointparams);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:40];
    [request setHTTPMethod:endpointmethod];
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:endpointparams options:NSJSONWritingPrettyPrinted error:nil]];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    
    [task resume];
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)currentTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if ([self.delegate respondsToSelector:@selector(imageUploadedBytesWithPercentage:)]) {
        [self.delegate imageUploadedBytesWithPercentage:((double)totalBytesWritten / (double)totalBytesExpectedToWrite)];
        
    }

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error == nil) {
        if ([self.delegate respondsToSelector:@selector(imageUploadedWithErrors:)]) {
            [self.delegate imageUploadedBytesWithPercentage:0.9];
            [self.query cacheDestroy:@"postsApi/getAllFriendsPostsNext"];
            [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
                [self.delegate imageUploadedBytesWithPercentage:1.0];
                [self.delegate imageUploadedWithErrors:[NSError errorWithDomain:@"no errors" code:200 userInfo:nil]];

            }];
            
        }
        
    }
    else {
        if ([self.delegate respondsToSelector:@selector(imageUploadedWithErrors:)]) {
            [self.delegate imageUploadedWithErrors:error];
            
        }
        
    }
    NSLog(@"Error: %@" ,error);
        
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)download didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"Completed!");
    if ([self.delegate respondsToSelector:@selector(imageUploadedWithErrors:)]) {
        [self.delegate imageUploadedBytesWithPercentage:0.85];
        [self.query cacheDestroy:@"postsApi/getAllFriendsPostsNext"];
        [self.query queryTimeline:BQueryTimelineFriends page:0 completion:^(NSArray *posts, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.delegate imageUploadedBytesWithPercentage:1.0];
                [self.delegate imageUploadedWithErrors:[NSError errorWithDomain:@"no errors" code:200 userInfo:nil]];
                
            }];
            
        }];
        
    }
    
}

@end
