//
//  BAdminStatsController.h
//  Blrrd
//
//  Created by Joe Barbour on 02/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mixpanel.h>
#import "BNavigationView.h"
#import "GDActionSheet.h"
#import "GDPlaceholderView.h"

#import "BCredentialsObject.h"
#import "BQueryObject.h"

@interface BAdminStatsController : UIViewController <UITableViewDelegate, UITableViewDataSource, BNavigationDelegate, GDPlaceholderDelegate>

@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) NSMutableArray *output;
@property (nonatomic, strong) NSString *header;

@property (nonatomic, strong) BNavigationView *viewNavigation;
@property (nonatomic, strong) GDPlaceholderView *viewPlaceholder;
@property (nonatomic, strong) UITableView *viewTable;
@end
