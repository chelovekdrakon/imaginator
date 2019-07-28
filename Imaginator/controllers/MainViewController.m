//
//  RootViewController.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/28/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"

@interface MainViewController ()
@property(retain, nonatomic) UIViewController *loginView;
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
    
    if (_loginView) {
        [_loginView release];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [self getRandomColor];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults removeObjectForKey:userDefaultsTokens]; // for login debugging
    NSDictionary *tokens = [userDefaults objectForKey:userDefaultsTokens];
    
    if (tokens) {
        // load collection view
    } else {
        self.loginView = [[[LoginViewController alloc] init] autorelease];
        
        [userDefaults addObserver:self
                   forKeyPath:userDefaultsTokens
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
//        [loginView willMoveToParentViewController:self];
//        [self addChildViewController:loginView];
//        loginView.view.frame = self.view.bounds;
//        [self.view addSubview:loginView.view];
//        [loginView didMoveToParentViewController:self];
//
//        loginView.view.translatesAutoresizingMaskIntoConstraints = NO;
//
//        [NSLayoutConstraint activateConstraints:@[
//          [loginView.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
//          [loginView.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
//          [loginView.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
//          [loginView.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
//        ]];
        
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
                NSLog(@"loginViewController removed!");
                // load collection view
            }];
        });
    }
}

#pragma mark - Utils

- (UIColor *)getRandomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (UIViewController *)getRootVC {
    UIViewController *rootViewController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    return rootViewController;
}


@end
