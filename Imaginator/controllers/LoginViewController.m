//
//  ViewController.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/27/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "LoginViewController.h"
#import <Accounts/Accounts.h>
#import <WebKit/WebKit.h>

NSString * const OAuth2BaseUrl = @"https://unsplash.com/oauth/";
NSString * const appUrlScheme = @"imaginatorapp";

@interface LoginViewController () <UIApplicationDelegate, WKUIDelegate, WKNavigationDelegate, NSURLSessionDelegate>
@property(retain, nonatomic) NSString *secretKey;
@property(retain, nonatomic) NSString *accessKey;
@property(retain, nonatomic) NSString *redirectURI;

@property(retain, nonatomic) NSURLSession *session;

@property(retain, nonatomic) WKWebView *webView;
@property(retain, nonatomic) WKWebViewConfiguration *webViewConfig;
@end

@implementation LoginViewController

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        self.secretKey = [plistData objectForKey:@"SECRET_KEY"];
        self.accessKey = [plistData objectForKey:@"ACCESS_KEY"];
        self.redirectURI = [plistData objectForKey:@"REDIRECT_URI"];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSString *authHeader = [NSString stringWithFormat:@"Client-ID %@", self.accessKey];
        
        sessionConfig.HTTPAdditionalHeaders = @{
                                                @"Accept-Language":@"en",
                                                @"Authorization":authHeader,
                                                @"Accept":@"application/json",
                                                };
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    
    [self.secretKey release];
    [self.accessKey release];
    [self.session release];
    
    [self.webViewConfig release];
    [self.webView release];
    
    NSLog(@"dealloca of Login VC");
}

- (void)loadView {
    [super loadView];
    
    self.webViewConfig = [[WKWebViewConfiguration alloc] init];
    
    self.webView = [[WKWebView alloc] initWithFrame:[self.view bounds] configuration:self.webViewConfig];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    [self.view addSubview:self.webView];
    
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
      [self.webView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
      [self.webView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
      [self.webView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
      [self.webView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [self getRandomColor];
    
    NSString *urlString = [NSString stringWithFormat:@"%@authorize", OAuth2BaseUrl];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlString];
    urlComponents.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"client_id" value:self.accessKey],
        [NSURLQueryItem queryItemWithName:@"redirect_uri" value:self.redirectURI],
        [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
        [NSURLQueryItem queryItemWithName:@"scope" value:@"public"],
    ];
    
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:urlComponents.URL];
    
    NSString *authHeader = [NSString stringWithFormat:@"Client-ID %@", self.accessKey];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlComponents.URL];
    [request setAllHTTPHeaderFields:@{
                                      @"Accept-Language":@"en",
                                      @"Authorization":authHeader,
                                      @"Accept":@"application/json",
                                      }];
    
    [self.webView loadRequest:request];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = navigationAction.request.URL;
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    
    NSString *code = nil;
    
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"code"]) {
            code = item.value;
            break;
        }
    }

    if ([url.scheme isEqualToString:appUrlScheme] &&
        [app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:^(BOOL success) {
            decisionHandler(WKNavigationActionPolicyCancel);
            // handle
        }];
        
    } if (code) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self requestAuthTokenWithCode:code];
        [self.webView removeFromSuperview];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)requestAuthTokenWithCode:(NSString *)code {
    NSString *urlString = [NSString stringWithFormat:@"%@token", OAuth2BaseUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *params = @{
                             @"client_id": self.accessKey,
                             @"client_secret": self.secretKey,
                             @"redirect_uri": self.redirectURI,
                             @"code": code,
                             @"grant_type": @"authorization_code"
                             };
    
    NSData *body = [NSJSONSerialization
                        dataWithJSONObject:params
                        options:kNilOptions
                        error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:nil];
    
    NSURLSessionDataTask *task = [self.session
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                      
                                      if (error) {
                                          NSLog(@"Error: %@", error.localizedDescription);
                                          return;
                                      }
                                      
                                      NSError *parsingError = nil;
                                      NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parsingError];
                                      
                                      if (parsingError) {
                                          NSLog(@"Error parsin JSON: %@", parsingError.localizedDescription);
                                          return;
                                      }
                                      
                                      NSLog(@"Dic: %@", jsonDic);
    }];
    [task resume];
}

#pragma mark - Utils

- (UIColor *)getRandomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
