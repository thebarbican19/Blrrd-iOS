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
#import "SAMLabel.h"

@protocol BProfileHeaderDelegate;
@interface BProfileHeader : UIView <UIGestureRecognizerDelegate> {
    UIImageView *profile;
    UIView *halo;
    SAMLabel *username;
    SAMLabel *email;
    UITapGestureRecognizer *gesture;
    UIButton *settings;
    SAMLabel *timeviewed;

}

@property (nonatomic, strong) id <BProfileHeaderDelegate> delegate;
@property (nonatomic, strong) BCredentialsObject *credentials;

@end

@protocol BProfileHeaderDelegate <NSObject>

@optional

-(void)viewPresentProfile;
-(void)viewPresentSettings;

@end

