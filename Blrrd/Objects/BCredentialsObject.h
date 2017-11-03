//
//  BCredentialsObject.h
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NSString+EmailAddresses.h"

@interface BCredentialsObject : NSObject

@property (nonatomic, strong) NSUserDefaults *data;

-(void)destoryAllCredentials;

-(NSString *)userKey;
-(NSString *)userDisplay;
-(NSString *)userEmail;
-(NSURL *)userAvatar;
-(BOOL)userPublic;

-(BOOL)appRated;
-(BOOL)appOnboarded;

-(NSString *)devicePush;
-(NSString *)deviceIdentifyer;
-(BOOL)devicePushUploaded;


-(void)setDeviceIdentifyer;
-(void)setDevicePush:(NSString *)push;
-(void)setDeviceUploaded:(BOOL)uploaded;

-(void)setAppOnboarded:(BOOL)onboarded;
-(void)setAppRated:(BOOL)rated;

-(void)setUserEmail:(NSString *)email;
-(void)setUserIdentifyer:(NSString *)key;
-(void)setUserHandle:(NSString *)handle;
-(void)setUserAvatar:(NSString *)url;
-(void)setUserPublic:(BOOL)yes;

@end
