//
//  BCredentialsObject.h
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Mixpanel.h>

#import "NSString+EmailAddresses.h"

@interface BCredentialsObject : NSObject

@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) Mixpanel *mixpanel;

-(void)destoryAllCredentials;

-(NSString *)authToken;
-(NSDate *)authExpiry;

-(NSString *)userKey;
-(NSString *)userHandle;
-(NSString *)userEmail;
-(NSString *)userType;
-(NSURL *)userAvatar;
-(BOOL)userPublic;
-(int)userTotalTime;
-(NSString *)userTotalTimeFormatted;
-(int)userPosts;

-(BOOL)appRated;
-(BOOL)appOnboarded;
-(BOOL)appSaveImages;

-(NSString *)devicePush;
-(NSString *)deviceIdentifyer;
-(BOOL)devicePushUploaded;

-(void)setDeviceIdentifyer;
-(void)setDevicePush:(NSString *)push;
-(void)setDeviceUploaded:(BOOL)uploaded;

-(void)setAuthToken:(NSString *)token;
-(void)setAuthExpiry:(NSString *)expiry;

-(void)setAppOnboarded:(BOOL)onboarded;
-(void)setAppRated:(BOOL)rated;
-(void)setAppSaveImages:(BOOL)save;

-(void)setUserType:(NSString *)type;
-(void)setUserEmail:(NSString *)email;
-(void)setUserIdentifyer:(NSString *)key;
-(void)setUserHandle:(NSString *)handle;
-(void)setUserAvatar:(NSString *)url;
-(void)setUserPublic:(BOOL)yes;
-(void)setUserTotalTime:(int)seconds append:(BOOL)append;
-(void)setUserTotalPosts:(int)posts;

@end
