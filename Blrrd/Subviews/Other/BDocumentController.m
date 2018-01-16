//
//  BDocumentController.m
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BDocumentController.h"
#import "BConstants.h"

@interface BDocumentController ()

@end

@implementation BDocumentController

-(void)viewNavigationButtonTapped:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:true];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self.viewNavigation navigationTitle:self.header];
    [self.viewWeb loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.file isDirectory:false]]];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.view.clipsToBounds = true;
    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;

    self.viewNavigation = [[BNavigationView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT, self.view.bounds.size.width, 70.0)];
    self.viewNavigation.backgroundColor = [UIColor clearColor];
    self.viewNavigation.name = nil;
    self.viewNavigation.delegate = self;
    [self.view addSubview:self.viewNavigation];
    
    self.viewWeb = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (APP_STATUSBAR_HEIGHT + self.viewNavigation.bounds.size.height))];
    self.viewWeb.delegate = self;
    self.viewWeb.scalesPageToFit = true;
    self.viewWeb.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewWeb];

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
