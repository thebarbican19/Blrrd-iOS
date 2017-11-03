//
//  BQueryObject.h
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BCredentialsObject.h"

@interface BQueryObject : NSObject

@property (nonatomic, assign) BOOL debug;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) BCredentialsObject *credentials;

-(void)authenticationLoginWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion;
-(void)authenticationSignupWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion;

-(void)queryFriendsTimeline:(int)page completion:(void (^)(NSArray *posts, NSError *error))completion;

@end
