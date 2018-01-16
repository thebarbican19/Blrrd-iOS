//
//  BGalleryController.m
//  Blrrd
//
//  Created by Joe Barbour on 28/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BGalleryController.h"
#import "BGalleryCell.h"
#import "BConstants.h"

@interface BGalleryController ()

@end

@implementation BGalleryController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.imageobj = [BImageObject sharedInstance];
    
    self.gallery = [[NSMutableArray alloc] init];

    [self.collectionView registerClass:[BGalleryCell class] forCellWithReuseIdentifier:@"image"];

}

-(void)viewLoadImages {
    [self.imageobj imagesFromAlbum:nil completion:^(NSArray *images) {
        [self.gallery addObjectsFromArray:images];
        [self.collectionView reloadData];
        
    }];

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.gallery count];
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.collectionView.bounds.size.width / 3) - 12.0, (self.collectionView.bounds.size.width / 3) - 12.0);

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BGalleryCell *cell = (BGalleryCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"image" forIndexPath:indexPath];
    
    [self.imageobj imagesFromAsset:[self.gallery objectAtIndex:indexPath.row] thumbnail:true completion:^(NSDictionary *data, UIImage *image) {
        [cell.container setImage:image];

    } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
    
    }];
    
    [cell.container setClipsToBounds:true];
    [cell.container.layer setCornerRadius:4.0];
    [cell.overlay setTransform:CGAffineTransformMakeScale(1.25, 1.25)];

    [cell.contentView.layer setShadowColor:UIColorFromRGB(0x000000).CGColor];
    [cell.contentView.layer setShadowOffset:CGSizeMake(0.0, 2.0)];
    [cell.contentView.layer setShadowRadius:9.0];
    [cell.contentView.layer setCornerRadius:8.0];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BGalleryCell *cell = (BGalleryCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (self.selected != [self.gallery objectAtIndex:indexPath.row]) {
        self.selected = [self.gallery objectAtIndex:indexPath.row];

    }
    else {
        self.selected = nil;
        
    }

    for (BGalleryCell *visible in self.collectionView.visibleCells) {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if (cell == visible && self.selected != nil) {
                [visible.overlay setAlpha:1.0];
                [visible.overlay setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

            }
            else {
                [visible.overlay setAlpha:0.0];
                [visible.overlay setTransform:CGAffineTransformMakeScale(1.25, 1.25)];

            }
            
        } completion:nil];
        
    }
    
}

@end
