//
//  BAuthController.m
//  Blrrd
//
//  Created by Joe Barbour on 02/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BAuthController.h"
#import "BConstants.h"

@interface BAuthController ()

@end

@implementation BAuthController

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"authenticationLoginWithCredentials");
    [self.query authenticationLoginWithCredentials:@{@"username":@"emanuel.vila",
                                                     @"password":@"Florian1"}
                                        completion:^(NSDictionary *user, NSError *error) {
                                        NSLog(@"")
    }];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    self.query.debug = APP_DEBUG_MODE;
    
    self.credentials = [[BCredentialsObject alloc] init];

}

@end
