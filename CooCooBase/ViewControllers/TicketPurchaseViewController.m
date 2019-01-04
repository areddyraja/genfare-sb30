//
//  TicketPurchaseViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TicketPurchaseViewController.h"
#import "AuthorizeTokenService.h"
#import "ForgotLoginViewController.h"
#import "GetTokensService.h"
#import "Reachability.h"
#import "StoredData.h"
#import "TicketsViewController.h"
#import "Utilities.h"
#import "LoginViewController.h"

@interface TicketPurchaseViewController ()

@end

@implementation TicketPurchaseViewController
{
    BOOL isViewingPayPalLogin;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Purchase" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    UserData *userData = [StoredData userData];
    
    if ([userData.authToken length] > 0) {
        [self showProgressDialog];
        /*SAAS
        AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self
                                                                                     username:userData.email
                                                                                    authToken:userData.authToken];
         [tokenService execute];

         */
    } else {
        /*NSString *urlString = [[NSString stringWithFormat:@"%@/ticketpurchase/?deviceid=%@&transitid=%@&authtoken=&station1=%@&station2=%@",
                                [Utilities apiUrl],
                                [Utilities deviceId],
                                [Utilities transitId],
                                self.departStation,
                                self.arriveStation] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];*/
        NSString *urlString = [[NSString stringWithFormat:@"%@/%@/?deviceid=%@",
                                [Utilities stringInfoForId:@"purchase_link"],
                                [Utilities transitId],
                                [Utilities deviceId]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSLog(@"urlString = %@",urlString);
        [self testUrlString:urlString];
        //[self loadUrl:urlString];
    }
}

- (void) loadWebView {
    [self testUrlString:self.firstUrl];
}

-(void)testUrlString:(NSString *)url
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIAlertView *alertView = [self offlineAlertViewWithDelegate:self tag:TAG_OFFLINE];
        [alertView show];
    } else {
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        int code = (int)[response statusCode];
        
        if ((code < 400) && (code > 0)) {
            [self loadUrl:url];
        } else {
            [self.webMessageLabel setText:[Utilities stringResourceForId:@"page_unavailable"]];
            
            //Logging Error
            NSDate *date = [[NSDate alloc] init];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            
            NSError *error = nil;
            NSString *directoryPath= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
            NSString *filePath = [NSString stringWithFormat:@"%@/ERRORS",directoryPath];
            NSString *entry = [NSString stringWithFormat:@"%@ UTC , HTTP:%d , %@ , %@ , %@"
                               , [dateFormat stringFromDate:date]
                               , code
                               ,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                               , [UIDevice currentDevice].systemVersion
                               , @"iOS"];
            
            NSLog(@"\n\nERROR LOG - %@\n\n",entry);
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSMutableData *file = [NSMutableData dataWithContentsOfFile:filePath];
                [file appendData:[entry dataUsingEncoding:NSUTF16StringEncoding]];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                [[NSFileManager defaultManager] createFileAtPath:filePath contents:file attributes:nil];
            } else {
                NSData *file = [entry dataUsingEncoding:NSUTF16StringEncoding];
                [[NSFileManager defaultManager] createFileAtPath:filePath contents:file attributes:nil];
            }
        }
    }
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

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service
{
    if ([service isMemberOfClass:[AuthorizeTokenService class]]) {
        UserData *userData = [StoredData userData];
        NSString *urlString = [[NSString stringWithFormat:@"%@/%@/?deviceid=%@&authtoken=%@",
                                [Utilities stringInfoForId:@"purchase_link"],
                                [Utilities transitId],
                                [Utilities deviceId],
                                userData.authToken] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        [self loadUrl:urlString];
    }
    
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service
{

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logged Out"
                                                        message:@"You have been logged out. Please login again or continue as a guest user."
                                                       delegate:self
                                              cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                              otherButtonTitles:[Utilities stringResourceForId:@"login"], nil];
    [alertView setTag:TAG_LOGGED_OUT];
    [alertView show];
    
    NSString *urlString = [[NSString stringWithFormat:@"%@/%@/?deviceid=%@",
                            [Utilities stringInfoForId:@"purchase_link"],
                            [Utilities transitId],
                            [Utilities deviceId]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [self loadUrl:urlString];
    
    [self dismissProgressDialog];
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    
    NSLog(@"shouldStartLoad url: %@", url);
    
    if ((navigationType == UIWebViewNavigationTypeFormSubmitted) && ([url rangeOfString:@"checkout"].location != NSNotFound)) {
        [self showBackButton];
    }
    
    if ([url hasPrefix:NATIVE_COMMAND]) {
        NSRange commandRange = [url rangeOfString:NATIVE_COMMAND options:NSBackwardsSearch];
        NSRange parametersRange = [url rangeOfString:@"/" options:NSBackwardsSearch];
        
        NSString *command = [url substringWithRange:NSMakeRange(commandRange.length, parametersRange.location - commandRange.length)];
        
        
        if ([command isEqualToString:FORGOT_PASSWORD_COMMAND]) {
            [self goToForgotPassword];
        }
        
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
        
        return NO;
    } else if ([url rangeOfString:@"finished"].location != NSNotFound) {
        GetTokensService *tokensService = [[GetTokensService alloc] initWithListener:nil
                                                                managedObjectContext:self.managedObjectContext];
        [tokensService setGetTokenOfDay:YES];
        [tokensService execute];
    } else if ([url rangeOfString:@"thank_you"].location != NSNotFound) {
        [self showHomeButton];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *urlString = [[webView.request URL] absoluteString];
    
    NSLog(@"webViewDidStartLoad url: %@", urlString);
    
    // We can run a 'double back' action to navigate back from the PayPal login screen.
    // HOWEVER, once logged in, back navigation from the PayPal environment will always
    // redirect to PayPal's acceptance screen. A user can only back out of the PayPal
    // environment by tapping on the hyperlinks provided by PayPal.
    if ([urlString containsString:@"proxy_form?"]) {
        isViewingPayPalLogin = YES;
    } else {
        isViewingPayPalLogin = NO;
        
        [self showProgressDialog];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinish url: %@", webView.request.URL.absoluteString);
    
    if ([webView.request.URL.absoluteString rangeOfString:@"finished"].location != NSNotFound) {
        [self showHomeButton];
    }
    
    [self dismissProgressDialog];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView didFailWithError: %@", error.description);
    
    [self dismissProgressDialog];
}

#pragma mark - Other methods

- (void)loadUrl:(NSString *)urlString
{
    NSLog(@"------------------------ loadUrl: %@", urlString);
    
    NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [self.webView loadRequest:requestUrl];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (NSDictionary *)parseParameters:(NSString *)parameters
{
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *pairs = [parameters componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in pairs) {
        NSRange separatorRange = [keyValuePair rangeOfString:@"=" options:NSBackwardsSearch];
        NSString *key = [keyValuePair substringToIndex:separatorRange.location];
        NSString *value = [keyValuePair substringFromIndex:separatorRange.location + 1];
        
        [parametersDictionary setValue:value forKey:key];
    }
    
    return parametersDictionary;
}

- (void)processNativeCallback:(NSString *)command parameters:(NSDictionary *)parameters
{
    if ([command isEqualToString:ALERT_COMMAND]) {
        NSString *alertTitle = [parameters objectForKey:ALERT_TITLE];
        if ([alertTitle length] == 0) {
            alertTitle = [Utilities stringResourceForId:@"requestErrorTitle"];
        }
        
        NSString *alertMessage = [parameters objectForKey:ALERT_MESSAGE];
        if ([alertMessage length] == 0) {
            alertMessage = [Utilities stringResourceForId:@"requestErrorMessage"];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    } else if ([command isEqualToString:TICKETS_COMMAND]) {
        [self goToTicketsHome];
    }
}

- (void)loginWithAuthToken:(NSString *)authToken email:(NSString *)email
{
    UserData *userData = [StoredData userData];
    
    [userData setAuthToken:authToken];
    [userData setEmail:email];
    [userData setLoggedIn:YES];
    
    [StoredData commitUserDataWithData:userData];
}

- (void)goBack
{
    if (isViewingPayPalLogin) {
        [self.webView goBack];
        [self.webView goBack];
        
        isViewingPayPalLogin = NO;
    } else {
        [self.webView goBack];
    }
    
    if (![self.webView canGoBack]) {
        [self showHomeButton];
    }
}

- (void)showBackButton
{
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"back"]
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(goBack)]];
}

- (void)showHomeButton
{
    [self.navigationItem setHidesBackButton:YES animated:NO];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"home"]
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(goHome)]];
}

- (void)goToTicketsHome
{
    TicketsViewController *ticketsView = [[TicketsViewController alloc] initWithNibName:@"TicketsViewController" bundle:nil];
    [ticketsView setManagedObjectContext:self.managedObjectContext];
    
    if (self.createCustomBarcodeViewController) {
        [ticketsView setCreateCustomBarcodeViewController:self.createCustomBarcodeViewController];
    }
    
    if (self.createCustomSecurityViewController) {
        [ticketsView setCreateCustomSecurityViewController:self.createCustomSecurityViewController];
    }
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
    [viewControllers removeObjectsInRange:NSMakeRange(1, [viewControllers count] - 1)];
    [viewControllers addObject:ticketsView];
    NSLog(@"%@ Ticket purchase view controller",viewControllers);
    [[self navigationController] setViewControllers:viewControllers animated:YES];
}

- (void)goToForgotPassword
{
    ForgotLoginViewController *forgotPasswordView = [[ForgotLoginViewController alloc] initWithNibName:@"ForgotLoginViewController" bundle:nil];
    [forgotPasswordView setManagedObjectContext:self.managedObjectContext];
    
    [self.navigationController pushViewController:forgotPasswordView animated:YES];
}

- (void)goHome
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_LOGGED_OUT:
            if (buttonIndex == 0) {
                // Logout
                [StoredData removeUserData];
            } else if (buttonIndex == 1) {
                // Login
                LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                
                [self.navigationController pushViewController:loginView animated:YES];
            }
            break;
            
        case TAG_OFFLINE:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}

@end
