//
//  BaseSettingsViewController.m
//  Pods
//
//  Created by CooCooTech on 7/23/15.
//
//

#import "BaseSettingsViewController.h"
#import "AppConstants.h"
#import "LoginService.h"
#import "NSBundle+BaseResourcesBundle.h"
#import "StoredData.h"
#import "Utilities.h"

@interface BaseSettingsViewController ()

@end

@implementation BaseSettingsViewController
{
    UIView *spinnerView;
    CGFloat helpSliderOrigin;
    BOOL isTouchingTopBar;
    CGFloat maxBarPointY;
    BOOL firstLoad;
    CGFloat originalHeight;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [self setShowCreditsFooter:NO];
        [self setShowDoneButton:NO];
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            maxBarPointY = NAVIGATION_BAR_HEIGHT + HELP_SLIDER_HEIGHT + TOUCH_PADDING;
        } else {
            maxBarPointY = NAVIGATION_BAR_HEIGHT + HELP_SLIDER_HEIGHT;
        }
    }
    
    firstLoad = YES;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setDelegate:self];
    
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
    
    /*if ([Utilities featuresFromId:@"check_for_external_password_change"]) {
     [self checkIfPasswordIsStillValid];
     }*/
}

/*- (void)checkIfPasswordIsStillValid
 {
 UserData *userData = [StoredData userData];
 if (userData.isLoggedIn){
 LoginService *loginService = [[LoginService alloc] initWithListener:self
 username:userData.email
 password:userData.password];
 [loginService execute];
 }
 }*/

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.helpSlider removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self setDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender
{
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - View controls

- (void)doubleTapAction:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (!self.helpSlider.isExpanded) {
            [UIView animateWithDuration:0.7f animations:^{
                [self.helpSlider setTransform:CGAffineTransformIdentity];
                [self.helpSlider setFrame:CGRectMake(0,
                                                     STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT + HELP_SLIDER_PADDING,
                                                     self.helpSlider.frame.size.width,
                                                     self.helpSlider.frame.size.height)];
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

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[LoginService class]]) {
        NSLog(@"Password is still valid");
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[LoginService class]]) {
        NSLog(@"Password is outdated");
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
