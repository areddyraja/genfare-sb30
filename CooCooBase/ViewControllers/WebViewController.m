//
//  WebViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
{
    NSString *url;
    BOOL showProgressDialog;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                title:(NSString *)title
                  url:(NSString *)urlString
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:title];
        
        url = urlString;
        showProgressDialog = YES;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
                title:(NSString *)title
                  url:(NSString *)urlString
   showProgressDialog:(BOOL)show
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:title];
        
        url = urlString;
        showProgressDialog = show;
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/"]];
    
    [self.webView loadRequest:requestUrl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

#pragma mark - UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (showProgressDialog) {
//        [self showProgressDialog];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (showProgressDialog) {
//        [self dismissProgressDialog];
    }
}

@end
