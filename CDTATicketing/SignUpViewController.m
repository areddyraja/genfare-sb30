//
//  SignUpViewController.m
//  Pods
//
//  Created by ibasemac3 on 3/17/17.
//
//

#import "SignUpViewController.h"
#import "BorderedButton.h"
#import "CustomButtonClass.h"
#import "NSString+FontAwesome.h"
#import "LoginService.h"
#import "RegisterAccountService.h"
#import "Utilities.h"
#import "ForgotLoginViewController.h"
#import "WalletInstructionsViewController.h"
#import "CheckWalletService.h"
#import "GetProductsService.h"
#import "CooCooBase.h"
#import "GetConfigApi.h"
#import "SMSVerficationViewController.h"
#import "GetOAuthService.h"
#import "GetAppUpdateService.h"
#import "Singleton.h"

@interface SignUpViewController () <UITextFieldDelegate>
#pragma mark - Variables Declarations
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *emailAddress;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *password;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *confirmPassword;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *firstName;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UIScrollView *signupScrollView;

@property (unsafe_unretained, nonatomic) IBOutlet BorderedButton *actionButton;

@property (weak, nonatomic) IBOutlet UIView *viFirstName;
@property (weak, nonatomic) IBOutlet UIView *viLastName;
@property (weak, nonatomic) IBOutlet UIView *viEmail;
@property (weak, nonatomic) IBOutlet UIView *viPassword;
@property (weak, nonatomic) IBOutlet UIView *viConfirmPassword;

@property (weak, nonatomic) IBOutlet CustomButtonClass *btnFirstName;
@property (weak, nonatomic) IBOutlet CustomButtonClass *btnLastName;
@property (weak, nonatomic) IBOutlet CustomButtonClass *btnEmail;
@property (weak, nonatomic) IBOutlet CustomButtonClass *btnPassword;
@property (weak, nonatomic) IBOutlet CustomButtonClass *btnConfirmPassword;
@property (weak, nonatomic) IBOutlet CustomButtonClass *btnUser;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnSignUp;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@end

@implementation SignUpViewController

#pragma mark - View lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    doSignUp = NO;
    [self initialiseMethods];
    self.emailAddress.delegate = self;
    self.firstName.delegate = self;
    self.lastName.delegate = self;
    self.password.delegate = self;
    self.confirmPassword.delegate = self;
    // Do any additional setup after loading the view from its nib.
    self.imgUser.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@LogoBig",[[Utilities tenantId] lowercaseString]]];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.cdtaController = self;
    [self applyStylesAndColors];
}

#pragma mark - Initial Methods
-(void)applyStylesAndColors {
    self.navigationController.navigationBarHidden = YES;
    
    if ([self.emailAddress respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@PlaceHolderTextColor",[[Utilities tenantId] lowercaseString]]]];
        self.emailAddress.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    if ([self.firstName respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@PlaceHolderTextColor",[[Utilities tenantId] lowercaseString]]]];
        self.firstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    if ([self.lastName respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@PlaceHolderTextColor",[[Utilities tenantId] lowercaseString]]]];
        self.lastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    if ([self.confirmPassword respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@PlaceHolderTextColor",[[Utilities tenantId] lowercaseString]]]];
        self.confirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    if ([self.password respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@PlaceHolderTextColor",[[Utilities tenantId] lowercaseString]]]];
        self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    self.view.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@LoginBGColor",[[Utilities tenantId] lowercaseString]]]];
    self.btnSignUp.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@BigButtonBGColor",[[Utilities tenantId] lowercaseString]]]];
    [self.btnSignIn setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@BigButtonBGColor",[[Utilities tenantId] lowercaseString]]]] forState:UIControlStateNormal];
}

-(void)initialiseMethods{
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Add Account" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action Methods
-(IBAction)signUpHandler:(id)sender{
    email = self.emailAddress.text;
    password = self.password.text;
    NSString *confirmPassword = self.confirmPassword.text;
    NSString *firstName = self.firstName.text;
    NSString *lastName = self.lastName.text;
    if (([email length] > 0) && ([confirmPassword length] > 0) && ([firstName length] > 0) && ([lastName length] > 0)) {
        if ([confirmPassword isEqualToString:password]) {
            [self showProgressDialog];
            NSString * accessToken = [Utilities commonaccessToken];
            if (accessToken) {
                RegisterAccountService *registerService = [[RegisterAccountService alloc] initWithListener:self
                                                                                                  username:email
                                                                                                  password:password
                                                                                                 firstName:self.firstName.text
                                                                                                  lastName:self.lastName.text managedObjectContext:self.managedObjectContext];
                [registerService execute];
            }else{
                doSignUp = YES;
                GetOAuthService * getOAuthService = [[GetOAuthService alloc] initWithListener:self];
                [getOAuthService execute];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                                message:[Utilities stringResourceForId:@"password_error_msg"]
                                                               delegate:nil
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"all_fields_required"]
                                                           delegate:nil
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
 #pragma mark - UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.firstName) {
        [textField resignFirstResponder];
        [self.lastName becomeFirstResponder];
        self.signupScrollView.contentOffset = CGPointMake(0.0, 0.0);
    }else if(textField == self.lastName){
        [textField resignFirstResponder];
        [self.emailAddress becomeFirstResponder];
        self.signupScrollView.contentOffset = CGPointMake(0.0, 60.0);
    }else if (textField == self.emailAddress){
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
        self.signupScrollView.contentOffset = CGPointMake(0.0, 100.0);
    }else if (textField == self.password){
        [textField resignFirstResponder];
        [self.confirmPassword becomeFirstResponder];
        self.signupScrollView.contentOffset = CGPointMake(0.0, 150.0);
    }else{
        [textField resignFirstResponder];
        self.signupScrollView.contentOffset = CGPointMake(0.0, 0.0);
    }
    return YES;
}

#pragma mark - Service Call Success method
- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
      if ([service isMemberOfClass:[GetOAuthService class]]){
        if (doSignUp == YES) {
            [self showProgressDialog];
            RegisterAccountService *registerService = [[RegisterAccountService alloc] initWithListener:self
                                                                                              username:email
                                                                                              password:password
                                                                                             firstName:self.firstName.text
                                                                                              lastName:self.lastName.text managedObjectContext:self.managedObjectContext];
            [registerService execute];
        }else{
            [self dismissProgressDialog];
        }
    } else if ([service isMemberOfClass:[RegisterAccountService class]]) {
        [self showProgressDialog];
        LoginService *login =   [[LoginService alloc] initWithListener:self username:self.emailAddress.text password:self.password.text managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
        [login execute];
    }else if ([service isMemberOfClass:[LoginService class]]) {
        UserData *userData = [StoredData userData];
        if (userData.isLoggedIn == YES){
            NSLog(@"User Already Loggedin");
            Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
            if ([account.password length]> 0) {
                [self showProgressDialog];
                AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self username:account.emailaddress password:account.password];
                [tokenService execute];
            }
        }else{
            NSLog(@"User NOT Loggedin");
        }
    }else if ([service isMemberOfClass:[AuthorizeTokenService class]]) {
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        if(account.needs_additional_auth==true){
            SMSVerficationViewController *smsVC=[[SMSVerficationViewController alloc] initWithNibName:@"SMSVerficationViewController" bundle:[NSBundle mainBundle]];
            smsVC.managedObjectContext=self.managedObjectContext;
            [self.cdtaController.navigationController pushViewController:smsVC animated:true];
        }else{
            Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
            if(account){
                [self showProgressDialog];
                CheckWalletService *isWalletExist  = [[CheckWalletService alloc] initWithListener:self emailid:account.emailaddress managedContext:self.managedObjectContext];
                [isWalletExist execute];
            }
            GetConfigApi *contents = [[GetConfigApi alloc]initWithListener:self];
            [contents execute];
        }
    }
    else if ([service isMemberOfClass:[CheckWalletService class]]){
        [self showProgressDialog];
        GetProductsService *productsService = [[GetProductsService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
        [productsService execute];
    }else  if ([service isMemberOfClass:[GetProductsService class]]){
        NSString * nibName = [Utilities walletInstructionsViewController];
        WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
        [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
        [self.navigationController pushViewController:walletInstructionsViewController animated:NO];
    }else if ([service isMemberOfClass:[GetConfigApi class]]){
        [self dismissProgressDialog];
    }
}
#pragma mark - Service Call Error method
- (void)threadErrorWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[LoginService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"login_error_title"]
                                                            message:[Utilities stringResourceForId:@"login_error_msg"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    } else if ([service isMemberOfClass:[RegisterAccountService class]]) {
        NSDictionary *json = (NSDictionary *)response;
        NSString *message = [json valueForKey:@"message"];
        if ([message length] > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"registration_error_title"]
                                                                message:[message stringByTrimmingCharactersInSet:
                                                                         [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                               delegate:self
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                      otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:[Utilities stringResourceForId:@"registration_error_title"]
                                      message:[Utilities stringResourceForId:@"registration_error_msg"]
                                      delegate:self
                                      cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}
@end
