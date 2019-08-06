//
//  CollectionViewDataModel.h
//  Imaginator
//
//  Created by Фёдор Морев on 8/6/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionViewDataModel : NSObject

@property(retain, nonatomic) NSMutableArray <NSMutableArray *> *dataModel;

+ (CollectionViewDataModel *)shared;
- (void)extendDataModelWithArray:(NSArray *)array;


@end
