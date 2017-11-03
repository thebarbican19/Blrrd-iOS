//
//  UIImage+BlurExtension.h
//  http://www.fornextlabs.com
//
//  Created by ForNextLabs on 19/01/16.
//  Copyright © 2016 ForNextLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (UIImageBlurExtension)
- (UIImage *)blurredImage;
- (UIImage *)blurredImageWithRadius:(float)radius;
@end

@implementation UIImage (UIImageBlurExtension)

- (UIImage *)blurredImage
{
    return [self blurredImageWithRadius:5.0f];
}

- (UIImage *)blurredImageWithRadius:(float)radius
{
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    //Make a copy of the image in which to apply the blur effect
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    //Gaussian Blur
    CIFilter *ciFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [ciFilter setValue:inputImage forKey:kCIInputImageKey];
    [ciFilter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    
    CIImage *resultImage = [ciFilter valueForKey:kCIOutputImageKey];
    
    //The blur effect shrinks the image, with the code following we adjust them to the original size
    CGImageRef cgImage = [ciContext createCGImage:resultImage fromRect:[inputImage extent]];
    
    UIImage *adjustedImage = [UIImage imageWithCGImage:cgImage];
    return adjustedImage;
}

@end