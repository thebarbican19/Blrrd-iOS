//
//  BQueryObject.h
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Mixpanel.h>

#import "BCredentialsObject.h"

typedef NS_ENUM(NSInteger, BQueryTimeline) {
    BQueryTimelineFriends,
    BQueryTimelineTrending,
    BQueryTimelineChannel

};


@protocol BQueryDelegate;
@interface BQueryObject : NSObject

@property (nonatomic, strong) id <BQueryDelegate> delegate;
@property (nonatomic, assign) BOOL debug;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) Mixpanel *mixpanel;

-(void)authenticationLoginWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion;
-(void)authenticationSignupWithCredentials:(NSDictionary *)credentials completion:(void (^)(NSDictionary *user, NSError *error))completion;

-(void)queryTimeline:(BQueryTimeline)type page:(int)page completion:(void (^)(NSArray *posts, NSError *error))completion;
-(void)queryChannels:(void (^)(NSArray *channels, NSError *error))completion;
-(void)queryChannelByIdentifyer:(NSString *)identifyer page:(int)page completion:(void (^)(NSArray *channel, NSError *error))completion;
-(void)queryNotifications:(void (^)(NSArray *notifications, NSError *error))completion;
-(void)queryRequests:(void (^)(NSArray *requests, NSError *error))completion;
-(void)querySuggestedUsers:(void (^)(NSArray *users, NSError *error))completion;

-(void)postTime:(NSDictionary *)image secondsadded:(int)seconds completion:(void (^)(NSError *error))completion;

-(id)cacheRetrive:(NSString *)endpoint;
-(BOOL)cacheExpired:(NSString *)endpoint;
-(void)cacheDestroy;

@end

@protocol BQueryDelegate <NSObject>

@optional

-(void)viewCheckAuthenticaion;

@end
