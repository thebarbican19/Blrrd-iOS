//
//  BFriendFinderController.m
//  Blrrd
//
//  Created by Joe Barbour on 08/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BFriendFinderController.h"
#import "BConstants.h"
#import "BCompleteController.h"

@interface BFriendFinderController ()

@end

@implementation BFriendFinderController

-(void)viewDidAppear:(BOOL)animated {
    if (self.signup) [self.viewNavigation navigationRightButton:NSLocalizedString(@"Onboarding_ActionSkip_Text", nil)];
    
    [self.viewNavigation navigationBackButtonDisabled:self.signup];
    [self.viewNavigation navigationTitle:self.header];
    [self.viewTable reloadData];
    [self.credentials setFriendsAdded:true];
    
    if (self.contacts.contactsAuthorized || self.contactgrantauthrization) {
        [self viewQueryContactsData];
        
        [self.viewHeader setType:BFriendHeaderTypeLoading];
        [self.viewHeader headerset:NSLocalizedString(@"Friend_StatusLoading_Text", nil) animated:false];
        
    }
    else {
        [self.viewHeader setType:BFriendHeaderTypeFindContacts];
        [self.viewHeader headerset:NSLocalizedString(@"Friend_StatusFindContacts_Text", nil) animated:false];
        
    }
    
}
    
-(void)viewQueryContactsData {
    [self.contacts contactsGrantAccess:^(bool granted, NSError *error) {
        if (granted) {
            [self.contacts contactsReturn:false completion:^(NSArray *contacts, int count) {
                NSMutableArray *emails = [[NSMutableArray alloc] init];
                NSMutableArray *contactslist = [[NSMutableArray alloc] init];
                for (NSDictionary *contact in contacts) {
                    for (NSDictionary *email in [contact objectForKey:@"contact_email"]) {
                        if (![emails containsObject:[[email objectForKey:@"address"] lowercaseString]]) {
                            [emails addObject:[[email objectForKey:@"address"] lowercaseString]];
                            
                        }
                        
                    }
                    
                    for (NSDictionary *phone in [contact objectForKey:@"contact_phone"]) {
                        if (![emails containsObject:[phone objectForKey:@"number"]]) {
                            [emails addObject:[phone objectForKey:@"number"]];
                            
                        }
                        
                    }
                    
                    [contactslist addObject:contact];
                    
                }
                
                [self.query querySuggestedUsers:nil emails:emails completion:^(NSArray *users, NSError *error) {
                    self.friends = [[NSMutableArray alloc] init];
                    for (NSDictionary *user in users) {
                        NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:user];
                        for (NSDictionary *contact in contactslist) {
                            for (NSDictionary *emaildata in [contact objectForKey:@"contact_email"]) {
                                if ([[emaildata objectForKey:@"address"] isEqualToString:[user objectForKey:@"email"]]) {
                                    if ([contact objectForKey:@"contact_name"] != nil) {
                                        [append setObject:[contact objectForKey:@"contact_name"] forKey:@"fullname"];
                                        
                                    }
                                    
                                    if ([contact objectForKey:@"contact_thumbnail"] != nil && [[user objectForKey:@"avatar"] length] == 0) {
                                        [append setObject:[contact objectForKey:@"contact_thumbnail"] forKey:@"avatar"];
                                        
                                    }
                                    
                                    break;
                                    
                                }
                                
                            }
                            
                            for (NSDictionary *phonedata in [contact objectForKey:@"contact_phone"]) {
                                if ([[phonedata objectForKey:@"number"] isEqualToString:[user objectForKey:@"phone"]]) {
                                    if ([contact objectForKey:@"contact_name"] != nil) {
                                        [append setObject:[contact objectForKey:@"contact_name"] forKey:@"fullname"];
                                        
                                    }
                                    
                                    if ([contact objectForKey:@"contact_thumbnail"] != nil && [[user objectForKey:@"avatar"] length] == 0) {
                                        [append setObject:[contact objectForKey:@"contact_thumbnail"] forKey:@"avatar"];
                                        
                                    }
                                    
                                    break;
                                    
                                }
                                
                            }
                            
                        }
                        
                        [self.friends addObject:append];
                        
                    }
                    if (error.code == 200) [self viewSetupSections];
                    
                }];
                
                [self viewSetupSections];
                
            }];
            
        }
        
    }];

}

-(void)viewHeaderTapped:(BFriendHeaderType)type {
    if (type == BFriendHeaderTypeFindContacts) {
        if ([self.credentials userPhone:false] == nil) {
            BSettingsUserEditController *viewPhoneadd = [[BSettingsUserEditController alloc] init];
            viewPhoneadd.friendfinder = true;
            viewPhoneadd.signup = self.signup;
            viewPhoneadd.type = GDFormInputTypePhone;
            viewPhoneadd.header = NSLocalizedString(@"Settings_ItemUserphone_Title", nil);
            viewPhoneadd.value = [self.credentials userPhone:true];
            viewPhoneadd.view.backgroundColor = self.view.backgroundColor;
            NSLog(@"phone signup: %@" ,self.signup?@"not signup":@"signup");

            [self.navigationController pushViewController:viewPhoneadd animated:true];
            
        }
        else [self viewQueryContactsData];
       
    }
    else if (type == BFriendHeaderTypeShare) {
        NSArray *shareitems = @[NSLocalizedString(@"Settings_Share_Body", nil), [NSURL URLWithString:@"http://blrrd.co"]];
        UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:shareitems applicationActivities:nil];
        [super presentViewController:share animated:true completion:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
            [self.mixpanel track:@"App Settings Shared"];
            
        }];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self viewDownloadContent:false];

}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    if (button.tag == 0) [self.navigationController popToRootViewControllerAnimated:true];
    else {
        BCompleteController *viewComplete = [[BCompleteController alloc] init];
        viewComplete.type = BCompleteScreenSignup;
        
        [self.navigationController pushViewController:viewComplete animated:true];
        
    }
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0x140F26);
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.query = [[BQueryObject alloc] init];
    self.query.debug = true;
    
    self.contacts = [[BContactsObject alloc] init];
    
    self.viewNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.name = self.header;
    self.viewNavigation.backdisabled = self.signup;
    self.viewNavigation.delegate = self;
    self.viewNavigation.rightbutton = @"";
    [self.view addSubview:self.viewNavigation];
    
    self.viewSearch  = [[BSearchView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height, self.view.bounds.size.width, 60.0)];
    self.viewSearch.delegate = self;
    self.viewSearch.backgroundColor = [UIColor clearColor];
    self.viewSearch.placeholder = NSLocalizedString(@"Friend_SearchPlaceholder_Text", nil);
    self.viewSearch.loaderRequired = true;
    self.viewSearch.shouldUpdate = true;
    self.viewSearch.keyboard = UIKeyboardTypeAlphabet;
    self.viewSearch.alpha = 1.0;
    [self.view addSubview:self.viewSearch];
    
    self.viewHeader = [[BFriendHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 90.0)];
    self.viewHeader.backgroundColor = [UIColor clearColor];
    self.viewHeader.delegate = self;
    if (![self.credentials appContactsParsed]) self.viewHeader.type = BFriendHeaderTypeFindContacts;
    else self.viewHeader.type = BFriendHeaderTypeShare;

    self.viewTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height + self.viewSearch.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + self.viewSearch.bounds.size.height + self.viewNavigation.bounds.size.height))];
    self.viewTable.delegate = self;
    self.viewTable.dataSource = self;
    self.viewTable.tableHeaderView = self.viewHeader;
    self.viewTable.separatorColor = [UIColor clearColor];
    self.viewTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewTable];
    [self.viewTable registerClass:[BFriendCell class] forCellReuseIdentifier:@"user"];

    self.viewPlaceholder = [[GDPlaceholderView alloc] initWithFrame:CGRectMake(0.0, self.viewTable.frame.origin.y + self.viewHeader.bounds.size.height, self.viewHeader.bounds.size.width, self.viewTable.bounds.size.height - (self.viewHeader.bounds.size.height))];
    self.viewPlaceholder.delegate = self;
    self.viewPlaceholder.backgroundColor = self.view.backgroundColor;
    self.viewPlaceholder.textcolor = [UIColor whiteColor];
    self.viewPlaceholder.gesture = true;
    self.viewPlaceholder.hidden = true;
    [self.view addSubview:self.viewPlaceholder];
    [self.view sendSubviewToBack:self.viewPlaceholder];
    
    [self.view bringSubviewToFront:self.viewSearch];
    [self.view bringSubviewToFront:self.viewNavigation];

}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    if ([self.viewPlaceholder.key isEqualToString:@"error"]) {
        [self viewDownloadContent:true];
        
    }
    
}

-(void)viewDownloadContent:(BOOL)refresh {
    self.suggested = [[NSMutableArray alloc] init];
    if ([self.query cacheExpired:@"user/suggested.php"]) {
        [self.query querySuggestedUsers:nil emails:nil completion:^(NSArray *users, NSError *error) {
            if (error.code == 200) {
                [self.suggested addObjectsFromArray:users];
               

            }
            else {
                [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Friend_ErrorPlaceholder_Title", nil) instructions:error.domain];
                
            }
            
            [self viewSetupSections];
            
        }];
        
    }
    else {
        [self.suggested addObjectsFromArray:[self.query cacheRetrive:@"user/suggested.php"]];
        [self viewSetupSections];
    
    }
    
}

-(void)viewSetupSections {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.sections = [[NSMutableArray alloc] init];
        if (self.viewSearch.search.text.length > 0) {
            [self.sections addObject:@{@"key":@"suggested", @"title":NSLocalizedString(@"Friend_SectionSearch_Title", nil), @"items":self.suggested}];

        }
        else {
            if ([self.friends count] > 0) {
                [self.sections addObject:@{@"key":@"local", @"title":NSLocalizedString(@"Friend_SectionContacts_Title", nil), @"items":self.friends}];

                [self.viewHeader setType:BFriendHeaderTypeShare];
                [self.viewHeader headerset:NSLocalizedString(@"Friend_StatusShare_Text", nil) animated:true];
                
            }
            else if (self.sections.count == 2) {
                [self.viewHeader setType:BFriendHeaderTypeShare];
                [self.viewHeader headerset:NSLocalizedString(@"Friend_StatusNoFriendsShare_Text", nil) animated:true];
                
            }
            
            if ([self.suggested count] > 0) {
                [self.sections addObject:@{@"key":@"suggested", @"title":NSLocalizedString(@"Friend_SectionSuggested_Title", nil), @"items":self.suggested}];
                
            }
            
        }
    
        if ([self.sections count] > 0) {
            [self.viewTable reloadData];
            [self.viewPlaceholder setHidden:true];
            
        }
        else {
            [self.viewPlaceholder setHidden:false];
            [self.view bringSubviewToFront:self.viewPlaceholder];

        }
        
    }];
    
}

-(void)viewPresentSubviewWithIndex:(int)index animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(viewPresentSubviewWithIndex:animated:)]) {
        [self.delegate viewPresentSubviewWithIndex:index animated:true];
        
    }
    
}

-(void)viewPresentProfile:(NSDictionary *)data {
    BDetailedTimelineController *viewDetailed = [[BDetailedTimelineController alloc] init];
    viewDetailed.view.backgroundColor = self.view.backgroundColor;
    viewDetailed.type = BDetailedViewTypeUserProfile;
    viewDetailed.data = data;
    viewDetailed.delegate = self;
    
    NSLog(@"viewPresentProfile %@" ,data);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.navigationController pushViewController:viewDetailed animated:true];
        
    }];
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSInteger items = [[[self.sections objectAtIndex:section] objectForKey:@"items"] count];
    BSectionHeader *header = [[BSectionHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 35.0)];
    header.name = [[self.sections objectAtIndex:section] objectForKey:@"title"];
    header.tag = section;
    header.backgroundColor = [UIColor clearColor];
    header.hidden = items>0?false:true;
    
    return header;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSInteger items = [[[self.sections objectAtIndex:section] objectForKey:@"items"] count];
    return items>0?60.0:0.0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.sections objectAtIndex:section] objectForKey:@"items"] count];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(BFriendCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.avatar setFrame:CGRectMake(12.0, 12.0, cell.contentView.bounds.size.height - 24.0, cell.contentView.bounds.size.height - 24.0)];
    [cell.avatar.layer setCornerRadius:cell.avatar.bounds.size.height / 2];
    [cell.follow setFrame:CGRectMake(cell.contentView.bounds.size.width - (cell.follow.followSizeUpdate + 60.0), 10.0, cell.follow.followSizeUpdate, cell.contentView.bounds.size.height - 20.0)];
    [cell.user setFrame:CGRectMake(60.0, 0.0, cell.contentView.bounds.size.width - (cell.follow.followSizeUpdate + 130.0), cell.contentView.bounds.size.height)];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[[self.sections objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    BFriendCell *cell = (BFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"user" forIndexPath:indexPath];
    
    if ([self.query friendCheck:[item objectForKey:@"userid"]]) cell.follow.type = BFollowActionTypeFollowed;
    else {
        if ([[item objectForKey:@"follows"] boolValue]) cell.follow.type = BFollowActionTypeFollowBack;
        else cell.follow.type = BFollowActionTypeUnfollowed;

    }
        
    
    [cell.follow followSetType:cell.follow.type animate:false];
    [cell.follow setDelegate:self];
    [cell.follow setIndexPath:indexPath];
    [cell content:item];
    [cell setDelegate:self];

    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
        
}

-(void)searchFieldWasUpdated:(NSString *)query {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    if (query.length > 1) {
        [self.query querySuggestedUsers:query emails:nil completion:^(NSArray *users, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [output addObjectsFromArray:users];
                [self searchSetContent:output error:error];

            }];
            
        }];

    }
    else {
        if ([self.query cacheExpired:@"user/suggested.php"]) {
            [self.query querySuggestedUsers:nil emails:nil completion:^(NSArray *users, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [output addObjectsFromArray:[self.query cacheRetrive:@"user/suggested.php"]];
                    [self searchSetContent:output error:nil];
                    
                }];
                
            }];
            
        }
        else {
            [self searchSetContent:[self.query cacheRetrive:@"user/suggested.php"] error:nil];

        }

    }
    
}

-(void)searchSetContent:(NSArray *)users error:(NSError *)error {
    self.suggested = [[NSMutableArray alloc] initWithArray:users];
    if (self.suggested.count > 0) {
        [self.viewTable setHidden:false];
        [self.viewPlaceholder setHidden:true];
        
    }
    else {
        [self.viewTable setHidden:true];
        [self.viewPlaceholder setHidden:false];
        if (error == nil || error.code == 200) {
            [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Friend_EmptyPlaceholder_Title", nil) instructions:NSLocalizedString(@"Friend_EmptyPlaceholder_Body", nil)];

        }
        else {
            [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Timeline_PlaceholderError_Title", nil) instructions:error.domain];

        }
        
    }
    
    [self viewSetupSections];

    
}

-(void)searchFieldWasPresented:(CGSize)keyboard {
    [self.viewTable setFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height + self.viewSearch.bounds.size.height, self.view.bounds.size.width, self.viewTable.bounds.size.height - keyboard.height)];
    [self.viewPlaceholder setFrame:CGRectMake(0.0, self.viewTable.frame.origin.y, self.viewHeader.bounds.size.width, self.viewTable.bounds.size.height - self.viewHeader.bounds.size.height + self.viewHeader.bounds.size.height)];

}

-(void)searchFieldWasDismissed {
    [self.viewTable setFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height + self.viewSearch.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + self.viewSearch.bounds.size.height + self.viewNavigation.bounds.size.height))];
    [self.viewPlaceholder setFrame:CGRectMake(0.0, self.viewTable.frame.origin.y + self.viewHeader.bounds.size.height, self.viewHeader.bounds.size.width, self.viewTable.bounds.size.height - (self.viewHeader.bounds.size.height))];

}

-(void)searchFieldReturnKeyPressed {
    [self.viewSearch dismiss];
    
}

-(void)followActionWasTapped:(BFollowAction *)action {
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[[[self.sections objectAtIndex:action.indexPath.section] objectForKey:@"items"] objectAtIndex:action.indexPath.row]];
    BFriendCell *cell = (BFriendCell *)[self.viewTable cellForRowAtIndexPath:action.indexPath];

    NSLog(@"button tapped %@ following %@" ,action ,[item objectForKey:@"following"]?@"yes":@"no");

    if ([[item objectForKey:@"following"] boolValue]) {
        [self.query friendsListAppend:[item objectForKey:@"userid"] remove:true];
        [cell.follow followSetType:BFollowActionTypeUnfollowed animate:true];
        [self.query postRequest:[item objectForKey:@"userid"] request:@"delete" completion:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (error.code != 200) {
                    [cell.follow followSetType:BFollowActionTypeFollowed animate:true];
                    [cell.follow setFrame:CGRectMake(cell.contentView.bounds.size.width - (cell.follow.followSizeUpdate + 60.0), 10.0, cell.follow.followSizeUpdate, cell.contentView.bounds.size.height - 20.0)];

                }
            
            }];
            
        }];
        
    }
    else {
        [self.query friendsListAppend:[item objectForKey:@"userid"] remove:false];
        [cell.follow followSetType:BFollowActionTypeFollowed animate:true];
        [self.query postRequest:[item objectForKey:@"userid"] request:@"add" completion:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (error.code != 200) {
                    [cell.follow followSetType:BFollowActionTypeUnfollowed animate:true];
                    [cell.follow setFrame:CGRectMake(cell.contentView.bounds.size.width - (cell.follow.followSizeUpdate + 60.0), 10.0, cell.follow.followSizeUpdate, cell.contentView.bounds.size.height - 20.0)];
                    
                }

            }];
            
        }];
            
    }
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [cell.follow setFrame:CGRectMake(cell.contentView.bounds.size.width - (cell.follow.followSizeUpdate + 60.0), 10.0, cell.follow.followSizeUpdate, cell.contentView.bounds.size.height - 20.0)];
    
    } completion:nil];

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
