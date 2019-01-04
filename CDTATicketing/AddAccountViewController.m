//
//  AddAccountViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 9/20/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "AddAccountViewController.h"
#import "LoginService.h"
#import "RegisterAccountService.h"
#import "CreateUser.h"
#import "Utilities.h"
#import "ForgotLoginViewController.h"
#import "CustomButtonClass.h"
#import "NSString+FontAwesome.h"
#import "CDTATicketsViewController.h"
#import "GetAppUpdateService.h"
#import "Singleton.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)



@interface AddAccountViewController  ()

@property (nonatomic) CAPSPageMenu *pageMenu;


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


@end

@implementation AddAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Existing Customer"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.confirmPassword setHidden:YES];
    [self.firstName setHidden:YES];
    [self.lastName setHidden:YES];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Add Account" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(goToForgotPassword:)];
    [self.forgotPassword addGestureRecognizer:tapGesture];
    
    [self applyUIChanges];
    [self setUpPageMenu];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    //    if(account){
    //        [self showProgressDialog];
    //        AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self username:account.emailaddress password:account.password];
    //        [tokenService execute];
    //    }else{
    //        [self showProgressDialog];
    //        GetOAuthService * getOAuthService = [[GetOAuthService alloc] initWithListener:self];
    //        [getOAuthService execute];
    //    }
    
    NSMutableArray *cards = [[NSMutableArray alloc] initWithArray:[Utilities getCards:self.managedObjectContext]];
    if(cards.count > 0){
        CDTATicketsViewController *ticketsView = [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
        [ticketsView setManagedObjectContext:self.managedObjectContext];
        
        [self.navigationController pushViewController:ticketsView animated:NO];
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
 }



-(void)backHandler
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUpPageMenu
{
    SignInViewController *signInViewController = [[SignInViewController alloc]initWithNibName:@"SignInViewController" bundle:[NSBundle mainBundle]];
    signInViewController.title = @"Existing Customer";
    signInViewController.cdtaController = self;
    
    SignUpViewController *signUpViewController = [[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:[NSBundle mainBundle]];
    signUpViewController.title = @"New Customer";
    signUpViewController.cdtaController = self;
    
    
    [signInViewController setManagedObjectContext:self.managedObjectContext];
    [signUpViewController setManagedObjectContext:self.managedObjectContext];
    
    _pageMenu.delegate = self;
    
    NSArray *controllerArray = @[signInViewController, signUpViewController];
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pageMenuColor]]],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pageMenuColor]]],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pageMenuColor]]],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"Montserrat" size:15.0],
                                 CAPSPageMenuOptionMenuHeight: @(70.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(SCREEN_WIDTH/2),
                                 CAPSPageMenuOptionCenterMenuItems: @(NO)
                                 };
    
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    _pageMenu.delegate = self;
    [self.view addSubview:_pageMenu.view];
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    if(index == 0)
        [self setTitle:@"Existing Customer"];
    else
        [self setTitle:@"New Customer"];
}

-(void)applyUIChanges
{
    [self.btnFirstName setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] andFontsize:30.0 andTitle:FAUser];
    [self.btnLastName setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] andFontsize:30.0 andTitle:FAUser];
    [self.btnEmail setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] andFontsize:30.0 andTitle:FAEnvelopeO];
    [self.btnPassword setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] andFontsize:30.0 andTitle:FAKey];
    [self.btnConfirmPassword setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] andFontsize:30.0 andTitle:FAKey];
    
    [self.btnUser setTitleColor:[UIColor colorWithRed:15.0/255.0 green:43.0/255.0 blue:91.0/255.0 alpha:1] andFontsize:30.0 andTitle:FAUserMd];
    
    
    self.viEmail.layer.cornerRadius = 8.0;
    self.viEmail.layer.borderWidth = 1.0;
    self.viEmail.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viEmail.layer.masksToBounds = YES;
    
    self.viFirstName.layer.cornerRadius = 8.0;
    self.viFirstName.layer.masksToBounds = YES;
    self.viFirstName.layer.borderWidth = 1.0;
    self.viFirstName.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.viLastName.layer.cornerRadius = 8.0;
    self.viLastName.layer.masksToBounds = YES;
    self.viLastName.layer.borderWidth = 1.0;
    self.viLastName.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.viPassword.layer.cornerRadius = 8.0;
    self.viPassword.layer.masksToBounds = YES;
    self.viPassword.layer.borderWidth = 1.0;
    self.viPassword.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.viConfirmPassword.layer.cornerRadius = 8.0;
    self.viConfirmPassword.layer.masksToBounds = YES;
    self.viConfirmPassword.layer.borderWidth = 1.0;
    self.viConfirmPassword.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
}



- (void)goToForgotPassword:(id)sender
{
    ForgotLoginViewController *forgotloginView = [[ForgotLoginViewController alloc] initWithNibName:@"ForgotLoginViewController" bundle:nil];
    
    [self.navigationController pushViewController:forgotloginView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View controls

- (IBAction)existingOrCreate:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.confirmPassword setHidden:YES];
        [self.firstName setHidden:YES];
        [self.lastName setHidden:YES];
        
        [self.actionButton setTitle:[Utilities stringResourceForId:@"add_account"] forState:UIControlStateNormal];
        [self.forgotPassword setHidden:NO];
    } else {
        [self.confirmPassword setHidden:NO];
        [self.firstName setHidden:NO];
        [self.lastName setHidden:NO];
        
        [self.actionButton setTitle:[Utilities stringResourceForId:@"register"] forState:UIControlStateNormal];
        [self.forgotPassword setHidden:YES];
    }
}

- (IBAction)addAccount:(id)sender {
    NSString *email = self.emailAddress.text;
    NSString *password = self.password.text;
    
    if (([email length] > 0) && ([password length] > 0)) {
        [self.view endEditing:YES];
        
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            [self showProgressDialog];
            
            LoginService *loginService = [[LoginService alloc] initWithListener:self username:email password:password managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
            
            [loginService execute];
        } else {
            NSString *confirmPassword = self.confirmPassword.text;
            NSString *firstName = self.firstName.text;
            NSString *lastName = self.lastName.text;
            
            if (([email length] > 0) && ([confirmPassword length] > 0) && ([firstName length] > 0) && ([lastName length] > 0)) {
                if ([confirmPassword isEqualToString:password]) {
                    [self showProgressDialog];
                    /*
                     RegisterAccountService *registerService = [[RegisterAccountService alloc] initWithListener:self
                     username:email
                     password:password
                     firstName:self.firstName.text
                     lastName:self.lastName.text managedObjectContext:self.managedObjectContext];
                     [registerService execute];
                     */
                    
                    RegisterAccountService *registerService = [[RegisterAccountService alloc] initWithListener:self
                                                                                                      username:email
                                                                                                      password:password
                                                                                                     firstName:self.firstName.text
                                                                                                      lastName:self.lastName.text managedObjectContext:self.managedObjectContext];
                    [registerService execute];
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
    }
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[LoginService class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([service isMemberOfClass:[RegisterAccountService class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:[[Utilities tenantId] uppercaseString]]
                                                            message:[Utilities stringResourceForId:@"registration_success_msg"]
                                                           delegate:nil
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
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
