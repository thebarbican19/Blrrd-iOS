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

typedef NS_ENUM(NSInteger, BNotificationMergeType) {
    BNotificationMergeTypePosts,
    BNotificationMergeTypeUniqueUsers,
    BNotificationMergeTypeUniqueUsersAndPosts
    
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
-(void)authenticationDestroy:(void (^)(NSError *error))completion;

-(void)queryTimeline:(BQueryTimeline)type page:(int)page completion:(void (^)(NSArray *posts, NSError *error))completion;
-(void)queryUserPosts:(NSString *)username page:(int)page completion:(void (^)(NSArray *items, NSError *error))completion;
-(void)queryNotifications:(void (^)(NSArray *notifications, NSError *error))completion;
-(void)queryRequests:(void (^)(NSArray *requests, NSError *error))completion;
-(void)querySuggestedUsers:(NSString *)search completion:(void (^)(NSArray *users, NSError *error))completion;
-(void)queryFriends:(NSString *)type completion:(void (^)(NSArray *users, NSError *error))completion;
-(void)queryUserStats:(void (^)(NSError *error))completion;

-(void)postTime:(NSDictionary *)image secondsadded:(int)seconds timeline:(BQueryTimeline)timeline completion:(void (^)(NSError *error))completion;
-(void)postRequest:(NSString *)user request:(NSString *)request completion:(void (^)(NSError *error))completion;
-(void)postReport:(NSString *)item message:(NSString *)message completion:(void (^)(NSError *error))completion;

-(NSArray *)friendsList;

-(NSArray *)notificationsMergeByType:(BNotificationMergeType)type;
-(NSArray *)notificationsForSpecificImage:(NSString *)identifyer;

-(id)cacheRetrive:(NSString *)endpoint;
-(BOOL)cacheExpired:(NSString *)endpoint;
-(void)cacheDestroy:(NSString *)endpoint;
-(void)cacheUpdatePostWithData:(NSDictionary *)data endpoint:(NSString *)endpoint;

@end

@protocol BQueryDelegate <NSObject>

@optional

-(void)viewCheckAuthenticaion;

@end
