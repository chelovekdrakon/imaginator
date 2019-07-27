//
//  ViewController.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/27/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property(retain, nonatomic) NSString *secretKey;
@property(retain, nonatomic) NSString *accessKey;
@end

@implementation LoginViewController

- (void)loadView {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    self.secretKey = [plistData objectForKey:@"SECRET_KEY"];
    self.accessKey = [plistData objectForKey:@"ACCESS_KEY"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)dealloc {
    [super dealloc];
    NSLog(@"dealloca of Login VC");
}


@end
