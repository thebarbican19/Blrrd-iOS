//
//  BChannelController.m
//  Blrrd
//
//  Created by Joe Barbour on 14/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BChannelController.h"
#import "BConstants.h"
#import "BChannelCell.h"

@interface BChannelController ()

@end

@implementation BChannelController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[BChannelCell class] forCellWithReuseIdentifier:@"channel"];
    
}

-(void)viewSetupContent:(NSArray *)content {
    self.channels = [[NSMutableArray alloc] initWithArray:content];
    
    if (self.channels.count > 0) [self.collectionView reloadData];
    else {
        
    }
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.channels.count;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.bounds.size.width / 2) - 20.0, (self.view.bounds.size.width / 2));
    
} 

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BChannelCell *cell = (BChannelCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"channel" forIndexPath:indexPath];
    
    [cell content:[self.channels objectAtIndex:indexPath.row] index:indexPath];
    
    [cell.contentView.layer setShadowColor:UIColorFromRGB(0x000000).CGColor];
    [cell.contentView.layer setShadowOffset:CGSizeMake(0.0, 2.0)];
    [cell.contentView.layer setShadowRadius:9.0];
    [cell.contentView.layer setCornerRadius:8.0];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(viewPresentChannel:)]) {
        [self.delegate viewPresentChannel:[self.channels objectAtIndex:indexPath.row]];
        
    }
    
}

@end
