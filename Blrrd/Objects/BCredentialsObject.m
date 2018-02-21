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
    [self setUserPhoneNumber:nil];
    [self setUserFullname:nil];
    [self setUserTotalTime:0 append:false];
    [self setAppContactUpdateExpiry:true];
    [self setAuthToken:nil];
    [self setInstagramToken:nil];
    [self setInstagramUsername:nil];
    [self setInstagramKey:nil];

    if (!self.userAdmin) {
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

-(NSString *)userBiography {
    if ([self.data objectForKey:@"user_bio"] != nil) return [self.data objectForKey:@"user_bio"];
    else return nil;
    
}

-(NSString *)userWebsite {
    if ([self.data objectForKey:@"user_website"] != nil) return [self.data objectForKey:@"user_website"];
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

-(void)setUserPhoneNumber:(NSString *)phone  {
    if ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_PHONE] evaluateWithObject:phone])
        [self.data setObject:phone forKey:@"user_phone"];
    else [self.data removeObjectForKey:@"user_phone"];
    
    [self.data synchronize];
    
}

-(void)setUserBirthday:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    [self.data setObject:[formatter stringFromDate:date] forKey:@"user_dob"];
    [self.data synchronize];
    
}

-(BOOL)userPublic {
    return [[self.data objectForKey:@"user_public"] boolValue];

}

-(BOOL)userVerifyed {
    return [[self.data objectForKey:@"user_verifyed"] boolValue];
    
}

-(BOOL)userAdmin {
    if ([[self.data objectForKey:@"user_type"] isEqualToString:@"admin"]) return true;
    else return false;
    
}

-(NSString *)userPhone:(BOOL)countrycode {
    if ([self.data objectForKey:@"user_phone"] != nil) {
        return [[self.data objectForKey:@"user_phone"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
    }
    else {
        if (countrycode) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"CountryCodes" ofType:@"json"];
            NSArray *content = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@" ,APP_COUNTRY_CODE];
            NSDictionary *output = [[content filteredArrayUsingPredicate:predicate] firstObject];
            return [output objectForKey:@"dial_code"];
            
        }
        else return nil;
        
    }
    
}

-(NSString *)userFullname {
    return [self.data objectForKey:@"user_fullname"];
    
}

-(NSDate *)userBirthday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss zzz";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    return [formatter dateFromString:[self.data objectForKey:@"user_dob"]];
    
}

-(int)userGender {
    return [[self.data objectForKey:@"user_gender"] intValue];
    
}

-(int)userTotalTime {
    return [[self.data objectForKey:@"user_total_seconds"] intValue];
    
}

-(int)userTotalRevealedTime {
    return [[self.data objectForKey:@"user_total_revealed"] intValue];

}

-(NSString *)userTotalTimeFormatted {
    if (self.userTotalTime < 60) return [NSString stringWithFormat:@"%01ds" ,self.userTotalTime % 60];
    else return [NSString stringWithFormat:@"%01dm %01ds" ,self.userTotalTime / 60 % 60, self.userTotalTime % 60];
    
}

-(int)userPosts {
    return [[self.data objectForKey:@"user_total_posts"] intValue];

}

-(NSString *)instagramToken {
    return [self.data objectForKey:@"instagram_token"];

}

-(NSString *)instagramHandle {
    return [self.data objectForKey:@"instagram_user"];

}

-(NSString *)instagramKey {
    return [self.data objectForKey:@"instagram_key"];

}

-(BOOL)instagramAdded {
    if (self.instagramToken != nil) return true;
    else return false;
    
}

-(BOOL)appRated {
    return [[self.data objectForKey:@"app_rate"] boolValue];

}

-(BOOL)appOnboarded {
    return [[self.data objectForKey:@"app_onboarding"] boolValue];

}

-(BOOL)appContactsParsed {
    return [[self.data objectForKey:@"app_contactsparsed"] boolValue];

}

-(BOOL)appFriendsAdded {
    return [[self.data objectForKey:@"app_friends"] boolValue];
    
}

-(BOOL)appSaveImages {
    return [[self.data objectForKey:@"app_save_images"] boolValue];

}

-(BOOL)appContactsUpdateExpired {
    NSDate *expiry = [self.data objectForKey:@"app_contact_expiry"];
    if ([[NSDate date] compare:expiry] == NSOrderedDescending || expiry == nil) return true;
    else if ([self.data objectForKey:@"app_contact_expiry"] == nil) return true;
    else return false;
    
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

-(void)setAppContactUpdateExpiry:(BOOL)expire {
    if (expire) [self.data removeObjectForKey:@"app_contact_expiry"];
    else [self.data setObject:[NSDate dateWithTimeIntervalSinceNow:60*60*24*5] forKey:@"app_contact_expiry"];
    
    [self.data synchronize];
    
}

-(void)setAppContactsParsed:(BOOL)parsed {
    [self.data setObject:[NSNumber numberWithBool:parsed] forKey:@"app_contactsparsed"];
    [self.data synchronize];
    
}

-(void)setFriendsAdded:(BOOL)added {
    [self.data setObject:[NSNumber numberWithBool:added] forKey:@"app_friends"];
    [self.data synchronize];
    
}

-(void)setUserBiography:(NSString *)bio {
    if (bio) [self.data setObject:bio forKey:@"user_bio"];
    else [self.data removeObjectForKey:@"user_bio"];
    
    [self.data synchronize];
    
}

-(void)setUserWebsite:(NSString *)website {
    if (website) [self.data setObject:website forKey:@"user_website"];
    else [self.data removeObjectForKey:@"user_website"];
    
    [self.data synchronize];
    
}

-(void)setUserType:(NSString *)type {
    if (type) [self.data setObject:type forKey:@"user_type"];
    else [self.data removeObjectForKey:@"user_type"];
    
    [self.data synchronize];
    
}

-(void)setUserFullname:(NSString *)fullname {
    if (fullname.length > 0) {
        [self.data setObject:fullname forKey:@"user_fullname"];
        [self setUserGender:fullname];
        
    }
    else [self.data removeObjectForKey:@"user_fullname"];
    
    [self.data synchronize];
    
}

-(void)setUserEmail:(NSString *)email {
    if (email.length > 0) [self.data setObject:[email stringByCorrectingEmailTypos] forKey:@"user_email"];
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

-(void)setUserVerifyed:(BOOL)yes {
    [self.data setObject:[NSNumber numberWithBool:yes] forKey:@"user_verifyed"];
    [self.data synchronize];
    
}

-(void)setUserTotalTime:(int)seconds append:(BOOL)append {
    int secondsset = seconds;
    if (append) secondsset += self.userTotalTime;
    
    [self.data setObject:[NSNumber numberWithInt:secondsset] forKey:@"user_total_seconds"];
    [self.data synchronize];

}

-(void)setUserTotalRevealed:(int)seconds append:(BOOL)append {
    int secondsset = seconds;
    if (append) secondsset += self.userTotalRevealedTime;
    
    [self.data setObject:[NSNumber numberWithInt:secondsset] forKey:@"user_total_revealed"];
    [self.data synchronize];
    
}

-(void)setUserTotalPosts:(int)posts {
    [self.data setObject:[NSNumber numberWithInt:posts] forKey:@"user_total_posts"];
    [self.data synchronize];
    
}

-(void)setUserGender:(NSString *)name {
    NSString *firstname = [[name componentsSeparatedByString:@" "] firstObject];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"NamesDetect" ofType:@"json"];
    NSArray *content = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@" ,firstname.capitalizedString];
    NSDictionary *output = [[content filteredArrayUsingPredicate:predicate] firstObject];
    if (output != nil) {
        int sex = 0;
        if ([[output objectForKey:@"sex"] isEqualToString:@"M"]) sex = 1;
        else sex = 2;
        
        [self.data setObject:[NSNumber numberWithInt:sex] forKey:@"user_gender"];
        [self.data synchronize];
        
    }
    
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
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    if (expiry) [self.data setObject:[formatter dateFromString:expiry] forKey:@"auth_expiry"];
    else [self.data removeObjectForKey:@"auth_expiry"];
    
    [self.data synchronize];
    
}

-(void)setInstagramToken:(NSString *)token {
    if (token) [self.data setObject:token forKey:@"instagram_token"];
    else [self.data removeObjectForKey:@"instagram_token"];
    
    [self.data synchronize];
    
}

-(void)setInstagramUsername:(NSString *)user {
    if (user) [self.data setObject:user forKey:@"instagram_user"];
    else [self.data removeObjectForKey:@"instagram_user"];
    
    [self.data synchronize];
    
}

-(void)setInstagramKey:(NSString *)key {
    if (key) [self.data setObject:key forKey:@"instagram_key"];
    else [self.data removeObjectForKey:@"instagram_key"];
    
    [self.data synchronize];
    
}

@end
