//
//  BDiscoverController.h
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BDiscoverDelegate;
@interface BDiscoverController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) id <BDiscoverDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSMutableArray *suggested;
@property (nonatomic, strong) NSMutableArray *requests;
@property (nonatomic, strong) NSMutableArray *sections;

-(void)viewSetupNotification:(NSArray *)notification limit:(int)limit;
-(void)viewSetupSuggested:(NSArray *)suggested limit:(int)limit;
-(void)viewSetupRequests:(NSArray *)requests limit:(int)limit;

@end

@protocol BDiscoverDelegate <NSObject>

@optional


@end

