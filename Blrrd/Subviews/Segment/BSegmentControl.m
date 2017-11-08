//
//  SHSegmentControl.m
//  Shwifty
//
//  Created by Joe Barbour on 22/09/2017.
//  Copyright © 2017 NorthernSpark. All rights reserved.
//

#import "BSegmentControl.h"
#import "BSegmentCell.h"
#import "BConstants.h"

@implementation BSegmentControl

-(void)drawRect:(CGRect)rect {    
    if (!self.font) self.font = [UIFont fontWithName:@"Avenir-Light" size:16];
    if (!self.fontselected) self.fontselected = [UIFont fontWithName:@"Avenir-Heavy" size:16];
    if (!self.background) self.background = [UIColor clearColor];
    if (!self.textcolor) self.textcolor = [UIColor whiteColor];
    if (!self.selecedtextcolor) self.selecedtextcolor = [UIColor redColor];
    if (self.padding == 0) self.padding = 50.0;
    if (self.index > self.buttons.count) self.index = 0;

    if (![self.subviews containsObject:container]) {
        self.backgroundColor = self.background;

        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 15.0;
        layout.sectionInset = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        container = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        container.pagingEnabled = false;
        container.backgroundColor = self.background;
        container.showsHorizontalScrollIndicator = true;
        container.bounces = true;
        container.scrollEnabled = self.scrolling;
        container.alwaysBounceVertical = false;
        container.delaysContentTouches = false;
        container.showsHorizontalScrollIndicator = false;
        container.delegate = self;
        container.dataSource = self;
        [container registerClass:[BSegmentCell class] forCellWithReuseIdentifier:@"segment"];
        [self addSubview:container];
    
        if (self.type == BSegmentTypeUnderline) {
            underline = [[UIView alloc] initWithFrame:CGRectMake(5.0, container.bounds.size.height - 2.0, [self buttonsize:self.buttons.firstObject].width - 10.0, 2.0)];
            underline.backgroundColor = self.selecedtextcolor;
            underline.clipsToBounds = true;
            [container addSubview:underline];
            
        }
        else {
            rectangle = [[UIView alloc] initWithFrame:CGRectMake(5.0, 5.0, [self buttonsize:self.buttons.firstObject].width - 10.0, container.bounds.size.height - 10.0)];
            rectangle.backgroundColor = self.selecedtextcolor;
            rectangle.clipsToBounds = true;
            rectangle.layer.cornerRadius = self.layer.cornerRadius - 5.0;
            rectangle.alpha = 0.0;
            [container addSubview:rectangle];
            
        }
        
    }
    
    [container setFrame:self.bounds];
    [underline setFrame:CGRectMake(5.0, container.bounds.size.height - 2.0, [self buttonsize:self.buttons.firstObject].width - 10.0, 2.0)];
    [rectangle setFrame:CGRectMake(5.0, 5.0, [self buttonsize:self.buttons.firstObject].width - 10.0, container.bounds.size.height - 10.0)];


}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.buttons.count;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self buttonsize:[self.buttons objectAtIndex:indexPath.row]];

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BSegmentCell *cell = (BSegmentCell *)[container dequeueReusableCellWithReuseIdentifier:@"segment" forIndexPath:indexPath];
    
    cell.label.text = [self.buttons objectAtIndex:indexPath.row];
    if (indexPath.row == self.index) {
        cell.label.font = self.fontselected;
        cell.label.textColor = self.selecedtextcolor;
        
    }
    else {
        cell.label.font = self.font;
        cell.label.textColor = self.textcolor;
        
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selected:indexPath animated:true];
    if ([self.delegate respondsToSelector:@selector(segmentViewWasTapped:index:)]) {
        [self.delegate segmentViewWasTapped:self index:indexPath.row];
        
    }

}

-(CGSize)buttonsize:(NSString *)label {
    CGRect rect;
    if (label != nil) rect = [label boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.font} context:nil];
    else rect = CGRectZero;
        
    return CGSizeMake(rect.size.width + self.padding, self.bounds.size.height);
    
}

-(void)selected:(NSIndexPath *)index animated:(BOOL)animated {
    for (int i = 0;i < self.buttons.count; i++) {
        BSegmentCell *cell = (BSegmentCell *)[container cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (index.row == i) {
            if (self.type == BSegmentTypeUnderline) {
                cell.label.font = self.font;
                cell.label.textColor = self.textcolor;
                
            }
            else {
                cell.label.font = self.fontselected;
                cell.label.textColor = self.selecedtextcolor;
                
            }
                
        }
        else {
            if (self.type == BSegmentTypeUnderline) {
                cell.label.font = self.fontselected;
                cell.label.textColor = self.selecedtextcolor;
            }
            else {
                cell.label.font = self.font;
                cell.label.textColor = self.textcolor;
                
            }
            
        }

    }
    
    BSegmentCell *cell = (BSegmentCell *)[container cellForItemAtIndexPath:index];
    [UIView animateWithDuration:animated?0.7:0.0 delay:0.05 usingSpringWithDamping:animated?0.6:0.0 initialSpringVelocity:animated?0.4:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [underline setFrame:CGRectMake(cell.frame.origin.x + 5.0, container.bounds.size.height - 2.0, cell.contentView.bounds.size.width - 10.0, 2.0)];
        [rectangle setFrame:CGRectMake(cell.frame.origin.x + 5.0, 5.0, cell.contentView.bounds.size.width - 10.0, container.bounds.size.height - 10.0)];
        [container scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionLeft animated:false];
        
    } completion:nil];
    
    self.index = (int)index.row;

}

-(void)segmentSetSelectedByIndex:(int)index {
    [self selected:[NSIndexPath indexPathForRow:index inSection:0] animated:true];
    
}

-(void)reload {
    for (int i = 0;i < self.buttons.count; i++) {
        BSegmentCell *cell = (BSegmentCell *)[container cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (self.index != i) [cell.label setTextColor:self.textcolor];
        
    }
    
    [container setBackgroundColor:self.background];
    
}

@end
