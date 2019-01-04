//
//  PurchaseWebViewController.m
//  CooCooBase
//
//  Created by IBase Software on 27/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "PurchaseWebViewController.h"
#import "Utilities.h"
#import "CooCooBase.h"

@interface PurchaseWebViewController ()<UIWebViewDelegate>
@end

@implementation PurchaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Purchase" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
//    self.pageButton1.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
//    self.pageButton2.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
//    self.pageButton3.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
    
    NSString *walletid = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    NSString *orderid = [[NSUserDefaults standardUserDefaults]valueForKey:@"ORDER_ID"];
    self.loadWebView.delegate = self;
    
    NSString *tenantId = [Utilities tenantId];
    NSString *host = [Utilities dev_ApiHost];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/services/data-api/mobile/payment/page?tenant=%@&orderId=%@&walletId=%@",host,tenantId,orderid,walletid];
    
    NSLog(@"url string %@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60.0];
    NSString * base64String = [Utilities accessToken];
    [request setValue:[NSString stringWithFormat:@"bearer %@", base64String] forHTTPHeaderField:@"Authorization"];
     [self.loadWebView loadRequest:request];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"url: %@", [[request URL] absoluteString]);
    if ([[[request URL] absoluteString] containsString:@"ticketshome"]) {
        
    //    [self.navigationController popToRootViewControllerAnimated:YES];

    }
    
    return YES;
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinish url: %@", webView.request.URL.absoluteString);
    
    if ([webView.request.URL.absoluteString rangeOfString:@"finished"].location != NSNotFound) {
       // [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [self dismissProgressDialog];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
