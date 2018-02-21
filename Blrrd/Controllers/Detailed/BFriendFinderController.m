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
    else [self.viewNavigation navigationRightButton:NSLocalizedString(@"Timeline_ActionSheetShare_Text", nil)];
    
    [self.viewNavigation navigationBackButtonDisabled:self.signup];
    [self.viewNavigation navigationTitle:self.header];
    [self.viewTable reloadData];
    [self.credentials setFriendsAdded:true];
    
    if (self.contacts.contactsAuthorized || self.contactgrantauthrization || self.credentials.instagramAdded) {
        if (self.contacts.contactsAuthorized || self.contactgrantauthrization) {
            [self viewQueryContactsData];

        }
        
        if (self.credentials.instagramAdded) {
            [self.instagram queryFriends:^(NSArray *contacts) {
                NSMutableArray *socials = [[NSMutableArray alloc] init];
                NSMutableArray *socialsdata = [[NSMutableArray alloc] init];
                for (NSDictionary *handle in contacts) {
                    if (![socials containsObject:[handle objectForKey:@"username"]]) {
                        [socials addObject:[handle objectForKey:@"username"]];
                        
                    }
                    
                    [socialsdata addObject:handle];
                    
                }
                
                if (socialsdata.count > 0) {
                    [self.query querySuggestedUsers:nil emails:nil socials:socials completion:^(NSArray *users, NSError *error) {
                        self.instausers = [[NSMutableArray alloc] init];
                        for (NSDictionary *user in users) {
                            NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:user];
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@" ,[user objectForKey:@"instagram"]];
                            NSDictionary *exitingdata = [[socialsdata filteredArrayUsingPredicate:predicate] firstObject];
                            if (exitingdata != nil) {
                                [append setObject:[exitingdata objectForKey:@"profile_picture"] forKey:@"avatar"];
                                [append setObject:[exitingdata objectForKey:@"full_name"] forKey:@"fullname"];

                            }
                            
                            [self.instausers addObject:append];
                            
                        }
                        
                        if (error.code == 200) [self viewSetupSections];
                        
                    }];
                    
                }
            
            }];
            
        }
        
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
                
                [self.query querySuggestedUsers:nil emails:emails socials:nil completion:^(NSArray *users, NSError *error) {
                    self.localusers = [[NSMutableArray alloc] init];
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
                        
                        [self.localusers addObject:append];
                        
                    }
                    
                    if (error.code == 200) [self viewSetupSections];
                    
                }];
                
                [self viewSetupSections];
                
            }];
            
        }
        
    }];

}

-(void)viewWillAppear:(BOOL)animated {
    [self viewDownloadContent:false];

}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    if (button.tag == 0) [self.navigationController popToRootViewControllerAnimated:true];
    else {
        if (self.signup) {
            BCompleteController *viewComplete = [[BCompleteController alloc] init];
            viewComplete.type = BCompleteScreenSignup;
            
            [self.navigationController pushViewController:viewComplete animated:true];
            
        }
        else {
            NSArray *shareitems = @[NSLocalizedString(@"Settings_Share_Body", nil), [NSURL URLWithString:@"https://apple.co/2nqdvf0"]];
            UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:shareitems applicationActivities:nil];
            [super presentViewController:share animated:true completion:^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
                [self.mixpanel track:@"App Settings Shared"];
                
            }];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
            
        }
        
    }
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColorFromRGB(0x140F26);
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.instagram = [[BInstagramObject alloc] init];
    
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
    
    self.viewTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height + self.viewSearch.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + self.viewSearch.bounds.size.height + self.viewNavigation.bounds.size.height))];
    self.viewTable.delegate = self;
    self.viewTable.dataSource = self;
    self.viewTable.separatorColor = [UIColor clearColor];
    self.viewTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewTable];
    [self.viewTable registerClass:[BFriendCell class] forCellReuseIdentifier:@"user"];

    self.viewPlaceholder = [[GDPlaceholderView alloc] initWithFrame:CGRectMake(0.0, self.viewTable.frame.origin.y, self.view.bounds.size.width, self.viewTable.bounds.size.height)];
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
    self.suggestedusers = [[NSMutableArray alloc] init];
    [self.query querySuggestedUsers:nil emails:nil socials:nil completion:^(NSArray *users, NSError *error) {
        if (error.code == 200) {
            [self.suggestedusers addObjectsFromArray:users];
           

        }
        else {
            [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Friend_ErrorPlaceholder_Title", nil) instructions:error.domain];
            
        }
        
        [self viewSetupSections];
        
    }];
    
}

-(void)viewSetupSections {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.sections = [[NSMutableArray alloc] init];
        self.connections = [[NSMutableArray alloc] init];
        if (self.viewSearch.search.text.length > 0) {
            [self.sections addObject:@{@"key":@"suggested", @"title":NSLocalizedString(@"Friend_SectionSearch_Title", nil), @"items":self.localusers}];

        }
        else {
            NSMutableDictionary *connectioninstagram = [[NSMutableDictionary alloc] init];
            [connectioninstagram setObject:@"friends_instagram_icon" forKey:@"icon"];
            [connectioninstagram setObject:@"instagram" forKey:@"key"];
            [connectioninstagram setObject:NSLocalizedString(@"Friend_ConnectionInstagram_Text", nil) forKey:@"label"];
            if (self.credentials.instagramAdded) {
                [connectioninstagram setObject:[NSNumber numberWithInteger:BFollowActionTypeDisconnect] forKey:@"action"];

            }
            else {
                [connectioninstagram setObject:[NSNumber numberWithInteger:BFollowActionTypeConnect] forKey:@"action"];

            }

            NSMutableDictionary *connectioncontacts = [[NSMutableDictionary alloc] init];
            [connectioncontacts setObject:@"friends_contacts_icon" forKey:@"icon"];
            [connectioncontacts setObject:@"contacts" forKey:@"key"];
            [connectioncontacts setObject:NSLocalizedString(@"Friend_ConnectionContacts_Text", nil) forKey:@"label"];
            if (self.credentials.appContactsParsed) {
                [connectioncontacts setObject:[NSNumber numberWithInteger:BFollowActionTypeConnected] forKey:@"action"];
                
            }
            else {
                [connectioncontacts setObject:[NSNumber numberWithInteger:BFollowActionTypeConnect] forKey:@"action"];
                
            }
            
            [self.connections addObject:connectioninstagram];
            [self.connections addObject:connectioncontacts];
            
            [self.sections addObject:@{@"key":@"connections", @"title":NSLocalizedString(@"Friend_SectionConnectionTypes_Title", nil), @"items":self.connections}];

            if ([self.instausers count] > 0) {
                [self.sections addObject:@{@"key":@"instagram", @"title":NSLocalizedString(@"Friend_SectionInstagram_Title", nil), @"items":self.instausers}];
                
            }
            
            if ([self.localusers count] > 0) {
                [self.sections addObject:@{@"key":@"local", @"title":NSLocalizedString(@"Friend_SectionContacts_Title", nil), @"items":self.localusers}];

            }
            
            if ([self.suggestedusers count] > 0) {
                [self.sections addObject:@{@"key":@"suggested", @"title":NSLocalizedString(@"Friend_SectionSuggested_Title", nil), @"items":self.suggestedusers}];
                
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
    NSString *key = [[self.sections objectAtIndex:indexPath.section] objectForKey:@"key"];
    BFriendCell *cell = (BFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"user" forIndexPath:indexPath];
    
    if ([key isEqualToString:@"connections"]) {
        [cell.user setText:[item objectForKey:@"label"]];
        [cell.avatar setImage:[UIImage imageNamed:[item objectForKey:@"icon"]]];
        [cell.verifyed setHidden:true];
        [cell.follow setType:[[item objectForKey:@"action"] integerValue]];
        
        [UIView animateWithDuration:0.2 animations:^{
            [cell.follow setAlpha:1.0];
            [cell.follow setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            
        }];


    }
    else {
        if ([self.query friendCheck:[item objectForKey:@"userid"]]) cell.follow.type = BFollowActionTypeFollowed;
        else {
            if ([[item objectForKey:@"follows"] boolValue]) cell.follow.type = BFollowActionTypeFollowBack;
            else cell.follow.type = BFollowActionTypeUnfollowed;

        }
        
        [cell content:item];

    }
    
    [cell.follow followSetType:cell.follow.type animate:false];
    [cell.follow setDelegate:self];
    [cell.follow setIndexPath:indexPath];
    [cell setDelegate:self];

    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
        
}

-(void)searchFieldWasUpdated:(NSString *)query {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    if (query.length > 1) {
        [self.query querySuggestedUsers:query emails:nil socials:nil completion:^(NSArray *users, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [output addObjectsFromArray:users];
                [self searchSetContent:output error:error];

            }];
            
        }];

    }
    else {
        [self.query querySuggestedUsers:nil emails:nil socials:nil completion:^(NSArray *users, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [output addObjectsFromArray:[self.query cacheRetrive:@"user/suggested.php"]];
                [self searchSetContent:output error:nil];
                
            }];
            
        }];

    }
    
}

-(void)searchSetContent:(NSArray *)users error:(NSError *)error {
    self.suggestedusers = [[NSMutableArray alloc] initWithArray:users];
    if (self.suggestedusers.count > 0) {
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
    [self.viewPlaceholder setFrame:CGRectMake(0.0, self.viewTable.frame.origin.y, self.view.bounds.size.width, self.viewTable.bounds.size.height)];

}

-(void)searchFieldWasDismissed {
    [self.viewTable setFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height + self.viewSearch.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + self.viewSearch.bounds.size.height + self.viewNavigation.bounds.size.height))];
    [self.viewPlaceholder setFrame:CGRectMake(0.0, self.viewTable.frame.origin.y, self.view.bounds.size.width, self.viewTable.bounds.size.height)];

}

-(void)searchFieldReturnKeyPressed {
    [self.viewSearch dismiss];
    
}

-(void)followActionWasTapped:(BFollowAction *)action {
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:[[[self.sections objectAtIndex:action.indexPath.section] objectForKey:@"items"] objectAtIndex:action.indexPath.row]];
    BFriendCell *cell = (BFriendCell *)[self.viewTable cellForRowAtIndexPath:action.indexPath];
    NSString *key = [[self.sections objectAtIndex:action.indexPath.section] objectForKey:@"key"];

    NSLog(@"pressed: %@ key %@" ,item ,key);

    if ([key isEqualToString:@"connections"]) {
        if ([[item objectForKey:@"key"] isEqualToString:@"instagram"]) {
            if (!self.credentials.instagramAdded) {
                self.safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:INSTARGRAM_AUTH_URL]];
                self.safari.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleDone;
                self.safari.view.tintColor = UIColorFromRGB(0x140F26);
                self.safari.delegate = self;
                
                [self presentViewController:self.safari animated:true completion:^{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
                    
                }];
                
            }
            else {
                [self.credentials setInstagramKey:nil];
                [self.credentials setInstagramToken:nil];
                [self.credentials setInstagramUsername:nil];
                
                [cell.follow followSetType:BFollowActionTypeConnect animate:true];

            }

        }
        
        if ([[item objectForKey:@"key"] isEqualToString:@"contacts"]) {
            if (!self.credentials.appContactsParsed) {
                if ([self.credentials userPhone:false] == nil) {
                    BSettingsUserEditController *viewPhoneadd = [[BSettingsUserEditController alloc] init];
                    viewPhoneadd.friendfinder = true;
                    viewPhoneadd.signup = self.signup;
                    viewPhoneadd.type = GDFormInputTypePhone;
                    viewPhoneadd.header = NSLocalizedString(@"Settings_ItemUserphone_Title", nil);
                    viewPhoneadd.value = [self.credentials userPhone:true];
                    viewPhoneadd.view.backgroundColor = self.view.backgroundColor;
                    
                    [self.navigationController pushViewController:viewPhoneadd animated:true];
                    
                }
                else [self viewQueryContactsData];
                
            }
            NSLog(@"pressed: %@" ,item);
            
        }
        
    }
    else {
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
