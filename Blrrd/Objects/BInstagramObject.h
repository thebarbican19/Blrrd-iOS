//
//  BInstagramObject.h
//  Blrrd
//
//  Created by Joe Barbour on 18/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mixpanel.h>

#import "BCredentialsObject.h"

@interface BInstagramObject : NSObject

@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) Mixpanel *mixpanel;

-(void)queryInstagramProfile:(void (^)(NSDictionary *profile))completion;
-(void)queryFrendshipStatus:(NSString *)user completion:(void (^)(BOOL connected))completion;
-(void)queryFriends:(void (^)(NSArray *contacts))completion;

-(void)updateFriendship:(NSString *)user action:(NSString *)action completion:(void (^)(NSError *error))completion;

@end
