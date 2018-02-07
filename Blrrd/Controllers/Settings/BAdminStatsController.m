//
//  BAdminStatsController.m
//  Blrrd
//
//  Created by Joe Barbour on 02/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import "BAdminStatsController.h"
#import "BConstants.h"
#import "BSettingsCell.h"

@interface BAdminStatsController ()

@end

@implementation BAdminStatsController

-(void)viewDidAppear:(BOOL)animated {
    [self.viewNavigation navigationTitle:self.header];
    [self.query queryAdminStats:^(NSDictionary *stats, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error.code == 200) {
                self.output = [[NSMutableArray alloc] init];
                for (NSString *key in stats.allKeys) {
                    id value = [stats objectForKey:key];
                    if ([key.lowercaseString containsString:@"time"]) {
                        if ((int)value < 60) value = [NSString stringWithFormat:@"%01ds" ,(int)value % 60];
                        else value = [NSString stringWithFormat:@"%01dm %01ds" ,(int)value / 60 % 60, (int)value % 60];
                    
                    }
                    
                    [self.output addObject:@{@"key":key, @"item":value}];
                    
                }
                
                [self.viewPlaceholder setHidden:true];
                [self.viewTable setHidden:false];
                [self.viewTable reloadData];
                
            }
            else {
                [self.viewTable setHidden:true];
                [self.viewPlaceholder setHidden:false];
                [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Friend_ErrorPlaceholder_Title", nil) instructions:error.domain];

            }
            
        }];
        
    }];
    
}

-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    [self performSelector:@selector(viewDidAppear:) withObject:nil afterDelay:0.5];
    [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Timeline_PlaceholderLoading_Title", nil) instructions:nil];

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
    
    self.viewTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - APP_STATUSBAR_HEIGHT)];
    self.viewTable.delegate = self;
    self.viewTable.dataSource = self;
    self.viewTable.clipsToBounds = true;
    self.viewTable.backgroundColor = [UIColor clearColor];
    self.viewTable.separatorColor = [UIColor clearColor];
    self.viewTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.viewNavigation.bounds.size.height)];
    [self.view addSubview:self.viewTable];
    [self.viewTable registerClass:[BSettingsCell class] forCellReuseIdentifier:@"item"];
    [self.view bringSubviewToFront:self.viewNavigation];
    
    self.viewPlaceholder = [[GDPlaceholderView alloc] initWithFrame:self.viewTable.frame];
    self.viewPlaceholder.delegate = self;
    self.viewPlaceholder.backgroundColor = [UIColor clearColor];
    self.viewPlaceholder.textcolor = [UIColor whiteColor];
    self.viewPlaceholder.gesture = true;
    self.viewPlaceholder.hidden = false;
    [self.view addSubview:self.viewPlaceholder];
    [self.view sendSubviewToBack:self.viewPlaceholder];
    [self.viewPlaceholder placeholderUpdateTitle:NSLocalizedString(@"Friend_LoadingPlaceholder_Title", nil) instructions:@"Wait for it, bellend."];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.output count];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(BSettingsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.name setFrame:CGRectMake(20.0, 5.0, (cell.contentView.bounds.size.width / 2) - 20.0, cell.contentView.bounds.size.height - 10.0)];
    [cell.variable setFrame:CGRectMake(cell.contentView.bounds.size.width / 2, 5.0, (cell.contentView.bounds.size.width / 2) - 20.0, cell.contentView.bounds.size.height - 10.0)];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self.output objectAtIndex:indexPath.row];
    NSString *key = [item objectForKey:@"key"];
    NSString *value = [NSString stringWithFormat:@"%@" ,[item objectForKey:@"item"]];

    BSettingsCell *cell = (BSettingsCell *)[tableView dequeueReusableCellWithIdentifier:@"item" forIndexPath:indexPath];
    
    [cell.variable setText:value];
    [cell.variable setHidden:false];
    [cell.name setTextAlignment:NSTextAlignmentLeft];
    [cell.name setBackgroundColor:[UIColor clearColor]];
    [cell.name setText:key];
    [cell.toggle setHidden:true];
    [cell.accessory setHidden:true];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
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
