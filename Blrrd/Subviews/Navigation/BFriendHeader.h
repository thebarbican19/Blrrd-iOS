//
//  BFriendsHeader.h
//  Blrrd
//
//  Created by Joe Barbour on 10/02/2018.
//  Copyright © 2018 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMLabel.h"

typedef NS_ENUM(NSInteger, BFriendHeaderType) {
    BFriendHeaderTypeFindContacts,
    BFriendHeaderTypeShare,
    BFriendHeaderTypeLoading
    
};

@protocol BFriendHeaderDelegate;
@interface BFriendHeader : UIView <UIGestureRecognizerDelegate> {
    UIView *container;
    UIImageView *icon;
    SAMLabel *label;
    UIImageView *accsesory;
    UITapGestureRecognizer *gesture;

}

@property (nonatomic, strong) id <BFriendHeaderDelegate> delegate;
@property (nonatomic, assign) BFriendHeaderType type;

-(void)headerset:(NSString *)content animated:(BOOL)animated;

@end

@protocol BFriendHeaderDelegate <NSObject>

@optional

-(void)viewHeaderTapped:(BFriendHeaderType)type;

@end

