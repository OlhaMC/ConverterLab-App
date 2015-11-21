//
//  WebViewController.m
//  ConverterLab-App
//
//  Created by Admin on 21.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:self.bankLinkURL];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.view bringSubviewToFront:self.indicator];
    [self.indicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.indicator stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

@end
