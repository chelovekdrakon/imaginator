//
//  RootViewController.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/28/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "../utils/Colors.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "CollectionView/CollectionViewController.h"

@interface MainViewController ()
@property(retain, nonatomic) UIViewController *loginView;
@property(retain, nonatomic) UIViewController *collectionView;
@end

@implementation MainViewController

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        self.loginView = nil;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObserver:self forKeyPath:userDefaultsTokens];
    
    if ([_loginView isKindOfClass:[LoginViewController class]]) {
        [_loginView release];
    }
    if ([_collectionView isKindOfClass:[CollectionViewController class]]) {
        [_collectionView release];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [Colors getRandomColor];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults removeObjectForKey:userDefaultsTokens]; // for login debugging
    NSDictionary *tokens = [userDefaults objectForKey:userDefaultsTokens];
    
    if (tokens) {
        [self loadCollectionView];
    } else {
        self.loginView = [[[LoginViewController alloc] init] autorelease];
        
        [userDefaults addObserver:self
                   forKeyPath:userDefaultsTokens
                      options:NSKeyValueObservingOptionNew
                      context:NULL];

        self.loginView.modalPresentationStyle = UIModalPresentationPopover;
        [[self getRootVC] presentViewController:self.loginView animated:YES completion:nil];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:userDefaultsTokens]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loginView willMoveToParentViewController:nil];
            [self.loginView removeFromParentViewController];
            [self.loginView.view removeFromSuperview];
             
            [[self getRootVC] dismissViewControllerAnimated:self.loginView completion:^{
                [self.loginView release];
                [self loadCollectionView];
            }];
        });
    }
}

#pragma mark - Utils

- (void)loadCollectionView {
    self.collectionView = [[[CollectionViewController alloc] init] autorelease];
    [self.navigationController pushViewController:self.collectionView animated:YES];
}

- (UIViewController *)getRootVC {
    UIViewController *rootViewController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    return rootViewController;
}


@end
