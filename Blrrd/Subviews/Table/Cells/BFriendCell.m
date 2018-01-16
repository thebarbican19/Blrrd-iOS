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
        [self.contentView addSubview:self.user];
        
        self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(19.0, 6.0, self.bounds.size.height - 12.0 ,self.bounds.size.height - 12.0)];
        self.avatar.contentMode = UIViewContentModeScaleAspectFill;
        self.avatar.image = nil;
        self.avatar.backgroundColor = [UIColor lightGrayColor];
        self.avatar.layer.cornerRadius = self.avatar.bounds.size.height / 2;
        self.avatar.clipsToBounds = true;
        [self.contentView addSubview:self.avatar];
        
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
    if ([[item objectForKey:@"username"] isEqual:[NSNull null]]) [self.user setText:[item objectForKey:@"requestto"]];
    else [self.user setText:[item objectForKey:@"username"]];
            
    [self avatar:[NSURL URLWithString:[item objectForKey:@"photo"]]];

    [UIView animateWithDuration:0.2 animations:^{
        [self.follow setAlpha:1.0];
        [self.follow setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        
    }];

}

-(void)avatar:(NSURL *)url {
    [self.avatar sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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

-(void)followActionWasTapped:(BFollowAction *)action {
    [self.query postRequest:[self.data objectForKey:@"username"] request:@"add" completion:^(NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.follow followSetType:BFollowActionTypeFollowed animate:true];
            [self.follow setFrame:CGRectMake(self.contentView.bounds.size.width - (self.follow.followSizeUpdate + 60.0), 10.0, self.follow.followSizeUpdate, self.contentView.bounds.size.height - 20.0)];

        }];
        
    }];

}

@end
