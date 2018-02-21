//
//  BLocationObject.h
//  Blrrd
//
//  Created by Joe Barbour on 20/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BLocationObject : NSObject <CLLocationManagerDelegate> 

@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic) CLLocationManager *manager;
@property (nonatomic, strong) CLGeocoder *geocoder;

-(void)returnGeolocation:(float)latitude longitude:(float)longitude completion:(void (^)(CLPlacemark *loation))completion;

@end
