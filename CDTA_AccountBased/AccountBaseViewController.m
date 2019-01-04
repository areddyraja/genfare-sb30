//
//  AccountBaseViewController.m
//  CDTATicketing Beta
//
//  Created by Gaian Solutions on 4/27/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "AccountBaseViewController.h"
#import "CheckWalletService.h"
#import "Account.h"
#import "CooCooAccountUtilities1.h"
#import "NSBundle+BaseResourcesBundle.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "GetAppUpdateService.h"
#import "Singleton.h"
#import "iRide-Swift.h"

//float const STATUS_BAR_HEIGHT1 = 20;
//float const NAVIGATION_BAR_HEIGHT1 = 44;
float const HELP_SLIDER_PADDING1 = 1;
float const TOUCH_PADDING1 = 60;


@interface AccountBaseViewController ()

@end

@implementation AccountBaseViewController{
    UIView *spinnerView;
    CGFloat helpSliderOrigin;
    BOOL isTouchingTopBar;
    CGFloat maxBarPointY;
    BOOL firstLoad;
    CGFloat originalHeight;
    float deviceStatusBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    deviceStatusBar = [Utilities statusBarHeight];
    
    // Set the background for all screens that extend BaseViewController
    [self.view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities mainBgColor]]]];
    
//    CGRect applicationRect = [[UIScreen mainScreen] bounds];
//    
////    helpSliderOrigin = applicationRect.size.height + deviceStatusBar - HELP_SLIDER_HEIGHT;
//    helpSliderOrigin = applicationRect.size.height - HELP_SLIDER_HEIGHT;
//
//    
//    self.helpSlider = [[HelpSliderView alloc] initWithFrame:CGRectMake(0,
//                                                                       helpSliderOrigin,
//                                                                       applicationRect.size.width,
//                                                                       applicationRect.size.height - NAVIGATION_BAR_HEIGHT)
//                                                    isLight:[Utilities isLightTheme]];
//    
//    [self.helpSlider initializeWithBarColor:[UIColor whiteColor]];
//    NSLog(@"helpSlider.frame = %@",NSStringFromCGRect(self.helpSlider.frame));
//    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doubleTapAction:)];
//    [doubleTap setNumberOfTapsRequired:2];
//    [doubleTap setDelegate:self];
//    
//    [self.helpSlider addGestureRecognizer:doubleTap];
//    
//    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
//    [mainWindow addSubview:self.helpSlider];
    
    
    // Do any additional setup after loading the view.
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
    
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // [self.helpSlider removeFromSuperview];
}
- (void)doubleTapAction:(UITapGestureRecognizer *)sender
{
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
                                                     self->helpSliderOrigin,
                                                     self.helpSlider.frame.size.width,
                                                     self.helpSlider.frame.size.height)];
            }];
            
            [self.helpSlider onCollapse];
        }
    }
}

#pragma mark - Side Menu Functionality

- (IBAction)showSideMenu:(UIButton *)sender {
    NSLog(@"Show Side Menu %@",[StoredData userData].email);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Sidemenu" bundle:nil];
    UISideMenuNavigationController *controller = [sb instantiateInitialViewController];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)sideMenuWillAppearWithMenu:(UISideMenuNavigationController *)menu animated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUISideMenuIsVisible" object:nil];
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
        //        if ([[Singleton sharedManager] isInternetAlertPresented] == YES) {
        //            [[Singleton sharedManager] setIsInternetAlertPresented:NO];
        //        }else{
        //
        //            [[Singleton sharedManager] showAlertForInternet:[Utilities stringResourceForId:@"connection_error_title"] message:[Utilities stringResourceForId:@"connection_error_msg"]];
        //            [[Singleton sharedManager] setIsInternetAlertPresented:YES];
        //        }
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

-(void)viewWillAppear:(BOOL)animated
{
 
     Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        [self showProgressDialog];
        CheckWalletService *walletService = [[CheckWalletService alloc] initWithListener:self emailid:account.emailaddress managedContext:self.managedObjectContext];
        [walletService execute];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - CustomAlertView Delegate Method
- (void) OkAction{
    NSLog(@"DO your wish");
    //Appstore Link
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities appstoreLink]]]];
    //    if ([[[Utilities apiEnvironment] lowercaseString] containsString:@"st"]) {
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities stagingLink]]]];
    //    }else if ([[[Utilities apiEnvironment] lowercaseString] containsString:@"ua"]){
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities uatLink]]]];
    //    }else{
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities appstoreLink]]]];
    //    }
    
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
- (void)threadSuccessWithClass:(id)service  response:(id)response
{
    [self dismissProgressDialog];
    if([service isMemberOfClass:[GetAppUpdateService class]]){
        [self getAppUpdateSupportingMethod:response];
    }
    else if ([service isMemberOfClass:[CheckWalletService class]]) {
    }
}
- (void)threadErrorWithClass:(id)service  response:(id)response
{
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[GetAppUpdateService class]]) {
    }
    else if ([service isMemberOfClass:[CheckWalletService class]]) {
    }
}

@end
