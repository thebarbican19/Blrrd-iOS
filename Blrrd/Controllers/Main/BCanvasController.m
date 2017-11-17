//
//  BCanvasController.m
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BCanvasController.h"
#import "BConstants.h"

@interface BCanvasController ()

@end

@implementation BCanvasController


-(void)viewContentRefresh:(UIRefreshControl *)refresh {
    
}

-(void)viewInitiateCamera {
    [self.placeholder placeholderUpdateTitle:@"Nope" instructions:@"Put ya dicks away fellas, this isn't available just yet."];
    
}

-(void)viewTermiateCamera {
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.placeholder = [[GDPlaceholderView alloc] initWithFrame:self.view.bounds];
    self.placeholder.delegate = self;
    self.placeholder.backgroundColor = [UIColor clearColor];
    self.placeholder.textcolor = [UIColor whiteColor];
    self.placeholder.gesture = true;
    [self.view addSubview:self.placeholder];
    
}

@end
