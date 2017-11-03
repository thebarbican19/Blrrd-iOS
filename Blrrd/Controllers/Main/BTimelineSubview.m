//
//  BTimelineSubview.m
//  Blrrd
//
//  Created by Joe Barbour on 03/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BTimelineSubview.h"
#import "BConstants.h"

@interface BTimelineSubview ()

@end

@implementation BTimelineSubview

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[BBlurredCell class] forCellWithReuseIdentifier:@"item"];
    [self.collectionView reloadData];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.content.count;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width - 30.0, self.view.bounds.size.width - 30.0);
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBlurredCell *cell = (BBlurredCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];

    [cell content:[self.content objectAtIndex:indexPath.row] index:indexPath];
    [cell backgroundoffset:CGPointMake(0.0f, ((self.collectionView.contentOffset.y - cell.frame.origin.y) / MAIN_CELL_SIZE.height) * 8.0)];

    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.collectionView.visibleCells.count > 1) {
        CGPoint selected;
        if (scrollView.contentOffset.y < 100.0) selected = CGPointMake(self.collectionView.center.x + self.collectionView.contentOffset.x, 0.0);
        else selected = CGPointMake(self.collectionView.center.x + self.collectionView.contentOffset.x, (self.collectionView.center.y + self.collectionView.contentOffset.y) - 50.0);
        
        self.activecell = (BBlurredCell *)[self.collectionView cellForItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:selected]];
        
    }
    
    for (NSIndexPath *item in [self.collectionView indexPathsForVisibleItems]) {
        BBlurredCell *cell = (BBlurredCell *)[self.collectionView cellForItemAtIndexPath:item];
        if (cell != self.activecell) [cell reveal:nil];

    }
    
    CGSize cellsize = MAIN_CELL_SIZE;
    for (BBlurredCell *view in self.collectionView.visibleCells) {
        [view backgroundoffset:CGPointMake(0.0f, ((self.collectionView.contentOffset.y - view.frame.origin.y) / cellsize.height) * 10.0)];
        
    }
    
}

@end
