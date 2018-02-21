//
//  BFollowAction.m
//  Blrrd
//
//  Created by Joe Barbour on 10/12/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BFollowAction.h"
#import "BConstants.h"

@implementation BFollowAction

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:container]) {
        container = [[UIButton alloc] initWithFrame:self.frame];
        container.backgroundColor = [UIColor clearColor];
        container.layer.cornerRadius = 6.0;
        container.layer.borderColor = UIColorFromRGB(0x69DCCB).CGColor;
        container.layer.borderWidth = 2.0;
        container.alpha = 0.0;
        container.userInteractionEnabled = true;
        [container addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:container];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(container.bounds.size.height, 2.0, container.bounds.size.width - container.bounds.size.height, container.bounds.size.height)];
        label.textColor = UIColorFromRGB(0x69DCCB);
        label.font = [UIFont fontWithName:@"Nunito-Black" size:12.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = nil;
        label.userInteractionEnabled = false;
        [container addSubview:label];
        
        icon = [[UIImageView alloc] initWithFrame:CGRectMake(4.0, 2.0, container.bounds.size.height - 4.0, container.bounds.size.height - 4.0)];
        icon.backgroundColor = [UIColor clearColor];
        icon.contentMode = UIViewContentModeCenter;
        icon.userInteractionEnabled = false;
        [container addSubview:icon];
        
    }
    
}

-(void)followAction:(UITapGestureRecognizer *)gesture {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if ([self.delegate respondsToSelector:@selector(followActionWasTapped:)]) {
            [self.delegate followActionWasTapped:self];
            NSLog(@"followAction");
        }
        
    }];

}

-(void)followSetType:(BFollowActionType)type animate:(BOOL)animate {
    self.type = type;
    [UIView animateWithDuration:animate?0.3:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (type == BFollowActionTypeFollowed || type == BFollowActionTypeDisconnect || type == BFollowActionTypeConnected) {
            if (type == BFollowActionTypeFollowed) {
                [label setText:NSLocalizedString(@"Friend_ActionFollowing_Text", nil).uppercaseString];
            
            }
            else if (type == BFollowActionTypeDisconnect) {
                [label setText:NSLocalizedString(@"Friend_ActionDisonnect_Text", nil).uppercaseString];
                
            }
            else if (type == BFollowActionTypeConnected) {
                [label setText:NSLocalizedString(@"Friend_ActionConnected_Text", nil).uppercaseString];
                
            }
            
            [label setTextColor:UIColorFromRGB(0x140F26)];
            [container setBackgroundColor:UIColorFromRGB(0x69DCCB)];
            [container.layer setBorderColor:UIColorFromRGB(0x69DCCB).CGColor];
            [icon setImage:[UIImage imageNamed:@"friends_following_icon"]];
            
        }
        else {
            if (type == BFollowActionTypeUnfollowed) {
                [label setText:NSLocalizedString(@"Friend_ActionFollow_Text", nil).uppercaseString];
                
            }
            else if (type == BFollowActionTypeFollowBack) {
                [label setText:NSLocalizedString(@"Friend_ActionFollowBack_Text", nil).uppercaseString];

            }
            else if (type == BFollowActionTypeConnect) {
                [label setText:NSLocalizedString(@"Friend_ActionConnect_Text", nil).uppercaseString];
                
            }
            [label setTextColor:UIColorFromRGB(0x69DCCB)];
            [container setBackgroundColor:UIColorFromRGB(0x140F26)];
            [container.layer setBorderColor:UIColorFromRGB(0x69DCCB).CGColor];
            [icon setImage:[UIImage imageNamed:@"friends_follow_icon"]];
            
        }
        
        [container setAlpha:1.0];
        [self followSizeUpdate];
        
    } completion:nil];

}

-(float)followSizeUpdate {
    if (self.style == BFollowActionStyleIcon) {
        [container setFrame:CGRectMake(0.0, 0.0, container.bounds.size.height + 4.0, container.bounds.size.height)];
        [label setHidden:true];
        
        return 0.0;
        
    }
    else {
        NSString *content;
        if (self.type == BFollowActionTypeFollowed) content = NSLocalizedString(@"Friend_ActionFollowing_Text", nil).uppercaseString;
        else if (self.type == BFollowActionTypeUnfollowed) content = NSLocalizedString(@"Friend_ActionFollow_Text", nil).uppercaseString;
        else if (self.type == BFollowActionTypeFollowBack) content = NSLocalizedString(@"Friend_ActionFollowBack_Text", nil).uppercaseString;
        else if (self.type == BFollowActionTypeConnect) content = NSLocalizedString(@"Friend_ActionConnect_Text", nil).uppercaseString;
        else if (self.type == BFollowActionTypeDisconnect) content = NSLocalizedString(@"Friend_ActionDisonnect_Text", nil).uppercaseString;
        else if (self.type == BFollowActionTypeConnected) content = NSLocalizedString(@"Friend_ActionConnected_Text", nil).uppercaseString;

        

        CGRect rect = [content boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Nunito-Black" size:12.0]} context:nil];
        
        [label setHidden:false];
        [label setFrame:CGRectMake(container.bounds.size.height, 0.0, rect.size.width, container.bounds.size.height)];
        [container setFrame:CGRectMake(0.0, 0.0, rect.size.width + 8.0 + container.bounds.size.height, self.bounds.size.height)];

        return rect.size.width;
        
    }

}

@end
