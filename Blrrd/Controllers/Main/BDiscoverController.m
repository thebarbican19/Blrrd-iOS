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
    
    self.sections = [[NSMutableArray alloc] initWithObjects:@[], @[], @[], nil];
    
    self.header = [[BProfileHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 120.0)];
    self.header.backgroundColor = [UIColor clearColor];
    self.header.delegate = self;
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView registerClass:[BNotificationCell class] forCellReuseIdentifier:@"notification"];
    [self.tableView registerClass:[BFriendCell class] forCellReuseIdentifier:@"friends"];
    [self.tableView setTableHeaderView:self.header];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 20.0)]];

}

-(void)viewPresentProfile {
    NSLog(@"viewPresentProfile");
    [self.delegate viewPresentProfile];
    
}

-(void)viewSetupNotification:(NSArray *)notification limit:(int)limit {
    if (limit == 0) self.notifications = [[NSMutableArray alloc] initWithArray:notification];
    else {
        self.notifications = [[NSMutableArray alloc] init];
        if (notification.count > limit) {
            [self.notifications addObjectsFromArray:[notification subarrayWithRange:NSMakeRange(0, limit)]];
        
        }
        else [self.notifications addObjectsFromArray:notification];
        
    }
    
    if (self.notifications.count > 0) {
        [self.sections replaceObjectAtIndex:0 withObject:self.notifications];
        [self.tableView reloadData];
        
    }
    else {
        
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

-(void)viewSetupSuggested:(NSArray *)suggested limit:(int)limit {
    if (limit == 0) self.suggested = [[NSMutableArray alloc] initWithArray:suggested];
    else {
        self.suggested = [[NSMutableArray alloc] init];
        if (suggested.count > limit) {
            [self.suggested addObjectsFromArray:[suggested subarrayWithRange:NSMakeRange(0, limit)]];
            
        }
        else [self.suggested addObjectsFromArray:suggested];
        
    }
    
    if (self.suggested.count > 0) {
        [self.sections replaceObjectAtIndex:2 withObject:self.suggested];
        [self.tableView reloadData];
        
    }
    else {
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return 50.0;
    else return 60.0;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BSectionHeader *header = [[BSectionHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 35.0)];
    if (section == 0) header.name = NSLocalizedString(@"Profile_SectionNotifications_Header", nil);
    else if (section == 1) header.name = NSLocalizedString(@"Profile_SectionRequests_Header", nil);
    else if (section == 2) header.name = NSLocalizedString(@"Profile_SectionYouMayKnow_Header", nil);
    header.tag = section;
    header.backgroundColor = [UIColor clearColor];
    if ([[self.sections objectAtIndex:section] count] == 0) header.hidden = true;
    else header.hidden = false;
    return header;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([[self.sections objectAtIndex:section] count] == 0) return 0.0;
    else return 60.0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sections objectAtIndex:section] count];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BNotificationCell *notification = (BNotificationCell *)cell;
        notification.status.frame = CGRectMake(19.0, 0.0, cell.contentView.bounds.size.width - 16.0 , cell.contentView.bounds.size.height - 12.0);
        notification.timestamp.frame = CGRectMake(19.0, cell.contentView.bounds.size.height - 18.0, cell.contentView.bounds.size.width - 16.0 ,8.0);
        notification.image.frame = CGRectMake(cell.contentView.bounds.size.width - (cell.contentView.bounds.size.height + 2.0), 3.0, cell.contentView.bounds.size.height - 6.0, cell.contentView.bounds.size.height - 6.0);

    }
    else {

    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (indexPath.section == 0) {
        BNotificationCell *cell = (BNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"notification" forIndexPath:indexPath];
        
        [cell content:item];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;

    }
    else {
        BFriendCell *cell = (BFriendCell *)[tableView dequeueReusableCellWithIdentifier:@"friends" forIndexPath:indexPath];

        [cell content:item];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;

    }
    
}

@end
