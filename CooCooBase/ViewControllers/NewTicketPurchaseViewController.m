//
//  NewTicketPurchaseViewController.m
//  Pods
//
//  Created by Andrey Kasatkin on 2/25/16.
//
//

#import "NewTicketPurchaseViewController.h"
#import "LoginViewController.h"
#import "StoredData.h"
#import "TicketsViewController.h"
#import "Utilities.h"
//#import "GetProductsService.h"
//#import "OrdersCreationService.h"



@interface NewTicketPurchaseViewController ()

@end

@implementation NewTicketPurchaseViewController{
    WKWebView *newWebView;
    NSString *startPageUrl;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    /*
     NSArray *cards = [[Utilities getCards:self.managedObjectContext] copy];
     if(cards.count > 0){
     OrdersCreationService * ordersCreationService = [[OrdersCreationService alloc] initWithListener:self managedObjectContext:self.managedObjectContext card:[cards objectAtIndex:0] array:purchaseTicketsArray];
     [ordersCreationService execute];
     NSError * error = nil;
     }
     */
    
    
    
    
    
    
    
}
#pragma mark - Background service declaration and callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    /*
     [self dismissProgressDialog];
     
     if ([service isMemberOfClass:[GetProductsService class]]) {
     NSLog(@"Get Products Success");
     
     }else if ([service isMemberOfClass:[OrdersCreationService class]]) {
     NSLog(@"OrdersCreationService Success");
     
     }
     */
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    /*
     [self dismissProgressDialog];
     
     if ([service isMemberOfClass:[GetProductsService class]]) {
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
     message:@"Unable to get Products. Please try again later."
     delegate:self
     cancelButtonTitle:@"Close"
     otherButtonTitles:nil, nil];
     
     [alertView show];
     }
     */
    
}





- (void)loadWebView {
    [self loadWkWebView];
}

- (void)loadWkWebView {
    newWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    newWebView.navigationDelegate = self;
    [self.webViewPlaceholder addSubview:newWebView];
    NSString *walletid = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    NSString *orderid = [[NSUserDefaults standardUserDefaults]valueForKey:@"ORDER_ID"];
    [newWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:newWebView attribute: NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.webViewPlaceholder attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:newWebView attribute: NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.webViewPlaceholder attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    [self.view addConstraints:@[height, width]];
    
    NSString *ischecked  =  [[NSUserDefaults standardUserDefaults] valueForKey:@"IS_CHECKED"];
    
    NSString *urlString = @"";
    
    NSString *tenantId = [Utilities tenantId];
    
    if(self.card){
        urlString = [NSString stringWithFormat:@"https://%@/services/data-api/mobile/payment/page?tenant=%@&orderId=%@&walletId=%@&savedCardId=%@",[Utilities dev_ApiHost],tenantId,orderid,walletid,self.card.cardNumber
                     .stringValue];
    }
    else{
        urlString = [NSString stringWithFormat:@"https://%@/services/data-api/mobile/payment/page?tenant=%@&orderId=%@&walletId=%@&saveForFuture=%@",[Utilities dev_ApiHost],tenantId,orderid,walletid,ischecked];
    }

    NSString * deviceId = [Utilities deviceId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60.0];
    NSString * base64String = [Utilities accessToken];
    [request setValue:[NSString stringWithFormat:@"bearer %@", base64String] forHTTPHeaderField:@"Authorization"];
    NSString * currentAppVersion = [Utilities appCurrentVersion];
    [request setValue:@"iOS" forHTTPHeaderField:@"app_os"];
    [request setValue:currentAppVersion forHTTPHeaderField:@"app_version"];
    [request setValue:deviceId forHTTPHeaderField:@"DeviceId"];
    [newWebView loadRequest:request];
    
}

#pragma mark - WKWebView delegate methods
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSURLRequest *request = navigationAction.request;
    NSString *url = [[request URL]absoluteString];
    NSLog(@"url is %@", url);
    
    // Add this IF statement in my project,  don`t need modify WebViewJavascriptBridge`s source code.
    
    if (![startPageUrl isEqualToString:url] && ([url rangeOfString:@"checkout"].location == NSNotFound)
        && ([url rangeOfString:NATIVE_COMMAND].location == NSNotFound)) {
        startPageUrl = url;
    }
    
    if (navigationAction.navigationType == UIWebViewNavigationTypeFormSubmitted) {
        if ([url rangeOfString:@"checkout"].location != NSNotFound) {
            [self putButtonBack];
        }
    }
    
    if ([url hasPrefix:NATIVE_COMMAND]) {
        NSRange commandRange = [url rangeOfString:NATIVE_COMMAND options:NSBackwardsSearch];
        NSRange parametersRange = [url rangeOfString:@"/" options:NSBackwardsSearch];
        
        NSString *command = [url substringWithRange:NSMakeRange(commandRange.length, parametersRange.location - commandRange.length)];
        
        if ([command isEqualToString:FORGOT_PASSWORD_COMMAND]) {
            [self putButtonBack];
            [self goToForgotPassword];
            
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else {
            NSString *parameters = [url substringWithRange:NSMakeRange(parametersRange.location + 1, [url length] - parametersRange.location - 1)];
            
            NSDictionary *parametersDictionary = [self parseParameters:parameters];
            
            if ([command isEqualToString:TOKEN_COMMAND]) {
                NSString *authToken = [parametersDictionary objectForKey:TOKEN_TITLE];
                if ([authToken length] > 0) {
                    NSString *email = [parametersDictionary objectForKey:TOKEN_EMAIL];
                    
                    [self loginWithAuthToken:authToken email:email];
                }
                
                [webView reload];
            } else {
                [self processNativeCallback:command parameters:parametersDictionary];
            }
            
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    } else if ([url rangeOfString:@"finished"].location != NSNotFound) {
        [self callTokenService];
    } else if ([url rangeOfString:@"thank_you"].location != NSNotFound){
        [self putButtonHome];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation: (WKNavigation *)navigation {
    NSString *urlString = [webView.URL absoluteString];
    
    if (![urlString containsString:@"purchase/proxy_form"]) {
        [self showProgressDialog];
    }
}


- (void)webView:(WKWebView *)webView didFailNavigation: (WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"fail navigation");
    [self dismissProgressDialog];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"commit navigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"finish navigation");
    [self dismissProgressDialog];
}



#pragma mark - Other methods

- (void)loadUrl:(NSString *)urlString
{
    [super loadUrl:(NSString*)urlString];
    NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [newWebView loadRequest:requestUrl];
}

- (void)goBack
{
    [newWebView goBack];
    if (![newWebView canGoBack]){
        NSLog(@"start page");
        [self putButtonHome];
    }
}

@end

