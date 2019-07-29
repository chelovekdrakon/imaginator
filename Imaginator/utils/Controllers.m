//
//  Controllers.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/29/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "Controllers.h"

@implementation Controllers

+ (UIViewController *)getRootVC {
    UIViewController *rootViewController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    return rootViewController;
}

@end
