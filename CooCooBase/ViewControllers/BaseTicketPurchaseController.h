//
//  BaseTicketPurchaseController.h
//  Pods
//
//  Created by Andrey Kasatkin on 2/25/16.
//
//

#import "BaseViewController.h"
#import "BasePageViewController.h"
#import "GetTokensService.h"
#import "AuthorizeTokenService.h"
#import "BaseTicketsViewController.h"


static NSString *const NATIVE_COMMAND = @"coocoo://";
static NSString *const TOKEN_COMMAND = @"setauthtoken";
static NSString *const ALERT_COMMAND = @"alert";
static NSString *const TICKETS_COMMAND = @"ticketshome";
static NSString *const FORGOT_PASSWORD_COMMAND = @"forgotpassword";
static NSString *const ALERT_TITLE = @"title";
static NSString *const ALERT_MESSAGE = @"message";
static NSString *const TOKEN_TITLE = @"token";
static NSString *const TOKEN_EMAIL = @"emailaddress";

static NSInteger const TAG_LOGGED_OUT = 1;
static NSInteger const TAG_OFFLINE = 2;

@interface BaseTicketPurchaseController : BaseViewController <ServiceListener>

@property (nonatomic, copy) BaseTicketsViewController *(^createCustomTicketsViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomBarcodeViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomSecurityViewController)();

@property (nonatomic, strong) NSString *firstUrl;
@property (nonatomic, assign) BOOL isHomeButton;
@property (nonatomic, strong) NSString *accountUuid;

- (void)loadWebView;

- (void)processNativeCallback:(NSString *)command parameters:(NSDictionary *)parameters;
- (void)loadUrl:(NSString *)urlString;
- (NSDictionary *)parseParameters:(NSString *)parameters;
- (void)goToForgotPassword;
- (void)goToTicketsHome;
- (void)goHome;
- (void)loginWithAuthToken:(NSString *)authToken email:(NSString *)email;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)callTokenService;

- (void)goBack;
- (void)putButtonBack;
- (void)putButtonHome;

@end
