//
//  CollectionViewDataModel.m
//  Imaginator
//
//  Created by Фёдор Морев on 8/6/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "CollectionViewDataModel.h"

@implementation CollectionViewDataModel

- (id)init {
    self = [super init];
    if (self) {
        NSMutableArray *dataModel = [NSMutableArray array];
        [dataModel addObject:[NSMutableArray array]];
        [dataModel addObject:[NSMutableArray array]];
        
        self.dataModel = dataModel;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    [_dataModel release];
}

- (void)extendDataModelWithArray:(NSArray *)array {
    for (int i = 0; i < [array count]; i++) {
        NSInteger section = i % [self.dataModel count];
        [self.dataModel[section] addObject:array[i]];
    }
}

+ (CollectionViewDataModel *)shared {
    static CollectionViewDataModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CollectionViewDataModel alloc] init];
    });
    
    return sharedInstance;
}

@end
