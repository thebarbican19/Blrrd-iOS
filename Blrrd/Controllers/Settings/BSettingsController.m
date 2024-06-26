//
//  BSettingsController.m
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BSettingsController.h"
#import "BConstants.h"
#import "BSectionHeader.h"
#import "BSettingsCell.h"
#import "GDFeedbackController.h"
#import "BDocumentController.h"
#import "BAdminStatsController.h"
#import "BSettingsUserEditController.h"

@interface BSettingsController ()

@end

@implementation BSettingsController

-(NSArray *)viewContents {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSMutableArray *contents = [[NSMutableArray alloc] init];
    if (self.credentials.userAdmin) {
        [contents addObject:@{@"section":@"admin", @"items":@[@{@"key":@"stats", @"switch":@(false)}]}];

    }
    [contents addObjectsFromArray:[NSArray arrayWithContentsOfFile:path]];

    return contents;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self.viewNavigation navigationTitle:NSLocalizedString(@"Settings_Title", nil)];
    [self.viewFooter present:false status:[NSString stringWithFormat:NSLocalizedString(@"Settings_VersionInfomation_Title", nil) ,APP_VERSION, APP_DEBUG_MODE?@"Debug Mode":@"", self.credentials.userAdmin?@"You have admin privileges":@""]];
    [self.mixpanel track:@"App Settings Viewed"];

}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:true];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.mixpanel = [Mixpanel sharedInstance];
    
    self.query = [[BQueryObject alloc] init];
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.view.clipsToBounds = true;
    self.navigationController.navigationBarHidden = true;
    self.navigationController.view.clipsToBounds = true;

    self.viewNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.name = nil;
    self.viewNavigation.delegate = self;
    [self.view addSubview:self.viewNavigation];
    
    self.viewFooter = [[BFooterView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 70.0)];
    self.viewFooter.backgroundColor = [UIColor clearColor];
    self.viewFooter.noformatting = true;
    
    self.viewTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - APP_STATUSBAR_HEIGHT)];
    self.viewTable.delegate = self;
    self.viewTable.dataSource = self;
    self.viewTable.clipsToBounds = true;
    self.viewTable.backgroundColor = [UIColor clearColor];
    self.viewTable.separatorColor = [UIColor clearColor];
    self.viewTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.viewNavigation.bounds.size.height)];
    self.viewTable.tableFooterView = self.viewFooter;
    [self.view addSubview:self.viewTable];
    [self.viewTable registerClass:[BSettingsCell class] forCellReuseIdentifier:@"item"];
    [self.view bringSubviewToFront:self.viewNavigation];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BSectionHeader *header = [[BSectionHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 35.0)];
    NSDictionary *item = [self.viewContents objectAtIndex:section];
    NSString *key = [item objectForKey:@"section"];
    NSString *localized = [NSString stringWithFormat:@"Settings_Section%@_Title" ,key.capitalizedString];
    header.name = NSLocalizedString(localized, nil);
    header.tag = section;
    header.backgroundColor = [UIColor clearColor];
    if (section == self.viewContents.count - 1) header.hidden = true;
    else header.hidden = false;
    return header;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[self.viewContents objectAtIndex:section] count] == 0) return 0.0;
    else if (section == self.viewContents.count - 1) return 30.0;
    else return 60.0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewContents count];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.viewContents objectAtIndex:section] objectForKey:@"items"] count];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(BSettingsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[[self.viewContents objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    NSString *key = [item objectForKey:@"key"];
    if ([key isEqualToString:@"logout"] || [key isEqualToString:@"cache"]) {
        [cell.name setFrame:CGRectMake(20.0, 5.0, cell.contentView.bounds.size.width - 40.0, cell.contentView.bounds.size.height - 10.0)];

    }
    else {
        [cell.name setFrame:CGRectMake(20.0, 5.0, cell.contentView.bounds.size.width / 2, cell.contentView.bounds.size.height - 10.0)];

    }
    
    [cell.toggle setFrame:CGRectMake(cell.contentView.bounds.size.width - 76.0, (cell.contentView.bounds.size.height / 2) - (31.0 / 2), 51.0, 31.0)];
    [cell.accessory setFrame:CGRectMake(cell.contentView.bounds.size.width - 58.0, 0.0, 51.0, cell.contentView.bounds.size.height)];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[[self.viewContents objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    NSString *key = [item objectForKey:@"key"];
    BOOL toggle = [[item objectForKey:@"switch"] boolValue];
    NSString *localized = [NSString stringWithFormat:@"Settings_Item%@_Title" ,key.capitalizedString];

    BSettingsCell *cell = (BSettingsCell *)[tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    
    [cell.name setText:NSLocalizedString(localized, nil)];
    [cell.toggle setHidden:!toggle];
    [cell.toggle addTarget:self action:@selector(tableViewSwitch:) forControlEvents:UIControlEventValueChanged];
    
    if ([key isEqualToString:@"saveimages"]) [cell.toggle setOn:self.credentials.appSaveImages];
    
    if ([key isEqualToString:@"logout"]) {
        [cell.name setTextAlignment:NSTextAlignmentCenter];
        [cell.name setBackgroundColor:UIColorFromRGB(0x69DCCB)];
        [cell.name setFont:[UIFont fontWithName:@"Nunito-Black" size:12]];
        [cell.name setTextColor:UIColorFromRGB(0x140F26)];
        [cell.name setText:cell.name.text.uppercaseString];
        [cell.accessory setHidden:true];
        
    }
    else if ([key isEqualToString:@"cache"]) {
        [cell.name setTextAlignment:NSTextAlignmentCenter];
        [cell.name setBackgroundColor:[UIColor clearColor]];
        [cell.name setTextColor:[UIColor whiteColor]];
        [cell.accessory setHidden:true];

    }
    else {
        [cell.name setTextAlignment:NSTextAlignmentLeft];
        [cell.name setBackgroundColor:[UIColor clearColor]];
        [cell.name setTextColor:[UIColor whiteColor]];
        [cell.name setFont:[UIFont fontWithName:@"Nunito-SemiBold" size:14]];
        [cell.accessory setHidden:toggle];

    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if (!toggle) [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BSettingsCell *cell = (BSettingsCell *)[self.viewTable cellForRowAtIndexPath:indexPath];
    NSDictionary *item = [[[self.viewContents objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    NSString *key = [item objectForKey:@"key"];
    NSString *localized = [NSString stringWithFormat:@"Settings_Item%@_Title" ,key.capitalizedString];

    if ([key isEqualToString:@"stats"]) {
        BAdminStatsController *viewStats = [[BAdminStatsController alloc] init];
        viewStats.header = NSLocalizedString(localized, nil);
        viewStats.view.clipsToBounds = true;
        viewStats.view.backgroundColor = self.view.backgroundColor;

        [self.navigationController pushViewController:viewStats animated:true];
        
    }
    
    if ([key containsString:@"user"]) {
        BSettingsUserEditController *viewUser = [[BSettingsUserEditController alloc] init];
        viewUser.header = NSLocalizedString(localized, nil);
        
        if ([key containsString:@"email"]) {
            viewUser.type = GDFormInputTypeEmail;
            viewUser.value = [self.credentials userEmail];
            
        }
        else if ([key containsString:@"phone"]) {
            viewUser.type = GDFormInputTypePhone;
            viewUser.value = [self.credentials userPhone:true];

        }
        else if ([key containsString:@"password"]) {
            viewUser.type = GDFormInputTypePassword;
            viewUser.value = nil;

        }
        else if ([key containsString:@"display"]) {
            viewUser.type = GDFormInputTypeDisplay;
            viewUser.value = [self.credentials userFullname];
            
        }
        
        viewUser.view.clipsToBounds = true;
        viewUser.view.backgroundColor = self.view.backgroundColor;
        
        [self.navigationController pushViewController:viewUser animated:true];
        
    }
    
    if ([key isEqualToString:@"instagram"]) {
        self.safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:INSTARGRAM_AUTH_URL]];
        self.safari.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleDone;
        self.safari.view.tintColor = UIColorFromRGB(0x140F26);
        self.safari.delegate = self;
        
        [self presentViewController:self.safari animated:true completion:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
            
        }];
        
    }
    
    if ([key isEqualToString:@"permissions"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
            
        }];

    }
    
    if ([key isEqualToString:@"share"]) {
        NSArray *shareitems = @[NSLocalizedString(@"Settings_Share_Body", nil), [NSURL URLWithString:@"https://apple.co/2nqdvf0"]];
        UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:shareitems applicationActivities:nil];
        [super presentViewController:share animated:true completion:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
            [self.mixpanel track:@"App Settings Shared"];
            
        }];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
        
    }
    
    if ([key isEqualToString:@"feedback"]) {
        GDFeedbackController *viewFeedback = [[GDFeedbackController alloc] init];
        viewFeedback.header = NSLocalizedString(localized, nil);
        viewFeedback.type = @"In-App Feedback";
        viewFeedback.placeholder = NSLocalizedString(@"Settings_FeedbackPlaceholder_Text", nil);
        
        [self.navigationController pushViewController:viewFeedback animated:true];
        
    }
    
    if ([key isEqualToString:@"terms"]) {
        BDocumentController *viewDocument = [[BDocumentController alloc] init];
        viewDocument.header = NSLocalizedString(localized, nil);
        viewDocument.file = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"pdf"];
        
        [self.mixpanel track:@"App Terms & Conditions Viewed"];
        [self.navigationController pushViewController:viewDocument animated:true];

    }
    
    if ([key isEqualToString:@"cache"]) {
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
        
        [self.query cacheDestroy:nil];
        [self.mixpanel track:@"App Cache Manually Destroyed"];
        [UIView animateWithDuration:0.2 animations:^{
            [cell.name setAlpha:0.6];
            [cell.name setText:NSLocalizedString(@"Settings_ItemCacheDestroyed_Title", nil)];
            
        }];
        
    }
    
    if ([key isEqualToString:@"logout"]) {
        [self.query authenticationDestroy:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.navigationController popViewControllerAnimated:true];
                
            }];

        }];

    }
    
    [self.viewTable deselectRowAtIndexPath:indexPath animated:true];

}

-(void)tableViewSwitch:(UISwitch *)sender {
    NSIndexPath *index = [self.viewTable indexPathForRowAtPoint:[sender convertPoint:CGPointZero toView:self.viewTable]];
    NSDictionary *item = [[[self.viewContents objectAtIndex:index.section] objectForKey:@"items"] objectAtIndex:index.row];
    NSString *key = [item objectForKey:@"key"];
    
    if ([key isEqualToString:@"saveimages"]) {
        [self.credentials setAppSaveImages:sender.on];
        
    }
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
    
}

-(BOOL)prefersStatusBarHidden {
    return false;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
    
}


@end
