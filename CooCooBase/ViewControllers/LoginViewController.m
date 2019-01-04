//
//  LoginViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "LoginViewController.h"
#import "AccountSettingsViewController.h"
#import "Reachability.h"
#import "StoredData.h"
#import "Utilities.h"
#import "UIColor+HexString.h"

@interface LoginViewController ()

@end

int const NEW_FIELDS_OFFSET = 150;
int const TEXTFIELD_TAG_USERNAME = 1;
int const TEXTFIELD_TAG_PASSWORD = 2;
int const TEXTFIELD_TAG_CONFIRM_PASSWORD = 3;
int const TEXTFIELD_TAG_FIRST_NAME = 4;
int const TEXTFIELD_TAG_LAST_NAME = 5;

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"login"]];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    NSLog(@"Initial setup");
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Login" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    CGFloat applicationWidth = [[UIScreen mainScreen] bounds].size.width;
    
    [self.loginSegment setFrame:CGRectMake(self.loginSegment.frame.origin.x, self.loginSegment.frame.origin.y,
                                           applicationWidth - (self.loginSegment.frame.origin.x * 2), self.loginSegment.frame.size.height)];
    
    [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y,
                                         applicationWidth, self.scrollView.frame.size.height)];
    
    [self.usernameText setFrame:CGRectMake(self.usernameText.frame.origin.x, self.usernameText.frame.origin.y,
                                           applicationWidth - (self.usernameText.frame.origin.x * 2), self.usernameText.frame.size.height)];
    [self.usernameText setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.usernameText setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    [self.passwordText setFrame:CGRectMake(self.passwordText.frame.origin.x, self.passwordText.frame.origin.y,
                                           applicationWidth - (self.passwordText.frame.origin.x * 2), self.passwordText.frame.size.height)];
    
    [self.confirmPasswordText setFrame:CGRectMake(self.confirmPasswordText.frame.origin.x, self.confirmPasswordText.frame.origin.y,
                                                  applicationWidth - (self.confirmPasswordText.frame.origin.x * 2), self.confirmPasswordText.frame.size.height)];
    
    [self.firstNameText setFrame:CGRectMake(self.firstNameText.frame.origin.x, self.firstNameText.frame.origin.y,
                                            applicationWidth - (self.firstNameText.frame.origin.x * 2), self.firstNameText.frame.size.height)];
    
    [self.lastNameText setFrame:CGRectMake(self.lastNameText.frame.origin.x, self.lastNameText.frame.origin.y,
                                           applicationWidth - (self.lastNameText.frame.origin.x * 2), self.lastNameText.frame.size.height)];
    
    [self.loginButton setFrame:CGRectMake(self.loginButton.frame.origin.x, self.loginButton.frame.origin.y,
                                          applicationWidth - (self.loginButton.frame.origin.x * 2), self.loginButton.frame.size.height)];
    
    [self.forgotPasswordLabel setFrame:CGRectMake(self.forgotPasswordLabel.frame.origin.x, self.forgotPasswordLabel.frame.origin.y,
                                                  applicationWidth - (self.forgotPasswordLabel.frame.origin.x * 2), self.forgotPasswordLabel.frame.size.height)];
    
    [self.forgotPasswordLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities highLightColor]]]];
    
    [self.confirmPasswordText setHidden:YES];
    [self.firstNameText setHidden:YES];
    [self.lastNameText setHidden:YES];
    
    [self resizeFields:-NEW_FIELDS_OFFSET];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                               self.forgotPasswordLabel.frame.origin.y + self.forgotPasswordLabel.frame.size.height)];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(goToForgotPassword:)];
    [self.forgotPasswordLabel addGestureRecognizer:tapGesture];
    
    [self.usernameText setTag:TEXTFIELD_TAG_USERNAME];
    [self.passwordText setTag:TEXTFIELD_TAG_PASSWORD];
    [self.confirmPasswordText setTag:TEXTFIELD_TAG_CONFIRM_PASSWORD];
    [self.firstNameText setTag:TEXTFIELD_TAG_FIRST_NAME];
    [self.lastNameText setTag:TEXTFIELD_TAG_LAST_NAME];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setLoginSegment:nil];
    [self setUsernameText:nil];
    [self setPasswordText:nil];
    [self setConfirmPasswordText:nil];
    [self setFirstNameText:nil];
    [self setLastNameText:nil];
    [self setLoginButton:nil];
    [self setForgotPasswordLabel:nil];
    [super viewDidUnload];
}

#pragma mark - View controls
/*
 - (BOOL)textFieldShouldReturn:(UITextField *)textField
 {
 [textField resignFirstResponder];
 
 return YES;
 }
 */
- (IBAction)loginOrRegister:(id)sender
{
    if (self.loginSegment.selectedSegmentIndex == 0) {
        [self setTitle:[Utilities stringResourceForId:@"login"]];
        
        [self.confirmPasswordText setHidden:YES];
        [self.firstNameText setHidden:YES];
        [self.lastNameText setHidden:YES];
        [self.forgotPasswordLabel setHidden:NO];
        
        [self.loginButton setTitle:[Utilities stringResourceForId:@"login"] forState:UIControlStateNormal];
        
        [self resizeFields:-NEW_FIELDS_OFFSET];
    } else {
        [self setTitle:[Utilities stringResourceForId:@"register"]];
        
        [self.confirmPasswordText setHidden:NO];
        [self.firstNameText setHidden:NO];
        [self.lastNameText setHidden:NO];
        [self.forgotPasswordLabel setHidden:YES];
        
        [self.loginButton setTitle:[Utilities stringResourceForId:@"register"] forState:UIControlStateNormal];
        
        [self resizeFields:NEW_FIELDS_OFFSET];
    }
}

- (IBAction)login:(id)sender
{
    NSLog(@"Login");
    NSString *email = self.usernameText.text;
    NSString *password = self.passwordText.text;
    
    if ([email length] > 0 && [password length] > 0) {
        [self.view endEditing:YES];
        
        if ([self.loginButton.titleLabel.text isEqualToString:[Utilities stringResourceForId:@"login"]]) {
            [self showProgressDialog];
            
            LoginService *loginService = [[LoginService alloc] initWithListener:self username:email password:password managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
            
            [loginService execute];
        } else {
            NSString *confirmPassword = self.confirmPasswordText.text;
            
            if ([confirmPassword isEqualToString:password]) {
                [self showProgressDialog];
                
                RegisterAccountService *registerService = [[RegisterAccountService alloc]
                                                           initWithListener:self
                                                           username:email
                                                           password:password
                                                           firstName:self.firstNameText.text
                                                           lastName:self.lastNameText.text managedObjectContext:self.managedObjectContext];
                [registerService execute];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                                    message:[Utilities stringResourceForId:@"password_error_msg"]
                                                                   delegate:nil
                                                          cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
}

- (void)goToForgotPassword:(id)sender
{
    ForgotLoginViewController *forgotloginView = [[ForgotLoginViewController alloc] initWithNibName:@"ForgotLoginViewController" bundle:nil];
    [forgotloginView setDefaultEmail:self.usernameText.text];
    
    [self.navigationController pushViewController:forgotloginView animated:YES];
}

- (void)resizeFields:(int)offset
{
    [self.loginButton setFrame:CGRectMake(self.loginButton.frame.origin.x,
                                          self.loginButton.frame.origin.y + offset,
                                          self.loginButton.frame.size.width,
                                          self.loginButton.frame.size.height)];
    
    [self.forgotPasswordLabel setFrame:CGRectMake(self.forgotPasswordLabel.frame.origin.x,
                                                  self.forgotPasswordLabel.frame.origin.y + offset,
                                                  self.forgotPasswordLabel.frame.size.width,
                                                  self.forgotPasswordLabel.frame.size.height)];
    
    NSUInteger lastViewIndex = self.scrollView.subviews.count;
    UIView *lastView = [self.scrollView.subviews objectAtIndex:lastViewIndex - 1];
    CGFloat lastViewOffsetY = lastView.frame.origin.y + lastView.frame.size.height;
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, lastViewOffsetY)];
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service
{
    if ([service isMemberOfClass:[LoginService class]]) {
        [self threadSuccessWithLogin:self];
    } else if ([service isMemberOfClass:[RegisterAccountService class]]) {
        [self threadSuccessWithRegistration:self];
    }
    
    [self dismissProgressDialog];
}

/**
 * Displays the next appropriate screen after a successful login.
 *
 * There is a FEATURE flag to goto the Home Screen if it is enabled.
 */
- (void)threadSuccessWithLogin:(id)service
{
    //If FEATURE enabled, go to the Home Screen; otherwise go to designated location.
    if ([Utilities featuresFromId:@"FEATURE__ACCOUNT__GOTO_HOME_SCREEN_AFTER_LOGIN"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        AccountSettingsViewController *accountSettingsView =
        [[AccountSettingsViewController alloc] initWithNibName:@"AccountSettingsViewController" bundle:nil];
        
        // Replace the current view controller
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
        [viewControllers removeLastObject];
        [viewControllers addObject:accountSettingsView];
        
        [[self navigationController] setViewControllers:viewControllers animated:YES];
    }
}

/**
 * Displays the next appropriate screen after a successful registration.
 *
 * There is a FEATURE flag to goto the Home Screen if it is enabled.
 */
- (void)threadSuccessWithRegistration:(id)service
{
    //If FEATURE enabled, go to the Home Screen; otherwise go to designated location.
    if ([Utilities featuresFromId:@"FEATURE__ACCOUNT__GOTO_HOME_SCREEN_AFTER_REGISTRATION"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        AccountSettingsViewController *accountSettingsView =
        [[AccountSettingsViewController alloc] initWithNibName:@"AccountSettingsViewController" bundle:nil];
        
        // Replace the current view controller
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
        [viewControllers removeLastObject];
        [viewControllers addObject:accountSettingsView];
        
        [[self navigationController] setViewControllers:viewControllers animated:YES];
    }
}

- (void)threadErrorWithClass:(id)service
{
    [self dismissProgressDialog];
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIAlertView *alertView = [self offlineAlertViewWithDelegate:nil tag:0];
        [alertView show];
    } else {
        if ([service isMemberOfClass:[LoginService class]]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"login"]
                                                                message:[Utilities stringResourceForId:@"password_incorrect"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                      otherButtonTitles:nil];
            [alertView show];
        } else if ([service isMemberOfClass:[RegisterAccountService class]]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"registration_error_title"]
                                                                message:[Utilities stringResourceForId:@"registration_error_msg"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                      otherButtonTitles:nil];
            [alertView show];
            
        }
    }
    
    [StoredData removeUserData];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (((self.loginSegment.selectedSegmentIndex == 0)
         && (textField.tag < TEXTFIELD_TAG_PASSWORD))
        || (self.loginSegment.selectedSegmentIndex == 1)) {
        
        NSInteger nextTag = textField.tag + 1;
        // Try to find next responder
        UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
        
        if (nextResponder) {
            // Found next responder, so set it.
            [nextResponder becomeFirstResponder];
        } else {
            // Not found, so remove keyboard.
            [textField resignFirstResponder];
        }
    } else {
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

@end

