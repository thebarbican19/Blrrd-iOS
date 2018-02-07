//
//  BProfileHeader.h
//  Blrrd
//
//  Created by Joe Barbour on 27/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>
#import "BCredentialsObject.h"
#import "BQueryObject.h"
#import "SAMLabel.h"
#import "GDStatusLabel.h"

@protocol BProfileHeaderDelegate;
@interface BProfileHeader : UIView <UIGestureRecognizerDelegate> {
    UIImageView *profile;
    UIImageView *verifyed;
    UIView *halo;
    UIView *hairline;
    SAMLabel *username;
    SAMLabel *email;
    UITapGestureRecognizer *gesture;
    UIButton *settings;
    UIButton *friends;
    SAMLabel *timeviewed;

}

@property (nonatomic, strong) id <BProfileHeaderDelegate> delegate;
@property (nonatomic, strong) BCredentialsObject *credentials;
@property (nonatomic, strong) BQueryObject *query;
@property (nonatomic, assign) BOOL owner;

@end

@protocol BProfileHeaderDelegate <NSObject>

@optional

-(void)viewPresentProfile;
-(void)viewPresentSettings;
-(void)viewPresentFriends;

@end

