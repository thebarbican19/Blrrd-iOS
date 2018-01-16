//
//  BSettingsController.h
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import <UIImageView+WebCache.h>
#import <Mixpanel.h>
#import "BNavigationView.h"
#import "GDActionSheet.h"

#import "BCredentialsObject.h"
#import "BQueryObject.h"

@interface BSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate,  BNavigationDelegate ,GDActionSheetDelegate>

@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic) SFSafariViewController *safari;

@property (nonatomic, strong) BNavigationView *viewNavigation;
@property (nonatomic, strong) UITableView *viewTable;
@property (nonatomic, strong) GDActionSheet *viewSheet;

@end
