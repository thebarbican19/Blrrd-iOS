//
//  BFriendFinderController.h
//  Blrrd
//
//  Created by Joe Barbour on 08/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNavigationView.h"
#import "BSearchView.h"
#import "GDPlaceholderView.h"

#import "BQueryObject.h"
#import "BCredentialsObject.h"
#import "BFollowAction.h"

@interface BFriendFinderController : UIViewController <UITableViewDelegate, UITableViewDataSource, BNavigationDelegate, BSearchViewDelegate, GDPlaceholderDelegate>

@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) BCredentialsObject *credentials;

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, assign) BOOL signup;

@property (nonatomic, strong) BNavigationView *viewNavigation;
@property (nonatomic, strong) UITableView *viewTable;
@property (nonatomic, strong) GDPlaceholderView *viewPlaceholder;
@property (nonatomic, strong) BSearchView *viewSearch;

@end
