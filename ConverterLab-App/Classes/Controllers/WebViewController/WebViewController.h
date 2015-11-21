//
//  WebViewController.h
//  ConverterLab-App
//
//  Created by Admin on 21.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSURL *bankLinkURL;

@end
