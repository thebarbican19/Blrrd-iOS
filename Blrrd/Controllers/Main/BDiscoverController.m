//
//  BDiscoverController.m
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BDiscoverController.h"
#import "BConstants.h"
#import "BNotificationCell.h"
#import "BFriendCell.h"
#import "BSectionHeader.h"

@interface BDiscoverController ()

@end

@implementation BDiscoverController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.query = [[BQueryObject alloc] init];
    
    self.sections = [[NSMutableArray alloc] initWithObjects:@[@{@"type":@"images"}], @[], @[], @[], nil];
    
    self.header = [[BProfileHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 125.0)];
    self.header.backgroundColor = [UIColor clearColor];
    self.header.delegate = self;
    self.header.owner = true;

    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView registerClass:[BProfileContainerCell class] forCellReuseIdentifier:@"profileimages"];
    [self.tableView registerClass:[BNotificationCell class] forCellReuseIdentifier:@"notification"];
    [self.tableView registerClass:[BFriendCell class] forCellReuseIdentifier:@"friends"];
    [self.tableView setTableHeaderView:self.header];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 20.0)]];

}

-(void)viewRefreshImages {
    BProfileContainerCell *cell = (BProfileContainerCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell setup];

}

-(void)viewPresentProfile {
    [self.delegate viewPresentProfile];
    
}

-(void)viewPresentSettings {
    [self.delegate viewPresentSettings];
    
}

-(void)viewPresentFriends {
    [self.delegate viewPresentFriends];
    
}

-(void)viewPresentImageWithData:(NSDictionary *)data {
    [self.delegate viewPresentImageWithData:data];
    
}

-(void)viewSetupNotification:(NSArray *)notification limit:(int)limit {
    if (limit == 0) self.notifications = [[NSMutableArray alloc] initWithArray:notification];
    else {
        self.notifications = [[NSMutableArray alloc] init];
        if (notification.count > limit) {
            [self.notifications addObjectsFromArray:notification];
        
        }
        else [self.notifications addObjectsFromArray:notification];
        
    }
    
    if (self.notifications.count > 0) {
        [self.sections replaceObjectAtIndex:2 withObject:self.notifications];
        [self.tableView reloadData];
        
    }
    
}

-(void)viewSetupRequests:(NSArray *)requests limit:(int)limit {
    if (limit == 0) self.requests = [[NSMutableArray alloc] initWithArray:requests];
    else {
        self.requests = [[NSMutableArray alloc] init];
        if (requests.count > limit) {
            [self.suggested addObjectsFromArray:[requests subarrayWithRange:NSMakeRange(0, limit)]];
            
        }
        else [self.suggested addObjectsFromArray:requests];
        
    }
    
    if (self.requests.count > 0) {
        [self.sections replaceObjectAtIndex:1 withObject:self.requests];
        [self.tableView reloadData];
        
    }
    else {
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return 115.0;
    else return 50.0;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BSectionHeader *header = [[BSectionHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 35.0)];
    if (section == 0) header.name = [NSString stringWithFormat:NSLocalizedString(@"Profile_SectionImages_Header", nil) ,self.credentials.userPosts];
    else if (section == 1) header.name = NSLocalizedString(@"Profile_SectionRequests_Header", nil);
    else header.name = NSLocalizedString(@"Profile_SectionNotifications_Header", nil);
    header.tag = section;
    header.backgroundColor = [UIColor clearColor];
    if ([[self.sections objectAtIndex:section] count] == 0 && section > 0) header.hidden = true;
    else header.hidden = false;
    return header;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if ([[self.query cacheRetrive:@"user/posts.php"] count] == 0) return 0;
        else return 60.0;
        
    }
    else if ([[self.sections objectAtIndex:section] count] == 0 && section > 0) return 0.0;
    else return 60.0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if ([[self.query cacheRetrive:@"user/posts.php"] count] == 0) return 0;
        else return 1;
        
    }
    else return [[self.sections objectAtIndex:section] count];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > 0) {
        BNotificationCell *notification = (BNotificationCell *)cell;
        notification.status.frame = CGRectMake(cell.contentView.bounds.size.height + 25.0, 0.0, cell.contentView.bounds.size.width - (cell.contentView.bounds.size.height + 28.0) , cell.contentView.bounds.size.height - 12.0);
        notification.timestamp.frame = CGRectMake(cell.contentView.bounds.size.height + 25.0, cell.contentView.bounds.size.height - 18.0, cell.contentView.bounds.size.width - (cell.contentView.bounds.size.height - 12.0) ,8.0);
        notification.image.frame = CGRectMake(19.0, 3.0, cell.contentView.bounds.size.height - 6.0, cell.contentView.bounds.size.height - 6.0);

    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (indexPath.section == 0) {
        BProfileContainerCell *cell = (BProfileContainerCell *)[tableView dequeueReusableCellWithIdentifier:@"profileimages" forIndexPath:indexPath];
        
        [cell setDelegate:self];
        [cell setup];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
        
    }
    else {
        BNotificationCell *cell = (BNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notification" forIndexPath:indexPath];
        
        [cell content:item type:BNotificationCellTypeAllTime];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;

    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSLog(@"secion: %d item: %@" ,(int)indexPath.section ,item);
    if (indexPath.section == 1) {
        [self.delegate viewPresentFriendProfile:item];
        
    }
    else if (indexPath.section == 2) {
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@" ,[item objectForKey:@"postid"]];
        //NSArray *profile = [[self.query cacheRetrive:@"user/posts.php"] filteredArrayUsingPredicate:predicate];
        //NSDictionary *photodata = [[NSDictionary alloc] initWithDictionary:profile.firstObject];

        //NSLog(@"photodata: %@" ,photodata);
        [self.delegate viewPresentImageWithData:item];
        
    }

}

@end
