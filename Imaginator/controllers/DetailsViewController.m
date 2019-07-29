//
//  DetailsViewController.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/29/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()
@property(retain, nonatomic) UIImage *image;
@end

@implementation DetailsViewController

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    [_image release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:self.image] autorelease];
    [self.view addSubview:imageView];
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
                                              [imageView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
                                              [imageView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
                                              [imageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
                                              [imageView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
                                              ]];
}

@end
