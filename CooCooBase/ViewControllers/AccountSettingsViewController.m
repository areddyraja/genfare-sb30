//
//  AccountSettingsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "ChangeEmailViewController.h"
#import "ChangePasswordViewController.h"
#import "StoredData.h"
#import "Utilities.h"
#import "WebViewController.h"
#import "RegistrationManagementViewController.h"
#import "LoginService.h"
#import "CooCooAccountUtilities1.h"
#import "Account.h"
#import "UIColor+HexString.h"
#import "HelpViewController.h"
#import "GFSaveAddressViewController.h"

@interface AccountSettingsViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *homeAddressFld;
@property (weak, nonatomic) IBOutlet UITextField *schoolAddressFld;
@property (weak, nonatomic) IBOutlet UITextField *workAddressFld;

@property (nonatomic) NSString *currentAddress;

@end

@implementation AccountSettingsViewController
{
    UserData *userData;
}

const int PROMPT_TAG__SAVED_PAYMENTS_PASSWORD = 1;
const int PROMPT_TAG__CONFIRM_LOGOUT = 2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"account_settings"]];
        
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"logout"]
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self
                                                                        action:@selector(logout)];
        [self.navigationItem setRightBarButtonItem:logoutButton];
        
        userData = [StoredData userData];
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            [self setEdgesForExtendedLayout:UIRectEdgeNone];
        }
    }

    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSLog(@"AccountSettingsViewController");
    
    //If stored value FEATURE enabled, show it.
    [_storedValueButtonProperties setHidden:![Utilities featuresFromId:@"stored_value"]];
    
    //If saved payment token management FEATURE enabled, show it.
    self.savedPaymentsProperties.hidden = ![Utilities featuresFromId:@"show_manage_saved_payment"];
    
    //If device management FEATURE enabled, show it.
    [_viewDeviceRegistrationStatusProperties setHidden:![Utilities featuresFromId:@"FEATURE__ACCOUNT__SETTINGS__SHOW_DEVICE_MANAGMENT"]];
    
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];

    
    // Change title of back button on next screen
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"account"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    [self.verifiedLabel setText:(account.emailverified
                                 ? [Utilities stringResourceForId:@"email_verified"]
                                 : [Utilities stringResourceForId:@"email_pending"])];
    
    
    [self.emailLabel setText:[NSString stringWithFormat:@" %@", account.emailaddress]];


    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSideMenu:)];
    menuButton.tintColor = UIColor.whiteColor;
    [self.navigationItem setLeftBarButtonItem:menuButton];

    self.homeAddressFld.delegate = self;
    self.workAddressFld.delegate = self;
    self.schoolAddressFld.delegate = self;
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Account Settings" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    userData = [StoredData userData];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
/*SAAS
    AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self
                                                                                 username:account.emailaddress
                                                                                authToken:account.authToken];
    [tokenService execute];
    */

    self.view.backgroundColor = [UIColor colorWithHexString:@"#223668"];
    [self loadSavedAddresses];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Account Settings" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

#pragma mark - UITextField delegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.homeAddressFld) {
        [self showAddressEditorFor:KEY_SAVED_ADDRESS_HOME];
    }else if(textField == self.workAddressFld){
        [self showAddressEditorFor:KEY_SAVED_ADDRESS_WORK];
    }else if(textField == self.schoolAddressFld) {
        [self showAddressEditorFor:KEY_SAVED_ADDRESS_SCHOOL];
    }
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.homeAddressFld) {
        self.currentAddress = KEY_SAVED_ADDRESS_HOME;
    }else if(textField == self.workAddressFld){
        self.currentAddress = KEY_SAVED_ADDRESS_WORK;
    }else if(textField == self.schoolAddressFld) {
        self.currentAddress = KEY_SAVED_ADDRESS_SCHOOL;
    }
    
    [self showAddressClearAlert];

    return NO;
}

-(void)showAddressEditorFor:(NSString *)key {
    GFSaveAddressViewController *editor = [[GFSaveAddressViewController alloc] initWithNibName:@"GFSaveAddressViewController" bundle:nil];
    editor.addressFor = key;
    editor.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:editor animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setVerifiedLabel:nil];
    [self setEmailLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service  response:(id)response
{
    if ([service isMemberOfClass:[AuthorizeTokenService class]]) {
        userData = [StoredData userData];
        [self.verifiedLabel setText:(userData.isEmailVerified
                                     ? [Utilities stringResourceForId:@"email_verified"]
                                     : [Utilities stringResourceForId:@"email_pending"])];
        [self.emailLabel setText:[NSString stringWithFormat:@" %@", userData.email]];
    }/* else if ([service isMemberOfClass:[LoginService class]]) {
        UserData *myUserData = [StoredData userData];
        if (myUserData.loggedIn) {
            SavedPaymentsViewController *savedPaymentsViewController = [[SavedPaymentsViewController alloc] initWithNibName:@"SavedPaymentsViewController"
                                                                                                                     bundle:nil];
            
            [self.navigationController pushViewController:savedPaymentsViewController animated:YES];
        }
    }*/
    
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service  response:(id)response
{
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[AuthorizeTokenService class]]) {
        //[self logout];
    }/* else if ([service isMemberOfClass:[LoginService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"saved_payments"]
                                                            message:[Utilities stringResourceForId:@"password_incorrect"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }*/
}

#pragma mark - View controls

/**
  * Prompts the customer to confirm logging out of the account.
  *
  * @see AlertView.clickedButtonAtIndex for handler
  */
- (void)logout
{
    UIAlertView *confirmLogout = [[UIAlertView alloc] initWithTitle: [Utilities stringResourceForId:@"logout"]
                                                            message: [Utilities stringResourceForId:@"LOGOUT__CONFIRM_MSG"]
                                                           delegate: self
                                                  cancelButtonTitle: [Utilities stringResourceForId:@"no"]
                                                  otherButtonTitles: [Utilities stringResourceForId:@"yes"], nil];
    //Tag alert view for multi-view response handler.
    [confirmLogout setTag:PROMPT_TAG__CONFIRM_LOGOUT];
    [confirmLogout show];
}

- (IBAction)goToWallet:(id)sender
{
    /*UIAlertView *passwordPrompt = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"saved_payments"]
                                                             message:@""
                                                            delegate:self
                                                   cancelButtonTitle:[Utilities stringResourceForId:@"cancel"]
                                                   otherButtonTitles:[Utilities stringResourceForId:@"ok"] , nil];
    
    passwordPrompt.alertViewStyle = UIAlertViewStyleSecureTextInput;
    UITextField *passwordTextField;
    passwordTextField = [passwordPrompt textFieldAtIndex:0];
    passwordTextField.placeholder = [Utilities stringResourceForId:@"password"];
    [passwordPrompt setTag:PROMPT_TAG__SAVED_PAYMENTS_PASSWORD];
    [passwordPrompt show];*/
}

- (IBAction)changeEmail:(id)sender
{
    ChangeEmailViewController *emailView = [[ChangeEmailViewController alloc] initWithNibName:@"ChangeEmailViewController" bundle:nil];
    emailView.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:emailView animated:YES];
}

- (IBAction)changePassword:(id)sender
{
    ChangePasswordViewController *passwordView = [[ChangePasswordViewController alloc]
                                                  initWithNibName:@"ChangePasswordViewController"
                                                  bundle:nil];
    passwordView.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:passwordView animated:YES];
}

- (IBAction)showContacts:(UIButton *)sender {
    NSString * nibName = [Utilities HelpViewController];
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
    [helpViewController setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:helpViewController animated:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Handle password prompt response
    /*if (alertView.tag == PROMPT_TAG__SAVED_PAYMENTS_PASSWORD && buttonIndex == 1) {
        
        if ([alertView textFieldAtIndex:0].text.length > 0)
        {
            userData = [StoredData userData];
            LoginService *loginService = [[LoginService alloc] initWithListener:self
                                                                       username:userData.email
                                                                       password:[alertView textFieldAtIndex:0].text];
            
            [loginService execute];
            [self showProgressDialog];
            
        } else {
            UIAlertView *failed = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"saved_payments"]
                                                             message:[Utilities stringResourceForId:@"password_no_valid"]
                                                            delegate:self
                                                   cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                   otherButtonTitles:nil];
            
            [failed show];
        }
        
    }*/
    
    //Handle logout confirmation response.
    if (alertView.tag == PROMPT_TAG__CONFIRM_LOGOUT && buttonIndex == 1) {
        [StoredData removeUserData];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)viewDeviceRegistration:(id)sender
{
    RegistrationManagementViewController *registrationView = [[RegistrationManagementViewController alloc] initWithNibName:@"RegistrationManagementViewController"
                                                                                                                    bundle:nil];
    [self.navigationController pushViewController:registrationView animated:YES];
}

- (IBAction)storedValue:(id)sender
{
    
}

-(void)loadSavedAddresses {
    if ([Utilities getValueFromDefaultsForKey:KEY_SAVED_ADDRESS_HOME] != nil) {
        self.homeAddressFld.text =  [self getAddressFromString:[Utilities getValueFromDefaultsForKey:KEY_SAVED_ADDRESS_HOME]];
    }else{
        self.homeAddressFld.text = @"";
    }
    if ([Utilities getValueFromDefaultsForKey:KEY_SAVED_ADDRESS_WORK] != nil) {
        self.workAddressFld.text = [self getAddressFromString:[Utilities getValueFromDefaultsForKey:KEY_SAVED_ADDRESS_WORK]];
    }else{
        self.workAddressFld.text = @"";
    }
    if ([Utilities getValueFromDefaultsForKey:KEY_SAVED_ADDRESS_SCHOOL] != nil) {
        self.schoolAddressFld.text = [self getAddressFromString:[Utilities getValueFromDefaultsForKey:KEY_SAVED_ADDRESS_SCHOOL]];
    }else{
        self.schoolAddressFld.text = @"";
    }
}

- (NSString *)getAddressFromString:(NSString *)str {
    NSArray *items = [str componentsSeparatedByString:@"|"];
    return items.firstObject;
}

-(void)showAddressClearAlert {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Remove Address"
                                 message:@"Are you sure, You want to remove Address?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    [self clearAddress];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)clearAddress {
    [Utilities removeValueFromDefaults:self.currentAddress];
    [self loadSavedAddresses];
}

@end
