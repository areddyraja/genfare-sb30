//
//  SMSStatusVerificationViewController.m
//  CDTATicketing
//
//  Created by Gaian Solutions on 5/8/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "SMSStatusVerificationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SMSValidationService.h"
#import "Singleton.h"
#import "CheckWalletService.h"
#import "GetProductsService.h"
#import "WalletInstructionsViewController.h"
#import "AssignWalletApi.h"
#import "WalletListAccountBaseViewController.h"
@interface SMSStatusVerificationViewController ()
{
    int validationCount;
    int failureCases;
}
@end

@implementation SMSStatusVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [SVProgressHUD show];
    validationCount=0;
    failureCases=0;
    [self callSMSValidationService];
   
     [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:65.0/255.0 green:148.0/255.0 blue:160.0/255.0 alpha:1.0]];
//    smsVerificationLbl.text=[NSString stringWithFormat:@"%@\n%@",@"Please wait....",@"Registration Process is going on"];
     smsVerificationLbl.text=[NSString stringWithFormat:@"Account verification in progress"];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
}

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    
    [self dismissProgressDialog];

    if([service isMemberOfClass:[SMSValidationService class]]){
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        json = [json dictionaryRemovingNSNullValues];
        if([json[@"status"] isEqualToString:@"SUCCESS"]){
            Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
            account.needs_additional_auth=false;
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
                
            }
            
            if(account){
                CheckWalletService *isWalletExist  = [[CheckWalletService alloc] initWithListener:self emailid:account.emailaddress managedContext:self.managedObjectContext];
                [isWalletExist execute];
            }
        }
        else  if([json[@"status"] isEqualToString:@"PENDING"]){
            if(validationCount>30){
                [[Singleton sharedManager] logOutHandler];
                [self.navigationController popToRootViewControllerAnimated:true];
            }
            else{
            [self performSelector:@selector(callSMSValidationService) withObject:nil afterDelay:2.0];
            }
        }
        else  if([json[@"status"] isEqualToString:@"FAILURE"]){
            
            if(failureCases>10){
            
                UIAlertView *firstTimeView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"smsVerificationFailed"]
                                                                        message:json[@"detail"]
                                                                       delegate:nil
                                                              cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                              otherButtonTitles:nil];
                [firstTimeView show];
                
                
                [[Singleton sharedManager] logOutHandler];
                [self.navigationController popToRootViewControllerAnimated:true];
            }
            else{
                failureCases++;
                [self performSelector:@selector(callSMSValidationService) withObject:nil afterDelay:2.0];

            }
           
        }
    }
    else  if ([service isMemberOfClass:[GetProductsService class]]){
        NSString * nibName = [Utilities walletInstructionsViewController];
        WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
        [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
        [self.navigationController pushViewController:walletInstructionsViewController animated:NO];
        
        
    }
    
    else if ([service isMemberOfClass:[CheckWalletService class]]){
        
        Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
        if(loggedInAccount.needs_additional_auth==true){
            return;
        }
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        json = [json dictionaryRemovingNSNullValues];
        NSMutableArray *walletlist =[[NSMutableArray alloc] initWithArray: [json objectForKey:@"result"]];
        
        
        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]==NO){
            [self CardBasedSignin:walletlist];
        }
        else{
            [self accountBasedSignin:walletlist];
        }
         
    }
    
    
}

-(void)CardBasedSignin:(NSArray*)walletList
{
    Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
    Singleton *Sclass = [Singleton sharedManager];
    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@' && self.status=='Active'", loggedInAccount.accountId,[Utilities deviceId]]];
    NSArray *usersWalletList = [walletList filteredArrayUsingPredicate:userpreda];
    
    if(usersWalletList.count>0){
        
        NSDictionary * walletDict = usersWalletList.firstObject;
        [[NSUserDefaults standardUserDefaults]setObject:walletDict[@"walletId"] forKey:@"WALLET_ID"];
        [[NSUserDefaults standardUserDefaults]setObject:Sclass.userwallet.cardType forKey:@"WALLETCARDTYPE"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        AssignWalletApi *assignWalletApi = [[AssignWalletApi alloc]  initWithListener:self managedObjectContext:self.managedObjectContext accoundUuid:[Utilities deviceId]];
        [assignWalletApi execute];
        
    }
    else
    {
        
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
            [self.navigationController pushViewController:walletInstructionsViewController animated:NO];
        }
        
        
    }
    
    
}

-(void)accountBasedSignin:(NSArray*)walletList
{
    Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
    Singleton *Sclass = [Singleton sharedManager];
    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@' && self.status=='Active'", loggedInAccount.accountId,[Utilities deviceId]]];
    NSArray *usersWalletList = [walletList filteredArrayUsingPredicate:userpreda];
    
    if(usersWalletList.count>0){
        
        NSDictionary * walletDict = usersWalletList.firstObject;
        [[NSUserDefaults standardUserDefaults]setObject:walletDict[@"walletId"] forKey:@"WALLET_ID"];
        [[NSUserDefaults standardUserDefaults]setObject:Sclass.userwallet.cardType forKey:@"WALLETCARDTYPE"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        AssignWalletApi *assignWalletApi = [[AssignWalletApi alloc]  initWithListener:self managedObjectContext:self.managedObjectContext accoundUuid:[Utilities deviceId]];
        [assignWalletApi execute];
        
    }
    else
    {
        NSMutableArray *usersWalletList = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in walletList) {
            NSString* value = dict[@"deviceUUID"];
            NSString *status = dict[@"status"];
            if (([value isKindOfClass:[NSNull class]]||value.length==0)&&[status isEqualToString:@"Active"]) {
                [usersWalletList addObject:dict];
            }
        }
        
        
        
        if(usersWalletList.count>0)
        {
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
            WalletListAccountBaseViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"wallet"];
            accountBasedVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:accountBasedVC animated:true];
        }
        else{
            NSString * nibName = [Utilities walletInstructionsViewController];
            WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
            [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
            [self.navigationController pushViewController:walletInstructionsViewController animated:NO];
        }
    }
}


- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)callSMSValidationService{
    validationCount++;
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    
    if(account){
        SMSValidationService *service =  [[SMSValidationService alloc] initWithListener:self managedObjectContext:self.managedObjectContext deviceid:[Utilities deviceId]];
        [service execute];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
