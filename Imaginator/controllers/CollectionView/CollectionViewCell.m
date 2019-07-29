//
//  CollectionViewCell.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/28/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    NSArray *subviews = [self subviews];
    
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
}

@end
