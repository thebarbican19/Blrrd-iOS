//
//  BLocationObject.m
//  Blrrd
//
//  Created by Joe Barbour on 20/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import "BLocationObject.h"
#import "BConstants.h"

@implementation BLocationObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.manager = [[CLLocationManager alloc]init];
        self.geocoder = [[CLGeocoder alloc] init];
        
    }
    
    return self;
    
}

-(void)returnGeolocation:(float)latitude longitude:(float)longitude completion:(void (^)(CLPlacemark *loation))completion {
    [self.geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.lastObject;
        completion(placemark);
        
    }];
    
}

@end
