//
//  SignInViewController.m
//  Pods
//
//  Created by ibasemac3 on 3/17/17.
//
//

#import "SignInViewController.h"
#import "CustomButtonClass.h"
#import "NSString+FontAwesome.h"
#import "LoginService.h"
#import "RegisterAccountService.h"
#import "Utilities.h"
#import "ForgotLoginViewController.h"
#import "SignUpViewController.h"
#import "GetCardsForAccountService.h"
#import "ClaimCardsViewController.h"
#import "FontAwesomeButton.h"
#import "WalletInstructionsViewController.h"
#import "AppDelegate.h"
#import "CDTATicketsViewController.h"
#import "CheckWalletService.h"
#import "GetWalletContents.h"
#import "GetProductsService.h"
#import "AssignWalletApi.h"
#import "Singleton.h"
#import "CDTA_AccountBasedViewController.h"
#import "WalletListAccountBaseViewController.h"
#import "GetConfigApi.h"
#import "CooCooBase.h"
#import "SMSVerficationViewController.h"
#import "GetOAuthService.h"
#import "GetAppUpdateService.h"

NSString *const UNASSIGNEDD = @"Not Assigned To Any Device";
@interface SignInViewController () <UITextFieldDelegate>{
    NSMutableArray *walletHuuids;
    NSArray *releasedCardsArray;
}
#pragma mark - Variables Declarations
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *forgotPassword;
@property (weak, nonatomic) IBOutlet UIView *viEmail;
@property (weak, nonatomic) IBOutlet UIView *viPassword;
@property (weak, nonatomic) IBOutlet FontAwesomeButton *btnEmail;
@property (weak, nonatomic) IBOutlet FontAwesomeButton *btnPassword;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *emailAddress;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *password;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnSignUp;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UIButton *linkSignUP;

@end

@implementation SignInViewController
#pragma mark - View lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    doLogin = NO;
    [self initialiseMethods];
    self.password.delegate = self;
    self.emailAddress.delegate = self;
    // Do any additional setup after loading the view from its nib.
    self.imgUser.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@LogoBig",[[Utilities tenantId] lowercaseString]]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.cdtaController = self;
    [self applyStylesAndColors];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
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
    if ([self.password respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@PlaceHolderTextColor",[[Utilities tenantId] lowercaseString]]]];
        self.password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
    self.view.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@LoginBGColor",[[Utilities tenantId] lowercaseString]]]];
    self.btnSignUp.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@BigButtonBGColor",[[Utilities tenantId] lowercaseString]]]];
    [self.linkSignUP setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@BigButtonBGColor",[[Utilities tenantId] lowercaseString]]]] forState:UIControlStateNormal];
    [self.forgotPassword setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@PlaceHolderTextColor",[[Utilities tenantId] lowercaseString]]]] forState:UIControlStateNormal];
}

-(void)initialiseMethods{
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Add Account" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

#pragma mark - Selector Methods
-(void)CardBasedSignin:(NSArray*)walletList{
    Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
    Singleton *Sclass = [Singleton sharedManager];
    NSPredicate *userpreda1 = [NSPredicate predicateWithFormat:
                               [NSString stringWithFormat:@"self.personId == %@", loggedInAccount.accountId]];
    NSArray *usersList = [walletList filteredArrayUsingPredicate:userpreda1];
 //   NSPredicate *notthisDevicepreda = [NSPredicate predicateWithFormat:
 //                                      [NSString stringWithFormat:@"self.deviceUUID != \"%@\" && self.deviceUUID != nil",[[Utilities deviceId] //stringByReplacingOccurrencesOfString:@" " withString:@""]]];
    NSPredicate *notthisDevicepreda = [NSPredicate predicateWithFormat:
                                       [NSString stringWithFormat:@"self.deviceUUID != \"%@\" && self.deviceUUID != nil && self.deviceUUID.length > 0",[[Utilities deviceId] stringByReplacingOccurrencesOfString:@" " withString:@""]]];
    NSArray *notthisdeviceList = [usersList filteredArrayUsingPredicate:notthisDevicepreda];
    if(notthisdeviceList.count>0){
        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]==NO){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"] message:[Utilities stringResourceForId:[Utilities walletUsingAlreadyMessage]] delegate:self cancelButtonTitle:nil otherButtonTitles:[Utilities stringResourceForId:@"ok"], nil];
            alert.tag = 101;
            [alert show];
            [[Singleton sharedManager] logOutHandler];
            return;
        }
    }
//    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
//                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@' && self.status=='Active'", loggedInAccount.accountId,[Utilities deviceId]]];
    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@'", loggedInAccount.accountId,[Utilities deviceId]]];

    NSArray *usersWalletList = [walletList filteredArrayUsingPredicate:userpreda];
    if(usersWalletList.count>0){
        NSDictionary * walletDict = usersWalletList.firstObject;
        [[NSUserDefaults standardUserDefaults]setObject:walletDict[@"walletId"] forKey:@"WALLET_ID"];
        [[NSUserDefaults standardUserDefaults]setObject:Sclass.userwallet.cardType forKey:@"WALLETCARDTYPE"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        BOOL walletAssigned = NO;
        for (NSDictionary *dict in walletList) {
            NSString * deviceId = [dict valueForKey:@"deviceId"];
            if (deviceId != nil && ![deviceId isKindOfClass:[NSNull class]] && deviceId.length > 0 && [[Utilities deviceId] isEqualToString:deviceId]) {
                NSLog(@"Wallet Assigned to Current Device");
                walletAssigned = YES;
                break;
            }else{
                walletAssigned = NO;
            }
        }
        if (walletAssigned == YES) {
            [self showProgressDialog];
            GetWalletContents *contents = [[GetWalletContents alloc]initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
            [contents execute];
            return;
        }else{
            [self showProgressDialog];
            AssignWalletApi *assignWalletApi = [[AssignWalletApi alloc]  initWithListener:self managedObjectContext:self.managedObjectContext accoundUuid:[Utilities deviceId]];
            [assignWalletApi execute];
        }
    }else{
        NSMutableArray *usersWalletList = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in walletList) {
            NSString* value = dict[@"deviceUUID"];
            NSString *status = dict[@"status"];
            if (([value isKindOfClass:[NSNull class]]||value.length==0)&&[status isEqualToString:@"Active"]) {
                [usersWalletList addObject:dict];
            }
        }
        if(usersWalletList.count>0){
            NSDictionary * walletDict = usersWalletList.firstObject;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:@"retriveWallet"] message:[Utilities stringResourceForId:@"retriveWalletAlertMessage"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *retrieveAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"retrieve"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showProgressDialog];
                Singleton *Sclass= [Singleton sharedManager];
                WalletContent *Wcontent=[[WalletContent alloc]initWithDictionary:walletDict];
                [Sclass setUserWalletFromApi:Wcontent];
                Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
                account.walletname=Wcontent.nickname;
                NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
                }
                [[NSUserDefaults standardUserDefaults]setObject:walletDict[@"walletId"] forKey:@"WALLET_ID"];
                [[NSUserDefaults standardUserDefaults]setObject:Sclass.userwallet.cardType forKey:@"WALLETCARDTYPE"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                AssignWalletApi *assignWalletApi = [[AssignWalletApi alloc]  initWithListener:self managedObjectContext:self.managedObjectContext accoundUuid:[Utilities deviceId]];
                [assignWalletApi execute];
            }];
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:[Utilities closeButtonTitle]] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
                [[Singleton sharedManager] logOutHandler];
            }];
            [alertController addAction:retrieveAction];
            [alertController addAction:closeAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            NSString * nibName = [Utilities walletInstructionsViewController];
            WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
            [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
            [self.cdtaController.navigationController pushViewController:walletInstructionsViewController animated:NO];
        }
    }
}
-(void)accountBasedSignin:(NSArray*)walletList{
    Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
    Singleton *Sclass = [Singleton sharedManager];
//    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
//                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@' && self.status=='Active'", loggedInAccount.accountId,[Utilities deviceId]]];
    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@'", loggedInAccount.accountId,[Utilities deviceId]]];
    NSArray *usersWalletList = [walletList filteredArrayUsingPredicate:userpreda];
    if(usersWalletList.count>0){
        NSDictionary * walletDict = usersWalletList.firstObject;
        [[NSUserDefaults standardUserDefaults]setObject:walletDict[@"walletId"] forKey:@"WALLET_ID"];
        [[NSUserDefaults standardUserDefaults]setObject:Sclass.userwallet.cardType forKey:@"WALLETCARDTYPE"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        WalletContent *Wcontent=[[WalletContent alloc]initWithDictionary:walletDict];
        [Sclass setUserWalletFromApi:Wcontent];
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        account.walletname=Wcontent.nickname;
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        }
        BOOL walletAssigned = NO;
        for (NSDictionary *dict in walletList) {
            NSString * deviceId = [dict valueForKey:@"deviceId"];
            if (deviceId != nil && ![deviceId isKindOfClass:[NSNull class]] && deviceId.length > 0 && [[Utilities deviceId] isEqualToString:deviceId]) {
                NSLog(@"Wallet Assigned to Current Device");
                walletAssigned = YES;
                break;
            }else{
                walletAssigned = NO;
            }
        }
        if (walletAssigned == YES) {
            [self showProgressDialog];
            GetWalletContents *contents = [[GetWalletContents alloc]initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
            [contents execute];
        }else{
            [self showProgressDialog];
            AssignWalletApi *assignWalletApi = [[AssignWalletApi alloc]  initWithListener:self managedObjectContext:self.managedObjectContext accoundUuid:[Utilities deviceId]];
            [assignWalletApi execute];
        }
    }else{
        NSMutableArray *usersWalletList = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in walletList) {
            NSString* value = dict[@"deviceUUID"];
            NSString *status = dict[@"status"];
            if (([value isKindOfClass:[NSNull class]]||value.length==0)&&[status isEqualToString:@"Active"]) {
                [usersWalletList addObject:dict];
            }
        }
        if(usersWalletList.count>0){
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
            WalletListAccountBaseViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"wallet"];
            accountBasedVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:accountBasedVC animated:true];
        }else{
            NSString * nibName = [Utilities walletInstructionsViewController];
            WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
            [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
            [self.navigationController pushViewController:walletInstructionsViewController animated:NO];
        }
    }
}
#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 101){
        [[Singleton sharedManager] logOutHandler];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if(alertView.tag == 102){
        [[Singleton sharedManager] logOutHandler];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
#pragma mark - UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.emailAddress) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}
#pragma mark UIButton Action Methods

-(IBAction)signUpHandler:(id)sender {
    SignUpViewController *signupController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:[NSBundle mainBundle]];
    signupController.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:signupController animated:YES];
}

- (IBAction)SignInHandler:(id)sender{
    NSString *email = self.emailAddress.text;
    NSString *password = self.password.text;
    if (([email length] > 0) && ([password length] > 0)) {
        [self.view endEditing:YES];
        [self showProgressDialog];
        NSString * accessToken = [Utilities commonaccessToken];
        if (accessToken) {
            LoginService *login =   [[LoginService alloc] initWithListener:self username:self.emailAddress.text password:self.password.text managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
            [login execute];
        }else{
            doLogin = YES;
            GetOAuthService * getOAuthService = [[GetOAuthService alloc] initWithListener:self];
            [getOAuthService execute];
        }
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"all_fields_required"]
                                                           delegate:nil
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)goToForgotPassword:(id)sender{
    ForgotLoginViewController *forgotloginView = [[ForgotLoginViewController alloc] initWithNibName:@"ForgotLoginViewController" bundle:nil];
    forgotloginView.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:forgotloginView animated:YES];
}

#pragma mark - Service Call Success method
- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
      if ([service isMemberOfClass:[GetOAuthService class]]){
        if (doLogin == YES) {
            [self showProgressDialog];
            LoginService *login =   [[LoginService alloc] initWithListener:self username:self.emailAddress.text password:self.password.text managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
            [login execute];
        }else{
            [self dismissProgressDialog];
        }
    }else if ([service isMemberOfClass:[LoginService class]]){
        [self showProgressDialog];
        AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self username:self.emailAddress.text password:self.password.text];
        [tokenService execute];
    }else if ([service isMemberOfClass:[AuthorizeTokenService class]]) {
        if(account.needs_additional_auth==true ){
            SMSVerficationViewController *smsVC=[[SMSVerficationViewController alloc] initWithNibName:@"SMSVerficationViewController" bundle:[NSBundle mainBundle]];
            smsVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:smsVC animated:true];
        }
        else{
            [self showProgressDialog];
            GetConfigApi *contents = [[GetConfigApi alloc]initWithListener:self];
            [contents execute];
        }
    }else if ([service isMemberOfClass:[GetConfigApi class]]) {
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        if(account){
            CheckWalletService *isWalletExist  = [[CheckWalletService alloc] initWithListener:self emailid:account.emailaddress managedContext:self.managedObjectContext];
            [isWalletExist execute];
        }
    }else if ([service isMemberOfClass:[CheckWalletService class]]){
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
//        json = [json dictionaryRemovingNSNullValues];
        NSMutableArray *walletlist =[[NSMutableArray alloc] initWithArray: [json objectForKey:@"result"]];
        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]==NO){
            [self CardBasedSignin:walletlist];
        }else{
            [self accountBasedSignin:walletlist];
        }
    }else if ([service isMemberOfClass:[AssignWalletApi class]]){
        [self showProgressDialog];
        GetWalletContents *contents = [[GetWalletContents alloc]initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
        [contents execute];
    }else if ([service isMemberOfClass:[GetWalletContents class]]){
        Singleton *singlet = [Singleton sharedManager];
        singlet.userJustLoggedIn = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserLoginSuccessful" object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
        
        GetProductsService *productsService = [[GetProductsService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
        [productsService execute];
    }else if ([service isMemberOfClass:[GetProductsService class]]){
//        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]){
//            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
//            CDTA_AccountBasedViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"accountbased"];
//            accountBasedVC.managedObjectContext=self.managedObjectContext;
//            [self.cdtaController.navigationController pushViewController:accountBasedVC animated:true];
//        }else{
//            CDTATicketsViewController *ticketsView = [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
//            [ticketsView setManagedObjectContext:self.managedObjectContext];
//            [self.cdtaController.navigationController pushViewController:ticketsView animated:NO];
//        }
    }
}

#pragma mark - Service Call Error method
- (void)threadErrorWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[CheckWalletService class]]){
//        NSString * jsonstr = (NSString *)response;
//        NSLog(@"error response %@",jsonstr);
//        NSError *jsonError;
//        NSData *objectData = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
//                                                             options:NSJSONReadingMutableContainers
//                                                               error:&jsonError];
////        json = [json dictionaryRemovingNSNullValues];
//        NSString *message = [json valueForKey:@"message"];
//        if([message isEqualToString:@"UnAuthorized to get devicewallets"]){
//            NSString * nibName = [Utilities walletInstructionsViewController];
//            WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
//            [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
//            [self.cdtaController.navigationController pushViewController:walletInstructionsViewController animated:NO];
//        }
    }else if ([service isMemberOfClass:[LoginService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"login_error_title"]
                                                            message:[Utilities stringResourceForId:@"login_error_msg"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
@end
