//
//  HelpViewController.m
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "HelpViewController.h"
//#import "LogoBarButtonItem.h"
#import "PrivacyViewController.h"
#import "TermsViewController.h"

@interface HelpViewController ()

@end

NSString *const CONTACT_TITLE = @"Contact";

@implementation HelpViewController
{
    //LogoBarButtonItem *logoBarButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:CONTACT_TITLE];
        [self setTitle:CONTACT_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
    
    UIGestureRecognizer *twitterGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(goTwitter)];
    [self.twitterImage addGestureRecognizer:twitterGesture];
    
    UIGestureRecognizer *facebookGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(goFacebook)];
    [self.facebookImage addGestureRecognizer:facebookGesture];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kLoginScreenNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen:) name:@"kLoginScreenNavNotification" object:nil];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //iOS6 Support
    [self.visitTheWebsiteProperty setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    [self.callNumberProperty setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    [self.commentsProperty setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    //iOS6 Support
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSideMenu:)];
    menuButton.tintColor = UIColor.whiteColor;
    [self.navigationItem setLeftBarButtonItem:menuButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View controls
- (IBAction)visitWebsite:(id)sender {
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cota.com"]];
    }else if ([tenantId isEqualToString:@"CDTA"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cdta.org"]];
    }else if ([tenantId isEqualToString:@"BCT"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.broward.org/BCT/Pages/default.aspx"]];
    }
}

- (IBAction)callNumber:(id)sender {
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Call COTA?"
                                                            message:@"Call 614-228-1776"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        
        [alertView show];
    }else if ([tenantId isEqualToString:@"CDTA"]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Call CDTA?"
                                                            message:@"Call (518) 482-8822"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        
        [alertView show];
    }else if ([tenantId isEqualToString:@"BCT"]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Call BCT?"
                                                            message:@"Call (954) 357-8400"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        
        [alertView show];
    }
}
- (IBAction)sendEmail:(id)sender {
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        NSString *emailString = @"mailto:Requests@cota.com";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
    }else if ([tenantId isEqualToString:@"CDTA"]){
        NSString *emailString = @"mailto:mobilesupport@cdta.org";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
    }else if ([tenantId isEqualToString:@"BCT"]){
        NSString *emailString = @"mailto:cservice@broward.org";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
    }
}
- (void)goTwitter{
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        // check whether twitter is (likely to be) installed or not
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]] ){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/cotabus/"]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/cotabus/"]];
        }
    }else if ([tenantId isEqualToString:@"CDTA"]){
        // check whether twitter is (likely to be) installed or not
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]] ){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=cdta"]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/cdta"]];
        }
    }else{}
}
- (void)goFacebook{
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        // check whether facebook is (likely to be) installed or not
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
            // Safe to launch the facebook app
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/cotabus"]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/cotabus"]];
        }
    }else if ([tenantId isEqualToString:@"CDTA"]){
        // check whether facebook is (likely to be) installed or not
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
            // Safe to launch the facebook app
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/173703599066"]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/RideCDTA/"]];
        }
    }else{}
}

- (IBAction)goTos:(id)sender {
    if ([[Utilities tenantId].lowercaseString isEqualToString:@"bct"] || [[Utilities tenantId].lowercaseString isEqualToString:@"bvta"]){
        return;
    }
    NSString * nibName = [Utilities TermsViewController];
    TermsViewController *termsViewController = [[TermsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
    [termsViewController setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:termsViewController animated:NO];
}

- (IBAction)goPrivacy:(id)sender {
    if ([[Utilities tenantId].lowercaseString isEqualToString:@"bct"] || [[Utilities tenantId].lowercaseString isEqualToString:@"bvta"]){
        return;
    }
    NSString * nibName = [Utilities PrivacyViewController];
    PrivacyViewController *privacyViewController = [[PrivacyViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
    [privacyViewController setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:privacyViewController animated:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:6142281776"]];
    }
}

@end

