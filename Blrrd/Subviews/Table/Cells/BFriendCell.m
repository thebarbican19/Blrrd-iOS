//
//  BFriendCell.m
//  Blrrd
//
//  Created by Joe Barbour on 16/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BFriendCell.h"

@implementation BFriendCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.query = [[BQueryObject alloc] init];
    self.query.debug = true;
    if (self) {
        self.user = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 0.0, self.bounds.size.width - 64.0 , self.bounds.size.height)];
        self.user.clipsToBounds = true;
        self.user.textAlignment = NSTextAlignmentLeft;
        self.user.textColor = [UIColor whiteColor];
        self.user.font = [UIFont fontWithName:@"Nunito-Bold" size:14];
        self.user.numberOfLines = 2;
        self.user.userInteractionEnabled = true;
        [self.contentView addSubview:self.user];
        
        self.verifyed = [[UIImageView alloc] initWithFrame:CGRectMake(self.user.frame.origin.x + [self.user.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.user.bounds.size.width) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.user.font} context:nil].size.width + 4.0, self.user.frame.origin.y + 1.0, 13.0 ,13.0)];
        self.verifyed.contentMode = UIViewContentModeScaleAspectFill;
        self.verifyed.layer.cornerRadius = self.verifyed.bounds.size.width / 2;
        self.verifyed.clipsToBounds = true;
        self.verifyed.image = [UIImage imageNamed:@"profile_verifyed_icon"];
        self.verifyed.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.verifyed];
        
        self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(19.0, 6.0, self.bounds.size.height - 12.0 ,self.bounds.size.height - 12.0)];
        self.avatar.contentMode = UIViewContentModeScaleAspectFill;
        self.avatar.image = nil;
        self.avatar.backgroundColor = [UIColor lightGrayColor];
        self.avatar.layer.cornerRadius = self.avatar.bounds.size.height / 2;
        self.avatar.clipsToBounds = true;
        [self.contentView addSubview:self.avatar];
        
        self.gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        self.gesture.delegate = self;
        [self.user addGestureRecognizer:self.gesture];
        
        self.follow = [[BFollowAction alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - (100 + 55.0), 10.0, 100, self.contentView.bounds.size.height - 20.0)];
        self.follow.backgroundColor = [UIColor clearColor];
        self.follow.delegate = self;
        self.follow.alpha = 1.0;
        self.follow.transform = CGAffineTransformMakeScale(0.9, 0.9);
        self.follow.style = BFollowActionStyleIconAndText;
        [self.contentView addSubview:self.follow];

    }
    
    return self;
    
}

-(void)content:(NSDictionary *)item {
    self.data = [[NSDictionary alloc] initWithDictionary:item];
    
    [self name:item];
    [self avatar:[item objectForKey:@"avatar"]];

    [UIView animateWithDuration:0.2 animations:^{
        [self.follow setAlpha:1.0];
        [self.follow setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        
    }];

}

-(void)avatar:(id)image {
    if ([image isKindOfClass:[NSData class]]) {
        UIImage *data = [UIImage imageWithData:image];
        if (data.CGImage != NULL && data.CGImage != nil) {
            [self.avatar setImage:data];

        }
        else {
            [self.avatar setImage:[UIImage imageNamed:@"profile_avatar_placeholder"]];

        }
    }
    else {
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                if (image.CGImage != NULL && image.CGImage != nil) {
                    [self.avatar setImage:image];
                    
                }
                else {
                    [self.avatar setImage:[UIImage imageNamed:@"profile_avatar_placeholder"]];

                }
                
            } completion:nil];
            
        }];
        
    }
    
}

-(void)gesture:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(viewPresentProfile:)]) {
        [self.delegate viewPresentProfile:self.data];
        
    }
    
}

-(void)name:(NSDictionary *)data {
    NSString *header;
    NSString *subtitle;
    NSString *text;
    if ([data objectForKey:@"fullname"] != nil) {
        header = [data objectForKey:@"fullname"];
        subtitle = [data objectForKey:@"username"];
        text = [NSString stringWithFormat:@"%@\n@%@" ,header, subtitle.lowercaseString];

    }
    else if ([[data objectForKey:@"follows"] boolValue]) {
        if ([[data objectForKey:@"displayname"] length] > 0) {
            header = [data objectForKey:@"displayname"];
            subtitle = [NSString stringWithFormat:@"@%@ %@" ,[data objectForKey:@"username"], NSLocalizedString(@"Friend_CellSubtitleFollows_Text", nil)];

        }
        else {
            header = [data objectForKey:@"username"];
            subtitle = NSLocalizedString(@"Friend_CellSubtitleFollows_Text", nil);
            
        }
        
        text = [NSString stringWithFormat:@"%@\n%@ " ,header, subtitle.lowercaseString];

    }
    else if ([[data objectForKey:@"displayname"] length] > 0) {
        header = [data objectForKey:@"displayname"];
        subtitle = [data objectForKey:@"username"];
        text = [NSString stringWithFormat:@"%@\n@%@ " ,header, subtitle.lowercaseString];

    }
    else {
        header = [data objectForKey:@"username"];
        text = [NSString stringWithFormat:@"%@  " ,header];

    }
  
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:text];
    [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Nunito-Regular" size:9.0] range:NSMakeRange(header.length, subtitle.length + 2)];
    [formatted addAttribute:NSForegroundColorAttributeName value:[self.user.textColor colorWithAlphaComponent:0.6] range:NSMakeRange(header.length, subtitle.length + 2)];
    
    [self.user setAttributedText:formatted];
    [self.verifyed setHidden:![[data objectForKey:@"promoted"] boolValue]];
    [self.verifyed setFrame:CGRectMake(self.user.frame.origin.x + [header boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.user.bounds.size.width) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.user.font} context:nil].size.width + 4.0, self.user.frame.origin.y + (subtitle==nil?24.0:17.0), 13.0 ,13.0)];
    
}

-(void)followActionWasTapped:(BFollowAction *)action {
    [self.query postRequest:[self.data objectForKey:@"username"] request:@"add" completion:^(NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.follow followSetType:BFollowActionTypeFollowed animate:true];
            [self.follow setFrame:CGRectMake(self.contentView.bounds.size.width - (self.follow.followSizeUpdate + 60.0), 10.0, self.follow.followSizeUpdate, self.contentView.bounds.size.height - 20.0)];

        }];
        
    }];

}

@end
