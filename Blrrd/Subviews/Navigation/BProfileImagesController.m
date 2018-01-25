//
//  BProfileImagesController.m
//  Blrrd
//
//  Created by Joe Barbour on 30/11/2017.
//  Copyright © 2017 Blrrd Ltd. All rights reserved.
//

#import "BProfileImagesController.h"
#import "BConstants.h"
#import "BProfileCell.h"

@interface BProfileImagesController ()

@end

@implementation BProfileImagesController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.collectionView registerClass:[BProfileCell class] forCellWithReuseIdentifier:@"item"];

}

-(void)setup {
    self.query = [[BQueryObject alloc] init];
    self.credentials = [[BCredentialsObject alloc] init];
    self.images = [[NSMutableArray alloc] init];
    for (NSDictionary *images in [self.query cacheRetrive:self.credentials.userKey]) {
        if (self.limitimages > self.images.count) {
            NSMutableDictionary *append = [[NSMutableDictionary alloc] initWithDictionary:images];
            [append setObject:@"image" forKey:@"type"];
            
            [self.images addObject:append];
            
        }
        
    }

    [self.images addObject:@{@"type":@"showall", @"publicpath":[[[self.query cacheRetrive:self.credentials.userKey] lastObject] objectForKey:@"imageurl"]}];
    [self.collectionView reloadData];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.images count];
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.bounds.size.height - 10.0, self.collectionView.bounds.size.height - 10.0);
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BProfileCell *cell = (BProfileCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    NSDictionary *item = [self.images objectAtIndex:indexPath.row];

    [cell content:item];
    
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setClipsToBounds:true];
    [cell.contentView.layer setCornerRadius:5.0];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self.images objectAtIndex:indexPath.row];
    NSString *type = [item objectForKey:@"type"];
    if ([type isEqualToString:@"image"]) [self.delegate viewPresentImageWithData:item];
    else [self.delegate viewPresentProfile];
    
}

@end
