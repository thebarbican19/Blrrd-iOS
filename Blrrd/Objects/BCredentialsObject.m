//
//  BCredentialsObject.m
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BCredentialsObject.h"
#import "BConstants.h"

@implementation BCredentialsObject


-(instancetype)init {
    self = [super init];
    if (self) {
        self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.mixpanel = [Mixpanel sharedInstance];

    }
    return self;
    
}

-(void)destoryAllCredentials {
    [self setUserEmail:nil];
    [self setUserHandle:nil];
    [self setUserIdentifyer:nil];
    [self setUserTotalTime:0 append:false];

    if (!APP_DEBUG_MODE) {
        [self.mixpanel track:@"App Logged Out"];
        [self.mixpanel.people set:@{@"$email":@"", @"$name":@""}];
        
    }
    
}

-(NSString *)devicePush {
    return [self.data objectForKey:@"device_token"];
    
}

-(NSString *)deviceIdentifyer {
    return [self.data objectForKey:@"device_identifyer"];
    
}

-(BOOL)devicePushUploaded {
    return [[self.data objectForKey:@"device_uploaded"] boolValue];
    
}

-(NSString *)authToken {
    if ([self.data objectForKey:@"auth_token"] != nil) return [self.data objectForKey:@"auth_token"];
    else return nil;
    
}

-(NSDate *)authExpiry {
    if ([self.data objectForKey:@"auth_expiry"] != nil) return [self.data objectForKey:@"auth_expiry"];
    else return nil;
    
}

-(NSString *)userKey {
    if ([self.data objectForKey:@"user_key"] != nil) return [self.data objectForKey:@"user_key"];
    else return nil;
    
}

-(NSString *)userHandle {
    if ([self.data objectForKey:@"user_handle"] != nil) return [self.data objectForKey:@"user_handle"];
    else return nil;
    
}

-(NSString *)userType {
    if ([self.data objectForKey:@"user_type"] != nil) return [self.data objectForKey:@"user_type"];
    else return nil;
    
}

-(NSString *)userEmail {
    if ([self.data objectForKey:@"user_email"] != nil) return [self.data objectForKey:@"user_email"];
    else return nil;
    
}

-(NSURL *)userAvatar {
    if ([self.data objectForKey:@"user_avatar"] != nil) return [NSURL URLWithString:[self.data objectForKey:@"user_avatar"]];
    else return nil;
    
}

-(BOOL)userPublic {
    return [[self.data objectForKey:@"user_public"] boolValue];

}

-(int)userTotalTime {
    return [[self.data objectForKey:@"user_total_seconds"] intValue];
    
}

-(NSString *)userTotalTimeFormatted {
    if (self.userTotalTime < 60) return [NSString stringWithFormat:@"%01ds" ,self.userTotalTime % 60];
    else return [NSString stringWithFormat:@"%01dm %01ds" ,self.userTotalTime / 60 % 60, self.userTotalTime % 60];
    
}

-(int)userPosts {
    return [[self.data objectForKey:@"user_total_posts"] intValue];

}


-(BOOL)appRated {
    return [[self.data objectForKey:@"app_rate"] boolValue];

}

-(BOOL)appOnboarded {
    return [[self.data objectForKey:@"app_onboarding"] boolValue];

}

-(BOOL)appSaveImages {
    return [[self.data objectForKey:@"app_save_images"] boolValue];

}

-(void)setDeviceIdentifyer {
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    [self.data setObject:uuidString forKey:@"device_identifyer"];
    [self.data synchronize];
    
}

-(void)setDevicePush:(NSString *)push {
    if (push) [self.data setObject:push forKey:@"device_token"];
    else [self.data removeObjectForKey:@"device_token"];
    [self.data synchronize];
    
}

-(void)setDeviceUploaded:(BOOL)uploaded {
    [self.data setObject:[NSNumber numberWithBool:uploaded] forKey:@"device_uploaded"];
    [self.data synchronize];
    
}


-(void)setAppOnboarded:(BOOL)onboarded {
    [self.data setObject:[NSNumber numberWithBool:onboarded] forKey:@"app_onboarding"];
    [self.data synchronize];
    
}

-(void)setAppRated:(BOOL)rated {
    [self.data setObject:[NSNumber numberWithBool:rated] forKey:@"app_rate"];
    [self.data synchronize];
    
}

-(void)setAppSaveImages:(BOOL)save {
    [self.data setObject:[NSNumber numberWithBool:save] forKey:@"app_save_images"];
    [self.data synchronize];
    
}

-(void)setUserType:(NSString *)type {
    if (type) [self.data setObject:type forKey:@"user_type"];
    else [self.data removeObjectForKey:@"user_type"];
    
    [self.data synchronize];
    
}

-(void)setUserEmail:(NSString *)email {
    if (email) [self.data setObject:[email stringByCorrectingEmailTypos] forKey:@"user_email"];
    else [self.data removeObjectForKey:@"user_email"];
    
    [self.data synchronize];
    
}

-(void)setUserIdentifyer:(NSString *)key {
    if (key) [self.data setObject:key forKey:@"user_key"];
    else [self.data removeObjectForKey:@"user_key"];
    
    [self.data synchronize];
    
}

-(void)setUserHandle:(NSString *)handle {
    if (handle) [self.data setObject:handle forKey:@"user_handle"];
    else [self.data removeObjectForKey:@"user_handle"];
    
    [self.data synchronize];
    
}

-(void)setUserAvatar:(NSString *)url {
    if (url) [self.data setObject:url forKey:@"user_avatar"];
    else [self.data removeObjectForKey:@"user_avatar"];
    
    [self.data synchronize];
    
}

-(void)setUserPublic:(BOOL)yes {
    [self.data setObject:[NSNumber numberWithBool:yes] forKey:@"user_public"];
    [self.data synchronize];
    
}

-(void)setUserTotalTime:(int)seconds append:(BOOL)append {
    int secondsset = seconds;
    if (append) secondsset += self.userTotalTime;
    
    [self.data setObject:[NSNumber numberWithInt:secondsset] forKey:@"user_total_seconds"];
    [self.data synchronize];

}

-(void)setUserTotalPosts:(int)posts {
    [self.data setObject:[NSNumber numberWithInt:posts] forKey:@"user_total_posts"];
    [self.data synchronize];
    
}

-(void)setAuthToken:(NSString *)token {
    if (token) [self.data setObject:token forKey:@"auth_token"];
    else [self.data removeObjectForKey:@"auth_token"];
    
    [self.data synchronize];
    
}

-(void)setAuthExpiry:(NSString *)expiry {
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone defaultTimeZone];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    if (expiry) [self.data setObject:[formatter dateFromString:expiry] forKey:@"auth_expiry"];
    else [self.data removeObjectForKey:@"auth_expiry"];
    
    [self.data synchronize];
}

@end
