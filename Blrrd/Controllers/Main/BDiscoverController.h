//
//  BDiscoverController.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImage+BlurEffects.h>

#import "BProfileHeader.h"
#import "BCredentialsObject.h"
#import "BQueryObject.h"
#import "BProfileContainerCell.h"

@protocol BDiscoverDelegate;
@interface BDiscoverController : UITableViewController <UITableViewDelegate, UITableViewDataSource, BProfileHeaderDelegate, BProfileContainerDelegate>

@property (nonatomic, strong) id <BDiscoverDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *myposts;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSMutableArray *suggested;
@property (nonatomic, strong) NSMutableArray *requests;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) BProfileHeader *header;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;

-(void)viewSetupNotification:(NSArray *)notification limit:(int)limit;
-(void)viewSetupRequests:(NSArray *)requests limit:(int)limit;

@end

@protocol BDiscoverDelegate <NSObject>

@optional

-(void)viewPresentProfile;
-(void)viewPresentSettings;
-(void)viewPresentFriends;
-(void)viewPresentFriendProfile:(NSDictionary *)data;
-(void)viewPresentImageWithData:(NSDictionary *)data;
@end

