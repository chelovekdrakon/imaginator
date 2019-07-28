//
//  CollectionViewLayout.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/28/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "CollectionViewLayout.h"

@interface CollectionViewLayout()
@property(retain, nonatomic) NSArray *layoutArr;
@property(assign, nonatomic) CGSize currentContentSize;
@end

@implementation CollectionViewLayout

- (id)init {
    self = [super init];
    if (self) {
        self.layoutArr = [[self generateLayout] autorelease];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    
    [_layoutArr release];
}

- (void)prepareLayout {
    [super prepareLayout];
    self.layoutArr = [[self generateLayout] autorelease];
}

- (CGSize)collectionViewContentSize {
    return self.currentContentSize;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)bounds {
    NSMutableArray *layoutAttributes = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSArray *itemsArray in self.layoutArr) {
        for (UICollectionViewLayoutAttributes *attr in itemsArray) {
            [layoutAttributes addObject:attr];
        }
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutArr[indexPath.section][indexPath.item];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

#pragma mark - Utils

- (NSArray *)generateLayout {
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSInteger sectionsCount = 1;
    
    if ([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    }
    
    float xOffset = 0;
    float yOffset = 0;
    
    for (NSInteger section = 0; section < sectionsCount; section++) {
        NSInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
        
        NSMutableArray *sectionItems = [NSMutableArray array];
        
        for (NSInteger item = 0; item < itemsCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attrs.frame = CGRectMake(xOffset, yOffset, self.cellSize.width, self.cellSize.height);
            
            [sectionItems addObject:attrs];
            
            xOffset += self.cellSize.width;
        }
        
        [resultArray addObject:sectionItems];
        
        yOffset += self.cellSize.height;
    }
    
    self.currentContentSize = CGSizeMake(xOffset, yOffset);
    
    return [resultArray retain];
}

@end
