//
//  BFriendFinderController.m
//  Blrrd
//
//  Created by Joe Barbour on 08/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BFriendFinderController.h"
#import "BConstants.h"
#import "BFriendCell.h"

@interface BFriendFinderController ()

@end

@implementation BFriendFinderController

-(void)viewDidAppear:(BOOL)animated {
    [self.viewNavigation navigationTitle:self.header];
    [self.viewTable reloadData];

}

-(void)viewWillAppear:(BOOL)animated {
    [self viewDownloadContent:false];

}

-(void)viewNavigationButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:true];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    self.query.debug = true;
    
    self.viewNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.name = self.header;
    self.viewNavigation.delegate = self;
    self.viewNavigation.rightbutton = self.signup?@"Next":nil;
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
    self.viewTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 15.0)];
    self.viewTable.separatorColor = [UIColor clearColor];
    self.viewTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewTable];
    [self.viewTable registerClass:[BFriendCell class] forCellReuseIdentifier:@"user"];

    self.viewPlaceholder = [[GDPlaceholderView alloc] initWithFrame:self.viewTable.frame];
    self.viewPlaceholder.delegate = self;
    self.viewPlaceholder.backgroundColor = [UIColor clearColor];
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
    self.users = [[NSMutableArray alloc] initWithArray:[self.query cacheRetrive:@"userApi/getAllUsers"]];
    if ([self.query cacheExpired:@"userApi/getAllUsers"] || refresh) {
        [self.query querySuggestedUsers:^(NSArray *users, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (error.code == 200) {
                    [self.users addObjectsFromArray:[self.query cacheRetrive:@"userApi/getAllUsers"]];
                    [self.viewTable reloadData];
                    [self.viewTable setHidden:false];
                    [self.viewPlaceholder setHidden:true];

                }
                else {
                    [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Friend_ErrorPlaceholder_Title", nil) instructions:error.domain];
                    [self.viewTable setHidden:true];
                    [self.viewPlaceholder setHidden:false];
                    
                }
                
            }];
            
        }];
        
    }
    else {
        [self.users addObjectsFromArray:[self.query cacheRetrive:@"userApi/getAllUsers"]];
        [self.viewTable reloadData];
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(BFriendCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.avatar setFrame:CGRectMake(12.0, 12.0, cell.contentView.bounds.size.height - 24.0, cell.contentView.bounds.size.height - 24.0)];
    [cell.avatar.layer setCornerRadius:cell.avatar.bounds.size.height / 2];
    [cell.follow setFrame:CGRectMake(cell.contentView.bounds.size.width - (cell.follow.followSizeUpdate + 60.0), 10.0, cell.follow.followSizeUpdate, cell.contentView.bounds.size.height - 20.0)];
    [cell.user setFrame:CGRectMake(60.0, 0.0, cell.contentView.bounds.size.width - (cell.follow.followSizeUpdate + 130.0), cell.contentView.bounds.size.height)];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self.users objectAtIndex:indexPath.row];
    BFriendCell *cell = (BFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"user" forIndexPath:indexPath];
    
    if ([self.query friendCheck:[item objectForKey:@"username"]]) cell.follow.type = BFollowActionTypeFollowed;
    else cell.follow.type = BFollowActionTypeUnfollowed;
    
    [cell.follow followSetType:cell.follow.type animate:false];
    [cell content:item];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
        
}

-(void)searchFieldWasUpdated:(NSString *)query {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    NSPredicate *search = [NSPredicate predicateWithFormat:@"username CONTAINS[c] %@" ,query];
    if (query.length > 1) {
        NSLog(@"searching '%@'" ,query);
        [output addObjectsFromArray:[[self.query cacheRetrive:@"userApi/getAllUsers"] filteredArrayUsingPredicate:search]];

    }
    else {
        [output addObjectsFromArray:[self.query cacheRetrive:@"userApi/getAllUsers"]];

    }
    
    self.users = [[NSMutableArray alloc] initWithArray:output];
    if (self.users.count > 0) {
        [self.viewTable setHidden:false];
        [self.viewPlaceholder setHidden:true];
        
    }
    else {
        [self.viewTable setHidden:true];
        [self.viewPlaceholder setHidden:false];
        [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Friend_EmptyPlaceholder_Title", nil) instructions:NSLocalizedString(@"Friend_EmptyPlaceholder_Body", nil)];

    }
    
    [self.viewTable reloadData];
    
}

-(void)searchFieldWasPresented:(CGSize)keyboard {
    [self.viewTable setFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height + self.viewSearch.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + keyboard.height + self.viewSearch.bounds.size.height + self.viewNavigation.bounds.size.height))];
    [self.viewPlaceholder setFrame:self.viewTable.bounds];

}

-(void)searchFieldWasDismissed {
    [self.viewTable setFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height + self.viewSearch.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + self.viewSearch.bounds.size.height + self.viewNavigation.bounds.size.height))];
    [self.viewPlaceholder setFrame:self.viewTable.bounds];

}

-(void)searchFieldReturnKeyPressed {
    [self.viewSearch dismiss];
    
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
