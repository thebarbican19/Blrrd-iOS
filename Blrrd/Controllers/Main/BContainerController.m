//
//  BContainerController.m
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BContainerController.h"
#import "BAuthController.h"
#import "BConstants.h"

@interface BContainerController ()

@end

@implementation BContainerController

-(void)viewCheckAuthenticaion {
    if (self.credentials.userKey == nil) {
        BAuthController *viewAuthenticate = [[BAuthController alloc] init];
        viewAuthenticate.view.backgroundColor = [UIColor blackColor];
    
        [self.navigationController presentViewController:viewAuthenticate animated:false completion:nil];
        
    }
    else [self viewSetup];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self viewCheckAuthenticaion];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.query = [[BQueryObject alloc] init];
    self.query.debug = APP_DEBUG_MODE;
    self.query.delegate = self;
    
    self.credentials = [[BCredentialsObject alloc] init];
    
    self.statusbarstyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBarHidden = true;
    self.view.backgroundColor = [UIColor colorWithWhite:0.03 alpha:1.0];
    
    //[self.credentials destoryAllCredentials];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
}

-(void)viewSetup {
    NSDictionary *friendsendpoint = [self.query retriveEndpoint:@"maintimeline"];
    NSDictionary *hotendpoint = [self.query retriveEndpoint:@"maintimeline"];
    if (![self.view.subviews containsObject:self.viewTimeline.view]) {
        self.viewTimelineLayout = [[UICollectionViewFlowLayout alloc] init];
        self.viewTimelineLayout.minimumLineSpacing = 55.0;
        self.viewTimelineLayout.sectionInset = UIEdgeInsetsMake(100.0, 15.0, 100.0, 15.0);
        self.viewTimelineLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        self.viewTimeline = [[BTimelineSubview alloc] initWithCollectionViewLayout:self.viewTimelineLayout];
        self.viewTimeline.collectionView.frame = self.view.bounds;
        self.viewTimeline.collectionView.backgroundColor = [UIColor clearColor];
        self.viewTimeline.delegate = self;
        [self addChildViewController:self.viewTimeline];
        [self.view addSubview:self.viewTimeline.view];
        
        self.viewSegment = [[BSegmentControl alloc] initWithFrame:CGRectMake(self.view.center.x - 105.0, 28.0, 210.0, 50.0)];
        self.viewSegment.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.05];
        self.viewSegment.delegate = self;
        self.viewSegment.buttons = @[@"friends", @"hot"].mutableCopy;
        self.viewSegment.type = BSegmentTypeBox;
        //self.segment.font = [UIFont fontWithName:@"TitilliumWeb-Regular" size:12];
        //self.segment.fontselected = [UIFont fontWithName:@"TitilliumWeb-Bold" size:self.segment.font.pointSize];
        self.viewSegment.index = 0;
        self.viewSegment.selecedtextcolor = [UIColor colorWithWhite:1.0 alpha:1.0];
        self.viewSegment.textcolor = [UIColor colorWithWhite:1.0 alpha:0.5];
        self.viewSegment.layer.cornerRadius = self.viewSegment.bounds.size.height / 2;
        self.viewSegment.clipsToBounds = true;
        [self.viewTimelineLayout.collectionView addSubview:self.viewSegment];

    }
    
    NSLog(@"endpoint %@" ,friendsendpoint);
    NSLog(@"cache: %@" ,[self.query cacheRetrive:[friendsendpoint objectForKey:@"name"]]);
    if ([self.query cacheExpired:[friendsendpoint objectForKey:@"name"]]) {
        [self.query queryFriendsTimeline:self.viewTimeline.pagenation completion:^(NSArray *posts, NSError *error) {
            NSLog(@"queryFriendsTimeline %@ %@" ,posts, error);
            [self.viewTimeline collectionViewLoadContent:posts append:false];
            
            
        }];
        
    }
    else {
        [self.viewTimeline collectionViewLoadContent:[self.query cacheRetrive:@"friendstimelineone"] append:false];

    }
    
    if ([self.query cacheExpired:[hotendpoint objectForKey:@"name"]]) {
        
    }
    
}

-(void)viewSwitchTimeline:(int)index animated:(BOOL)animated {
    if (!animated) {
        //[self.viewTimeline collectionViewLoadContent:<#(NSArray *)#>]
    }
    else {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewTimeline.collectionView setFrame:CGRectMake(0.0, 40.0, self.view.bounds.size.width, self.view.bounds.size.height)];
            [self.viewTimeline.collectionView setAlpha:0.0];

        } completion:^(BOOL finished) {
            if (index == 0) {
                [self.viewTimeline collectionViewLoadContent:[self.query cacheRetrive:@"friendstimelineone"] append:false];
                
            }
            else {
                [self.viewTimeline collectionViewLoadContent:@[] append:false];
                
            }
            [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.viewTimeline.collectionView setFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
                [self.viewTimeline.collectionView setAlpha:1.0];
                
            } completion:nil];
            
        }];
        
    }
    
}

-(void)viewUpdateTimeline {
    NSLog(@"viewUpdateTimeline");
    if (self.timelineindex == 0) {
        [self.query queryFriendsTimeline:self.viewTimeline.pagenation completion:^(NSArray *posts, NSError *error) {
            [self.viewTimeline collectionViewLoadContent:posts append:self.viewTimeline.pagenation==0?false:true];

        }];
        
    }
    
}

-(void)segmentViewWasTapped:(BSegmentControl *)segment index:(NSUInteger)index {
    [self setTimelineindex:(int)index];
    [self viewSwitchTimeline:(int)index animated:true];
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
    
}

-(BOOL)prefersStatusBarHidden {
    return self.statusbarhidden;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusbarstyle;
    
}


@end
