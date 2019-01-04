//
//  BaseViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "AppConstants.h"
#import "UIColor+HexString.h"
#import "Utilities.h"
#import "StoredData.h"
#import "Account.h"
#import "CooCooAccountUtilities1.h"
#import "CheckWalletService.h"
#import "GetOAuthService.h"
#import "GetAppUpdateService.h"
#import "Singleton.h"
#import "AppDelegate.h"
#import "SignInViewController.h"
#import "iRide-Swift.h"

//#import "WebViewController.h"

int const APP_UPDATE_TAG = 99;


//float const STATUS_BAR_HEIGHT = 20;
//float const NAVIGATION_BAR_HEIGHT = 44;
float const HELP_SLIDER_PADDING = 1;
float const TOUCH_PADDING = 60;


@interface BaseViewController ()

@end

@implementation BaseViewController
{
    UIView *spinnerView;
    CGFloat helpSliderOrigin;
    BOOL isTouchingTopBar;
    CGFloat maxBarPointY;
    BOOL firstLoad;
    CGFloat originalHeight;
    UserData *userData;
    float deviceStatusBar;
    UIAlertView * appUpdateAlertView;
    BOOL isAuthorizeTokenService;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([nibBundleOrNil pathForResource:nibNameOrNil ofType:@"nib"] != nil) {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    } else {
        self = [super initWithNibName:nibNameOrNil bundle:[NSBundle baseResourcesBundle]];
    }
    
    if (self) {
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            [self setEdgesForExtendedLayout:UIRectEdgeTop];
        } else {
            maxBarPointY = NAVIGATION_BAR_HEIGHT + HELP_SLIDER_HEIGHT;
        }
    }
    userData = [StoredData userData];
    firstLoad = YES;
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[Singleton sharedManager] setCurrentNVC:self.navigationController];

    [self removeHelpSliderFromWindow];
    
    NSLog(@"Git Ignore checking.");
    isAuthorizeTokenService = NO;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAuthorizeTokenService) name:@"callAuthorizeTokenService" object:nil];
    deviceStatusBar = [Utilities statusBarHeight];
    // Set the background for all screens that extend BaseViewController
    [self.view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities mainBgColor]]]];
    
    CGRect applicationRect = [[UIScreen mainScreen] bounds];
    //    helpSliderOrigin = applicationRect.size.height + deviceStatusBar - HELP_SLIDER_HEIGHT;
    helpSliderOrigin = applicationRect.size.height - HELP_SLIDER_HEIGHT;
    self.helpSlider = [[HelpSliderView alloc] initWithFrame:CGRectMake(0,
                                                                       helpSliderOrigin,
                                                                       applicationRect.size.width,
                                                                       applicationRect.size.height - NAVIGATION_BAR_HEIGHT)
                                                    isLight:[Utilities isLightTheme]];
    self.helpSlider.tag = 1001;
    [self.helpSlider initializeWithBarColor:[UIColor whiteColor]];
    // NSLog(@"helpSlider.frame = %@",NSStringFromCGRect(self.helpSlider.frame));
    [self addGesturesToHelpSlider];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    UIView *oldView = [mainWindow viewWithTag:1001];
    [oldView removeFromSuperview];
    [mainWindow addSubview:self.helpSlider];
    [mainWindow bringSubviewToFront:self.helpSlider];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
  
    
    NSString * accessToken = [Utilities accessToken];
    if (!accessToken) {
        [self showProgressDialog];
        GetOAuthService * getOAuthService = [[GetOAuthService alloc] initWithListener:self];
        [getOAuthService execute];
    }else{
    }
//    if (self.helpSlider != nil) {
//        UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
//        [mainWindow addSubview:self.helpSlider];
//    }
    UserData *userData = [StoredData userData];
    if ([userData isLoggedIn] == YES) {
      //  NSLog(@"Already Logged in");
    }else{
       // NSLog(@"Not Logged in");
        return;
    }
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        CheckWalletService *walletService = [[CheckWalletService alloc] initWithListener:self emailid:account.emailaddress managedContext:self.managedObjectContext];
        [walletService execute];
    }
    
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@NavBarColor",[[Utilities tenantId] lowercaseString]]]];

}

-(void)addGesturesToHelpSlider {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doubleTapAction:)];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setDelegate:self];
    [self.helpSlider addGestureRecognizer:doubleTap];
}

-(void)callAuthorizeTokenService{
}

-(void)removeHelpSliderFromWindow {
    AppDelegate *aDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *subviews = aDelegate.window.subviews;
    
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[HelpSliderView class]] ) {
            [subview removeFromSuperview];
        }
    }
}

#pragma - SideMenu observers and handlers

-(void)sideMenuWillAppearWithMenu:(UISideMenuNavigationController *)menu animated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUISideMenuIsVisible" object:nil];
}

-(void)showLoginScreen:(NSNotification *)notification {
    Singleton *singleton = [Singleton sharedManager];
    SignInViewController *signIn = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
    signIn.managedObjectContext = singleton.managedContext;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signIn];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)showSideMenu:(UIButton *)sender {
    NSLog(@"Show Side Menu %@",[StoredData userData].email);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Sidemenu" bundle:nil];
    UISideMenuNavigationController *controller = [sb instantiateInitialViewController];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)dismissController:(id)sender {
    [self.helpSlider removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!self.refactorView)
    {
    }
    // Prevent window height from continuously subtracting if user swipes a screen back and forth
    if (firstLoad) {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       self.view.frame.origin.y,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height - HELP_SLIDER_HEIGHT)];
        
        originalHeight = self.view.frame.size.height;
        firstLoad = NO;
    } else {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       self.view.frame.origin.y,
                                       self.view.frame.size.width,
                                       originalHeight)];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self.helpSlider removeFromSuperview];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - View controls

- (void)doubleTapAction:(UITapGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.helpSlider.isExpanded) {
            [UIView animateWithDuration:0.7f animations:^{
                [self.helpSlider setTransform:CGAffineTransformIdentity];
                [self.helpSlider setFrame:CGRectMake(0,
                                                     NAVIGATION_BAR_HEIGHT + HELP_SLIDER_PADDING,
                                                     self.helpSlider.frame.size.width,
                                                     self.helpSlider.frame.size.height + NAVIGATION_BAR_HEIGHT)];
            }];
            
            [self.helpSlider onExpand];
        } else {
            [UIView animateWithDuration:0.3f animations:^{
                [self.helpSlider setTransform:CGAffineTransformIdentity];
                [self.helpSlider setFrame:CGRectMake(0,
                                                     helpSliderOrigin,
                                                     self.helpSlider.frame.size.width,
                                                     self.helpSlider.frame.size.height)];
            }];
            
            [self.helpSlider onCollapse];
        }
    }
}

-(void)getAppUpdateSupportingMethod:(id)response{
    NSDictionary *responseDict=[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    responseDict = [responseDict dictionaryRemovingNSNullValues];
    NSDictionary *resultDict = [responseDict valueForKey:@"result"];
    BOOL doUpdate = [[resultDict valueForKey:@"update"] boolValue];
    NSString * currentAppVersion = [Utilities appCurrentVersion];
    NSString * minAppVersion = [resultDict valueForKey:@"minAppVersion"];
    NSString *message = [NSString stringWithFormat:@"You are using %@ version \n%@ version is available \nClick OK button to update \nthe app from Appstore",currentAppVersion,minAppVersion];
    if (doUpdate == YES) {
        //                    [[Singleton sharedManager] showAlert:@"Update Available" message:message];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountBased" bundle:nil];
        CustomAlertAppUpdateController *appUpdate=[storyboard instantiateViewControllerWithIdentifier:@"appUpdate"];
        [appUpdate setResponse:responseDict];
        appUpdate.delegate=self;
        appUpdate.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        appUpdate.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        
        if ([[Singleton sharedManager] isAppUpdateAlertPresented] == YES) {
            [[Singleton sharedManager] setIsAppUpdateAlertPresented:NO];
            NSLog(@"Alert exists");
        }else{
            [[Singleton sharedManager] setIsAppUpdateAlertPresented:YES];
            NSLog(@" please present alert here.");
            [self presentViewController:appUpdate animated:NO completion:nil];
        }
    }
}


#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service  response:(id)response
{
    [self dismissProgressDialog];
        if([service isMemberOfClass:[GetAppUpdateService class]]){
            [self getAppUpdateSupportingMethod:response];
        }
    if ([service isMemberOfClass:[AuthorizeTokenService class]]) {
        userData = [StoredData userData];
        
    }
    
    else if ([service isMemberOfClass:[CheckWalletService class]]) {
        
    }else if ([service isMemberOfClass:[GetOAuthService class]]) {
        
    }
}

- (void)threadErrorWithClass:(id)service  response:(id)response
{
    [self dismissProgressDialog];
}


#pragma mark - Common methods

- (void)showProgressDialog
{
    id objSpinner = [self.view viewWithTag:TAG_SPINNER];
    if([objSpinner isKindOfClass:[UIView class]]){
        UIView * spinView = (UIView *)objSpinner;
        [spinView removeFromSuperview];
        spinView = nil;
    }
    BOOL netWorkAvailable = [Utilities isNetWorkAvailable];
    if(!netWorkAvailable){
        return;
    }
    // Spinner shadow
    spinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [spinnerView setTag:TAG_SPINNER];
    [spinnerView setBackgroundColor:[UIColor blackColor]];
    [spinnerView setAlpha:0.40];
    
    // Spinner
    CGRect spinnerFrame = CGRectMake(0, 0, 100, 100);
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setCenter:CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 20)];
    [spinner startAnimating];
    
    [spinnerView addSubview:spinner];
    
    [self.view addSubview:spinnerView];
}

- (void)dismissProgressDialog
{
    if ([spinnerView.superview viewWithTag:TAG_SPINNER]) {
        [spinnerView removeFromSuperview];
    }
}

/*
 * Default tag for UIAlertView is 0
 */
- (UIAlertView *)offlineAlertViewWithDelegate:(nullable id)delegate tag:(NSInteger)tag;
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"connection_error_title"]
                                                        message:[Utilities stringResourceForId:@"connection_error_msg"]
                                                       delegate:delegate
                                              cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                              otherButtonTitles:nil];
    [alertView setTag:tag];
    
    return alertView;
}
#pragma mark - CustomAlertView Delegate Method
- (void) OkAction{
    NSLog(@"DO your wish");
    //Appstore Link
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities appstoreLink]]]];
}


@end
