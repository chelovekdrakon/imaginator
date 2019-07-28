//
//  ViewController.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/27/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "LoginViewController.h"
#import <WebKit/WebKit.h>

NSString * const OAuth2BaseUrl = @"https://unsplash.com/oauth/";
NSString * const userDefaultsTokens = @"user_access_token";

@interface LoginViewController () <WKUIDelegate, WKNavigationDelegate>
@property(retain, nonatomic) NSString *secretKey;
@property(retain, nonatomic) NSString *accessKey;
@property(retain, nonatomic) NSString *redirectURI;

@property(retain, nonatomic) NSURLSession *session;
@property(retain, nonatomic) WKWebView *webView;
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
    
    [_secretKey release];
    [_accessKey release];
    [_redirectURI release];
    
    [_session release];
    [_webView release];
    
    NSLog(@"LoginVC deallocated!");
}

- (void)loadView {
    [super loadView];
    
    WKWebViewConfiguration *wvConfig = [[WKWebViewConfiguration alloc] init];
    
    self.webView = [[WKWebView alloc] initWithFrame:[self.view bounds] configuration:wvConfig];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    self.view = self.webView;
    
    [wvConfig release];
    [self.webView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlString = [NSString stringWithFormat:@"%@authorize", OAuth2BaseUrl];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:urlString];
    urlComponents.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"client_id" value:self.accessKey],
        [NSURLQueryItem queryItemWithName:@"redirect_uri" value:self.redirectURI],
        [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
        [NSURLQueryItem queryItemWithName:@"scope" value:@"public"],
    ];
    
    NSString *authHeader = [NSString stringWithFormat:@"Client-ID %@", self.accessKey];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlComponents.URL];
    [request setAllHTTPHeaderFields:@{
                                      @"Accept-Language":@"en",
                                      @"Authorization":authHeader,
                                      @"Accept":@"application/json",
                                      }];
    
    [self.webView loadRequest:request];
    
    [urlComponents release];
    [request release];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    
    NSString *code = nil;
    
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"code"]) {
            code = item.value;
            break;
        }
    }

    if (code) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self requestAuthTokenWithCode:code];
        [self.webView removeFromSuperview];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)requestAuthTokenWithCode:(NSString *)code {
    NSString *urlString = [NSString stringWithFormat:@"%@token", OAuth2BaseUrl];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlString];
    urlComponents.queryItems = @[
                              [NSURLQueryItem queryItemWithName:@"code" value:code],
                              [NSURLQueryItem queryItemWithName:@"client_id" value:self.accessKey],
                              [NSURLQueryItem queryItemWithName:@"client_secret" value:self.secretKey],
                              [NSURLQueryItem queryItemWithName:@"redirect_uri" value:self.redirectURI],
                              [NSURLQueryItem queryItemWithName:@"grant_type" value:@"authorization_code"],
                              ];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlComponents.URL];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *task = [self.session
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                      
                                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                      
                                      if (httpResponse.statusCode != 200) {
                                          NSLog(@"Response status code: %ld", httpResponse.statusCode);
                                          return;
                                      }

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
                                      
                                      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                      [userDefaults setObject:jsonDic forKey:userDefaultsTokens];
    }];
    
    [task resume];
}

@end
