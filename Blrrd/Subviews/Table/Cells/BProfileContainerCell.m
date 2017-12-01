//
//  BProfileContainerCell.m
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BProfileContainerCell.h"

@implementation BProfileContainerCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout.minimumLineSpacing = 10.0;
        self.layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.layout.sectionInset = UIEdgeInsetsMake(0.0, 18.0, 0.0, 16.0);
         
        self.collection = [[BProfileImagesController alloc] initWithCollectionViewLayout:self.layout];
        self.collection.collectionView.frame = self.bounds;
        self.collection.collectionView.backgroundColor = [UIColor clearColor];
        self.collection.collectionView.showsHorizontalScrollIndicator = false;
        self.collection.limitimages = 8;
        self.collection.delegate = self;
        [self.contentView addSubview:self.collection.view];
        
    }
    
    return self;
    
}

-(void)setup {
    [self.collection setup];
    
}

-(void)viewPresentProfile {
    [self.delegate viewPresentProfile];
}

-(void)viewPresentImageWithData:(NSDictionary *)data {
    [self.delegate viewPresentImageWithData:data];
    
}

@end
