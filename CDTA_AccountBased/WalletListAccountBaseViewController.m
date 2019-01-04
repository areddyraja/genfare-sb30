//
//  WalletListAccountBaseViewController.m
//  CDTATicketing Beta
//
//  Created by Gaian Solutions on 4/12/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "WalletListAccountBaseViewController.h"
#import "CheckWalletService.h"
#import "Account.h"
#import "CooCooAccountUtilities1.h"
#import "WalletContent.h"
#import "AssignWalletApi.h"
#import "GetWalletContents.h"
#import "WalletInstructionsViewController.h"
#import "Singleton.h"
#import "CDTA_AccountBasedViewController.h"
#import "CDTATicketsViewController.h"
@interface WalletListAccountBaseViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UITableView *WalletListtableview;
    IBOutlet UILabel *headinglabel;
    IBOutlet UIButton *createWalletButton;
    NSMutableArray *walletlistArray;
}
-(IBAction)createWallet:(id)sender;
@end

@implementation WalletListAccountBaseViewController

-(IBAction)createWallet:(id)sender
{
    NSString * nibName = [Utilities walletInstructionsViewController];
    WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
    [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:walletInstructionsViewController animated:NO];
}

-(IBAction)closeWalletWindow:(id)sender {
    Singleton *singleton = [Singleton sharedManager];
    [singleton logOutHandler];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissControllerWith:(BOOL)success {
    //TODO - Need to handle just close case
    [self dismissProgressDialog];
    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserLoginSuccessful" object:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    createWalletButton.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities continueButtonBgColor]]];
    
    walletlistArray=[[NSMutableArray alloc]init];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        CheckWalletService *isWalletExist  = [[CheckWalletService alloc] initWithListener:self emailid:account.emailaddress managedContext:self.managedObjectContext];
        [isWalletExist execute];
    }
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
     UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Slider Text" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
}
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    //    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Slider Text" owner:self options:nil] objectAtIndex:0];
//    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Text Screens" owner:self options:nil] objectAtIndex:0];
//    [[[Singleton sharedManager] ref_AccountBasedViewController].helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
//}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
}

 
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  walletlistArray.count;
}

- (void)threadSuccessWithClass:(id)service response:(id)response{
    //[super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[CheckWalletService class]]){
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
        
        NSArray *server = [json objectForKey:@"result"];
        [walletlistArray removeAllObjects];
        for(NSDictionary *dict in server){
            WalletContent *content = [[WalletContent alloc]initWithDictionary:dict];
            if([content.deviceUUID isEqualToString:[Utilities deviceId]]||content.deviceUUID==nil||[content.deviceUUID isKindOfClass:[NSNull class]] || content.deviceUUID.length ==0){
                [walletlistArray addObject:content];
            }
        }
        
        [WalletListtableview reloadData];
    } else if ([service isMemberOfClass:[AssignWalletApi class]]){
        [self dismissControllerWith:YES];
        return;
        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]){
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
            CDTA_AccountBasedViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"accountbased"];
            accountBasedVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:accountBasedVC animated:true];
            
        } else{
            CDTATicketsViewController *ticketsView = [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
            [ticketsView setManagedObjectContext:self.managedObjectContext];
            [self.navigationController pushViewController:ticketsView animated:YES];
        }
    }
      [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
      [self dismissProgressDialog];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"wallet"];
    cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0];
    WalletContent *wContent=[walletlistArray objectAtIndex:indexPath.row];
//    [wContent setStatusId:[NSNumber numberWithInt:2]];
    if ([[wContent statusId] integerValue]!= 2) {
        NSLog(@"Non - Active");
        [cell.contentView setBackgroundColor:[UIColor lightGrayColor]];
        [cell setUserInteractionEnabled:NO];
    }else{
        NSLog(@"Active");
    }
//    cell.textLabel.text=wContent.nickname.length==0?@"No Name":wContent.nickname;
    cell.textLabel.text=wContent.nickname.length==0?@"No Name":[NSString stringWithFormat:@"%@ - %@",wContent.nickname,wContent.status];
    cell.textLabel.textColor=[[Singleton sharedManager] getYellowThemeColor];
    return cell;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     WalletContent *wContent=[walletlistArray objectAtIndex:indexPath.row];
//    // rows in section 0 should not be selectable
//    if ( indexPath.section == 0 ) return nil;
    
//    // first 3 rows in any section should not be selectable
//    if ( indexPath.row <= 2 ) return nil;
     if ([[wContent statusId] integerValue] != 2) return nil;
    // By default, allow row to be selected
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:@"retriveWallet"] message:[Utilities stringResourceForId:@"retriveWalletAlertMessage"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *retrieveAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"retrieve"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self showProgressDialog];
        WalletContent *wContent=[walletlistArray objectAtIndex:indexPath.row];
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
       account.walletname=wContent.nickname;
        [[Singleton sharedManager] setUserWalletFromApi:wContent];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
            
        }
        [[NSUserDefaults standardUserDefaults]setObject:wContent.walletId forKey:@"WALLET_ID"];
        [[NSUserDefaults standardUserDefaults]setObject:wContent.cardType forKey:@"WALLETCARDTYPE"];
        
        [[NSUserDefaults standardUserDefaults]synchronize];
        AssignWalletApi *assignWalletApi = [[AssignWalletApi alloc]  initWithListener:self managedObjectContext:self.managedObjectContext accoundUuid:[Utilities deviceId]];
        [assignWalletApi execute];
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:[Utilities closeButtonTitle]] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action){
//        [[Singleton sharedManager] logOutHandler];
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alertController addAction:retrieveAction];
    [alertController addAction:closeAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
