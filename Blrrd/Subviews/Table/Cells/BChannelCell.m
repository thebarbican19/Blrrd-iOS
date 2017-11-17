//
//  BChannelCell.m
//  Blrrd
//
//  Created by Joe Barbour on 14/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BChannelCell.h"
#import "BConstants.h"

@implementation BChannelCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.container = [[UIView alloc] initWithFrame:self.bounds];
        self.container.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
        self.container.clipsToBounds = true;
        self.container.userInteractionEnabled = true;
        self.container.layer.cornerRadius = 6.0;
        [self.contentView addSubview:self.container];
        
        self.image = [[UIImageView alloc] initWithFrame:self.container.bounds];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.image = nil;
        [self.container addSubview:self.image];
        
        self.overlay = [[UIImageView alloc] initWithFrame:self.container.bounds];
        self.overlay.contentMode = UIViewContentModeScaleAspectFill;
        self.overlay.backgroundColor = [UIColorFromRGB(0xA573FF) colorWithAlphaComponent:0.4];
        [self.container addSubview:self.overlay];
        
        self.channel = [[SAMLabel alloc] initWithFrame:CGRectMake(12.0, 12.0, self.bounds.size.width - 24.0, self.bounds.size.height - 24.0)];
        self.channel.textAlignment = NSTextAlignmentLeft;
        self.channel.font = [UIFont fontWithName:@"Nunito-Regular" size:15];
        self.channel.verticalTextAlignment = SAMLabelVerticalTextAlignmentBottom;
        self.channel.textColor = [UIColor whiteColor];
        self.channel.backgroundColor = [UIColor clearColor];
        [self.container addSubview:self.channel];

    }
 
    return self;
    
}

-(void)content:(NSDictionary *)content index:(NSIndexPath *)index {
    [self.channel setText:[content objectForKey:@"name"]];
    [self image:[NSURL URLWithString:[content objectForKey:@"backgroundimage"]]];
    
}

-(void)image:(NSURL *)url {
    [self.image sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            if (image.CGImage != NULL && image.CGImage != nil) {
                [self.image setImage:image];
                
            }
            
        } completion:nil];
        
    }];
    
}


@end
