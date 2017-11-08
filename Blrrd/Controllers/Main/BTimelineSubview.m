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
    
    self.placeholder = [[GDPlaceholderView alloc] initWithFrame:CGRectMake(0.0, self.collectionView.contentInset.top, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height - self.collectionView.contentInset.top)];
    self.placeholder.delegate = self;
    self.placeholder.backgroundColor = [UIColor clearColor];
    self.placeholder.textcolor = [UIColor whiteColor];
    self.placeholder.gesture = true;
    [self.collectionView addSubview:self.placeholder];
    [self.collectionView sendSubviewToBack:self.placeholder];
    
    [self.collectionView registerClass:[BBlurredCell class] forCellWithReuseIdentifier:@"item"];
    [self.collectionView reloadData];
    
}

-(void)collectionViewLoadContent:(NSArray *)content append:(BOOL)append {
    if (append) [self.content addObjectsFromArray:content];
    else self.content = [[NSMutableArray alloc] initWithArray:content];
    
    if (self.content.count > 0) {
        [self.collectionView reloadData];
        [self.placeholder setHidden:true];
        
    }
    else {
        [self.placeholder setHidden:false];
        [self.placeholder placeholderUpdateTitle:@"Shit!" instructions:@"Feed currently unavailable."];
        [self.collectionView reloadData];

    }

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

    [cell setDelegate:self];
    [cell content:[self.content objectAtIndex:indexPath.row] index:indexPath];

    return cell;
    
}

-(void)collectionViewRevealed:(BBlurredCell *)revealed {
    for (BBlurredCell *cell in self.collectionView.visibleCells) {
        if (cell != revealed) [cell reveal:nil];
        
    }
    
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
    
    self.scrollheight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    if (self.scrollheight > self.view.bounds.size.height && !self.updating && self.collectionView.contentOffset.y > self.scrollposition && (scrollView.contentOffset.y + 150.0) > ((self.scrollheight / 5) * 4)) {
        if (self.pages != (float)self.scrollheight) {
            self.pagenation += 1;
            self.updating = true;
            self.pages = self.scrollheight;
            
        }
        //else if (self.scrollend) [(GDStreamFooter *)[self.collection viewWithTag:100] informationSet:NSLocalizedString(@"StreamFooterEndTitle", nil)];
        //else if (self.error.code != 200 && !self.scrollend) [(GDStreamFooter *)[self.collection viewWithTag:100] informationSet:self.error.domain];
        
    }
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.updating) {
        if ([self.delegate respondsToSelector:@selector(viewUpdateTimeline)]) {
            [self.delegate viewUpdateTimeline];
            
        }
        NSLog(@"go to next page: %d" ,(int)self.pagenation);
        
    }
    
}


@end
