//
//  BFriendFinderController.h
//  Blrrd
//
//  Created by Joe Barbour on 08/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mixpanel/Mixpanel.h>

#import "BNavigationView.h"
#import "BSearchView.h"
#import "GDPlaceholderView.h"

#import "BQueryObject.h"
#import "BCredentialsObject.h"
#import "BContactsObject.h"
#import "BFollowAction.h"
#import "BDetailedTimelineController.h"
#import "BFriendCell.h"
#import "BSettingsUserEditController.h"
#import "BFriendHeader.h"

@protocol BFriendFinderDelegate;
@interface BFriendFinderController : UIViewController <UITableViewDelegate, UITableViewDataSource, BNavigationDelegate, BSearchViewDelegate, BFollowActionDelegate, GDPlaceholderDelegate, BDetailedTimelineDelegate, BFriendDelegateCell, BFriendHeaderDelegate>

@property (nonatomic, strong) id <BFriendFinderDelegate> delegate;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BContactsObject *contacts;
@property (nonatomic, strong) Mixpanel *mixpanel;

@property (nonatomic, strong) NSMutableArray *suggested;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSString *header;
@property (nonatomic) BOOL signup;
@property (nonatomic) BOOL contactgrantauthrization;

@property (nonatomic, strong) BNavigationView *viewNavigation;
@property (nonatomic, strong) UITableView *viewTable;
@property (nonatomic, strong) GDPlaceholderView *viewPlaceholder;
@property (nonatomic, strong) BSearchView *viewSearch;
@property (nonatomic, strong) UIView *viewContacts;
@property (nonatomic, strong) BFriendHeader *viewHeader;

@end

@protocol BFriendFinderDelegate <NSObject>

@optional

-(void)viewPresentSubviewWithIndex:(int)index animated:(BOOL)animated;

@end
