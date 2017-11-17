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
        self.avatar.layer.cornerRadius = 8.0;
        self.avatar.clipsToBounds = true;
        [self.contentView addSubview:self.avatar];
        
    }
    
    return self;
    
}

-(void)content:(NSDictionary *)item {
    if ([[item objectForKey:@"username"] isEqual:[NSNull null]]) [self.user setText:[item objectForKey:@"requestto"]];
    else [self.user setText:[item objectForKey:@"username"]];
    
    [self avatar:[NSURL URLWithString:[item objectForKey:@"photo"]]];
    
}

-(void)avatar:(NSURL *)url {
    [self.avatar sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (image.CGImage != NULL && image.CGImage != nil) {
                [self.avatar setImage:image];
                
            }
            
        } completion:nil];
        
    }];
    
}

@end
