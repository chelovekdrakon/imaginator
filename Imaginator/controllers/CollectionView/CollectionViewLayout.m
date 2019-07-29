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
@property(retain, nonatomic) NSArray *dataModel;

@property(assign, nonatomic) CGSize screenSize;
@property(assign, nonatomic) CGSize currentContentSize;
@property(assign, nonatomic) NSInteger lastNumberOfItems;
@end

@implementation CollectionViewLayout

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    
    [_layoutArr release];
    [_dataModel release];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    self.screenSize = [[UIScreen mainScreen] bounds].size;
    self.layoutArr = [[self generateLayout] autorelease];
}

- (CGSize)collectionViewContentSize {
    return self.currentContentSize;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)bounds {
    NSMutableArray *layoutAttributes = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSArray *itemsArray in self.layoutArr) {
        [layoutAttributes addObjectsFromArray:itemsArray];
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.layoutArr[indexPath.section][indexPath.item];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}


- (void)updateDataModel:(NSArray *)array {
    self.dataModel = array;
}

- (NSArray *)generateLayout {
    NSMutableArray *resultArray = [NSMutableArray array];
    
    float cellMaxWidth = self.screenSize.width / 2;
    
    float xOffset = 0;
    float yOffset = 0;
    
    NSInteger sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    
    for (NSInteger section = 0; section < sectionsCount; section++) {
        yOffset = 0;
        
        NSInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
        
        NSMutableArray *sectionItems = [NSMutableArray array];
        
        for (NSInteger item = 0; item < itemsCount; item++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            NSDictionary *pictureInfo = self.dataModel[section][item];
            CGSize pictureSize = [self getPictureSizeFromInfo:pictureInfo];
            
            UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attrs.frame = CGRectMake(xOffset, yOffset, pictureSize.width, pictureSize.height);
            attrs.center = CGPointMake(xOffset + (cellMaxWidth / 2),
                                        yOffset + (pictureSize.height / 2));
            
            [sectionItems addObject:attrs];
            
            yOffset += pictureSize.height;
        }
        
        [resultArray addObject:sectionItems];
        
        xOffset += cellMaxWidth;
    }
    
    self.currentContentSize = CGSizeMake(xOffset, yOffset);
    
    return [resultArray retain];
}

#pragma mark - Utils

- (CGSize)getPictureSizeFromInfo:(NSDictionary *)info {
    float cellMaxWidth = self.screenSize.width / 2;
    
    float picWidth = [[info objectForKey:@"width"] floatValue];
    float picHeight = [[info objectForKey:@"height"] floatValue];
    
    if (picWidth <= cellMaxWidth) {
        return CGSizeMake(picWidth, picHeight);
    } else {
        float index = picWidth / cellMaxWidth;
        return CGSizeMake(cellMaxWidth, picHeight / index);
    }
}

@end
