//
//  CollectionViewController.h
//  Imaginator
//
//  Created by Фёдор Морев on 7/28/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewLayout.h"

@interface CollectionViewController : UIViewController
@property(retain, nonatomic) UICollectionView *collectionView;
@property(retain, nonatomic) CollectionViewLayout *collectionViewLayout;
@end
