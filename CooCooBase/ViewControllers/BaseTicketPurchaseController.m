//
//  BaseTicketPurchaseController.m
//  Pods
//
//  Created by Andrey Kasatkin on 2/25/16.
//
//

#import "BaseTicketPurchaseController.h"
#import "ForgotLoginViewController.h"
#import "LoginViewController.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "TicketsViewController.h"
#import "Utilities.h"

@implementation BaseTicketPurchaseController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:[Utilities stringResourceForId:@"purchase_tickets"]];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Purchase" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    if ([self.accountUuid length] > 0) {
        self.firstUrl = [self getFirstURLForLoggedInUsers];
        [self loadWebView];
    } else {
        self.firstUrl = [self getFirstURLForNonLoggedInUsers];
        [self loadWebView];
    }
    
    [self setIsHomeButton:YES];
}

- (void) loadWebView{
    //implemented by childs
}

- (NSString *)getFirstURLForNonLoggedInUsers
{
    return [[NSString stringWithFormat:@"%@/%@/?deviceid=%@",
             [Utilities stringInfoForId:@"purchase_link"],
             [Utilities transitId],
             [RuntimeData ticketSourceId:self.managedObjectContext]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
}

- (NSString *)getFirstURLForLoggedInUsers
{
    return  [[NSString stringWithFormat:@"%@/%@/?deviceid=%@&accountuuid=%@",
              [Utilities stringInfoForId:@"purchase_link"],
              [Utilities transitId],
              [RuntimeData ticketSourceId:self.managedObjectContext],
              self.accountUuid] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
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

- (void)loadUrl:(NSString *)urlString
{
    //implemented by childs
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

- (void)goToForgotPassword
{
    NSLog(@"goToForgotPassword");
    
    ForgotLoginViewController *forgotloginView = [[ForgotLoginViewController alloc] initWithNibName:@"ForgotLoginViewController" bundle:[NSBundle baseResourcesBundle]];
    
    [self.navigationController pushViewController:forgotloginView animated:YES];
}

- (void)goToTicketsHome
{
    
    for(UIViewController* viewcontroller in self.navigationController.viewControllers){
        NSString *classname=[NSString stringWithFormat:@"%@",[viewcontroller class]];
        if([classname isEqualToString:@"CDTATicketsViewController"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTickets" object:nil];
            [self.navigationController popToViewController:viewcontroller animated:YES];
            break;
        }
        else if([classname isEqualToString:@"CDTA_AccountBasedViewController"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTickets" object:nil];
            [self.navigationController popToViewController:viewcontroller animated:YES];
            break;
        }
    }
   
//    return;
//    BaseTicketsViewController *ticketsView;
//    
//    if (self.createCustomTicketsViewController) {
//        ticketsView = self.createCustomTicketsViewController();
//    } else {
//        ticketsView = [[TicketsViewController alloc] initWithNibName:@"TicketsViewController" bundle:nil];
//    }
//    [ticketsView setManagedObjectContext:self.managedObjectContext];
//    
//    if (self.createCustomBarcodeViewController) {
//        [ticketsView setCreateCustomBarcodeViewController:self.createCustomBarcodeViewController];
//    }
//    
//    if (self.createCustomSecurityViewController) {
//        [ticketsView setCreateCustomSecurityViewController:self.createCustomSecurityViewController];
//    }
//    
//    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
//    //[viewControllers removeObjectsInRange:NSMakeRange(1, [viewControllers count] - 2)];
//    //[viewControllers addObject:ticketsView];
//    NSArray *controllerArray = [NSArray arrayWithObjects:[viewControllers objectAtIndex:0],[viewControllers objectAtIndex:1],[viewControllers objectAtIndex:2],nil];
//   // NSArray *controllerArray = [NSArray arrayWithObjects:[viewControllers objectAtIndex:2], nil];
//    NSLog(@"%@ Base Ticket purchase view controller",controllerArray);
//    [[self navigationController] setViewControllers:controllerArray animated:YES];
}

- (void)goHome
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loginWithAuthToken:(NSString *)authToken email:(NSString *)email
{
    UserData *userData = [StoredData userData];
    
    [userData setAuthToken:authToken];
    [userData setEmail:email];
    [userData setLoggedIn:YES];
    
    [StoredData commitUserDataWithData:userData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 1) {
        if (buttonIndex == 0) {
            // Logout
            [StoredData removeUserData];
        } else if (buttonIndex == 1) {
            // Login
            LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            
            [self.navigationController pushViewController:loginView animated:YES];
        }
    }
}

- (void)callTokenService
{
    GetTokensService *tokensService = [[GetTokensService alloc] initWithListener:nil
                                                            managedObjectContext:self.managedObjectContext];
    [tokensService setGetTokenOfDay:YES];
    [tokensService execute];
}

#pragma mark Navigation Bar Button Modifications

- (void)goBack
{
    //implemented by childs
}

-(BOOL) navigationShouldPopOnBackButton {
    if(![self isHomeButton]) {
        [self goBack];
        return NO; // Ignore 'Back' button this time
    }
    return YES; // Process 'Back' button click and Pop view controler
}

- (void)putButtonBack{
    // Get the previous view controller
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:nil];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    [self setIsHomeButton:NO];
}

- (void)putButtonHome{
    // Get the previous view controller
    
    
    for(id viewcontroller in self.navigationController.viewControllers){
        NSLog(@"view controller %@",[viewcontroller class]);
    }
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    // Create a UIBarButtonItem
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:nil];
    
    // Associate the barButtonItem to the previous view
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    
    [self setIsHomeButton:YES];
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];

}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];

}

@end
