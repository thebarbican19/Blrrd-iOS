//
//  BFollowAction.h
//  Blrrd
//
//  Created by Joe Barbour on 10/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BFollowActionType) {
    BFollowActionTypeUnfollowed,
    BFollowActionTypeFollowed,
    BFollowActionTypeFollowBack,

};

typedef NS_ENUM(NSInteger, BFollowActionStyle) {
    BFollowActionStyleIcon,
    BFollowActionStyleIconAndText,
    
};

@protocol BFollowActionDelegate;
@interface BFollowAction : UIView <UIGestureRecognizerDelegate> {
    UIButton *container;
    UIImageView *icon;
    UILabel *label;

}

@property (nonatomic, strong) id <BFollowActionDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BFollowActionType type;
@property (nonatomic, assign) BFollowActionStyle style;

-(void)followSetType:(BFollowActionType)type animate:(BOOL)animate;
-(float)followSizeUpdate;

@end

@protocol BFollowActionDelegate <NSObject>

@optional

-(void)followActionWasTapped:(BFollowAction *)action;

@end
