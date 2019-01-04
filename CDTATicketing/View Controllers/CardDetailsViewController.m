//
//  CardDetailsViewController.m
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 3/23/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CardDetailsViewController.h"
#import "CardDetailsCell.h"
#import "LoginViewController.h"
#import "UserData.h"
#import "StoredValueAccount.h"
#import "StoredValueLoyalty.h"
#import "StoredValueProgramRule.h"
#import "StoredValueRange.h"
#import "StoredValueRuleCriteria.h"
#import "StoredValueSyncService.h"
#import "StoredValueProduct.h"
#import "Utilities.h"
#import "AppDelegate.h"
#import "CooCooAccountUtilities1.h"
#import "WalletReleaseService.h"
#import "GetOAuthService.h"
#import "Singleton.h"
#import "GetWalletContents.h"
#import "LoyaltyBonus.h"
#import "LoyaltyCapped.h"
#import "Wallet.h"
#import "WalletContent.h"
#import "AppConstants.h"
#import "iRide-Swift.h"
#import "CustomUnassignAlertViewController.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

NSString *const CARD_DETAILS_TITLE = @"Card Details";
float const DETAILS_CELL_HEIGHT = 64.0;

@interface CardDetailsViewController ()

@end

@implementation CardDetailsViewController{
    NSString *releasedCardUuid;
    NSString *cappedRides;
    NSString *bonusRides;
    NSString *emailaddress;
    NSString *currentWalletPassword;
    WalletContent *walletContent ;
    LoyaltyBonus *bonus ;
    LoyaltyCapped *capped;
    int cappedThreshold;
    int bonusThreshold;
    NSString *nickname;
    NSString *cardType;
    NSString *accountType;
    NSArray *filteredProdcutArray;
    UIAlertView *singleAlertView;
}
#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:CARD_DETAILS_TITLE];
    [self.cardTableView registerNib:[UINib nibWithNibName:@"CardDetailsCell" bundle:nil] forCellReuseIdentifier:@"cardDetailsCell"];
//    self.btnTransfer.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]] ;
    self.btnTransfer.layer.cornerRadius = 8.0;
    self.btnTransfer.layer.masksToBounds = YES;
    //self.btnTransfer.layer.borderWidth = 1.0;
    self.cardTableView.layer.borderColor = [UIColor colorWithRed:231/255.0 green:233/255.0 blue:238/255.0 alpha:1].CGColor;
    self.cardTableView.layer.masksToBounds = YES;
    //[self.navigationItem setHidesBackButton:YES];
    
//    UIBarButtonItem *btnHome = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"] style:UIBarButtonItemStylePlain target:self action:@selector(homeBtnHandler)];
//    self.navigationItem.rightBarButtonItem = btnHome;
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    NSString * walletId = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",walletId]];
    NSError *error = nil;
    walletarray = [self.managedObjectContext executeFetchRequest:request error:&error];
    walletContent = (WalletContent *)[walletarray lastObject];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    emailaddress =  account.emailaddress;
    currentWalletPassword = account.password;
    cappedThreshold = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_THRESHOLD"]).intValue;
    bonusThreshold = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_THRESHOLD"]).intValue;
    accountType = [[NSUserDefaults standardUserDefaults] valueForKey:@"Account_Type"];
    //    cardType = wallet.accountType;
    cardType = account.profileType;
    if(account.firstName){
        //        nickname=account.firstName;
//        nickname=account.walletname.length==0?@" ":account.walletname;
//        nickname=wallet.nickname.length==0?@" ":wallet.nickname;
        nickname=walletContent.nickname.length==0?@" ":[NSString stringWithFormat:@"%@ - %@",walletContent.nickname,walletContent.status];
    }
    NSFetchRequest *Productrequest = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    NSError *producterror = nil;
    NSArray* totalProdcutArray = [self.managedObjectContext executeFetchRequest:Productrequest error:&producterror];
    if (totalProdcutArray.count >0) {
        filteredProdcutArray = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@) AND isActivationOnly == 1 ",@"Stored Value"]];
        [self.cardTableView reloadData];
    }
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bct-logo-blue.png"]];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Card was released
    if (self.card == nil) {
        // [self.navigationController popViewControllerAnimated:YES];
    }
    NSString *cardtypevalue = [[NSUserDefaults standardUserDefaults] objectForKey:@"WALLETCARDTYPE"];
    if(![cardtypevalue.lowercaseString containsString:@"full"]){
        self.cardImage.image=[UIImage imageNamed:@"pass.png"];
    }else{
        //         self.cardImage.image=[UIImage imageNamed:@"card.png"];
        self.cardImage.image=[UIImage imageNamed:@"pass.png"];
    }
    [self updateUiBasedOnWalletState];
    [self.cardTableView reloadData];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#dadada"];
}

-(void)updateUiBasedOnWalletState{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    NSString * walletId = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",walletId]];
    NSError *error = nil;
    NSArray *walletarray = [self.managedObjectContext executeFetchRequest:request error:&error];
    WalletContent *walletContent  = (WalletContent *)[walletarray lastObject];
    if ([[walletContent statusId] integerValue]!= WALLET_STATUS_ACTIVE) {
        NSLog(@"Non - Active");
        [_btnTransfer setUserInteractionEnabled:NO];
        [_btnTransfer setBackgroundColor:[UIColor lightGrayColor]];
    }else{
        NSLog(@"Active");
        [_btnTransfer setUserInteractionEnabled:YES];
        [_btnTransfer setBackgroundColor:[UIColor colorWithHexString:@"#223668"] ];
    }
}
#pragma mark - Selector Methods
-(void)homeBtnHandler{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - UITableView DataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (filteredProdcutArray.count > 0) {
        return 5;
    }
    
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CardDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardDetailsCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIButton *btnAssign = [UIButton buttonWithType:UIButtonTypeCustom];
    [cell.btnAssign setHidden:YES];
    [cell.btnAssign setUserInteractionEnabled:NO];
    [cell.btnAssign addTarget:self action:@selector(showCustomUnassignAlert) forControlEvents:UIControlEventTouchUpInside];
    
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
//    if(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS){
//        cell.title.font = [UIFont systemFontOfSize:13];
//        cell.detail.font = [UIFont systemFontOfSize:13];
//    }else{
//        cell.title.font = [UIFont systemFontOfSize:15];
//        cell.detail.font = [UIFont systemFontOfSize:15];
//    }
    switch (indexPath.row) {
        case 0:
            [cell.title setText:@"Account Email"];
            if ([account.emailaddress length] > 0) {
                [cell.detail setText:account.emailaddress];
                [cell.btnAssign setHidden:NO];
                [cell.btnAssign setUserInteractionEnabled:YES];
            } else {
                [self createAssignButtonWithCell:cell andButton:btnAssign];
                //[cell.detail setText:@"Not Assigned"];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            break;
        case 1:
            [cell.title setText:@"Card Nickname"];
            [cell.detail setText:nickname];
            break;
        case 2:{
            [cell.title setText:@"Card Type"];
            [cell.detail setText:[NSString stringWithFormat:@"%@(%@)",walletContent.cardType,cardType]];
        }
            break;
        case 3:
            [self getProgramInfoForBonus];
            [cell.title setText:@"Bonus Accruals"];
            [cell.detail setText:bonusRides];
            break;
        case 4:
            [self getProgramInfoCappedRide];
            [cell.title setText:@"Capped Accruals"];
            [cell.detail setText:cappedRides];
            break;
        default:
            break;
    }
    return cell;
}
#pragma mark - UITableView Delegate methods
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DETAILS_CELL_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 94;
    }
    return DETAILS_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.cardTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0) {
        NSString *title = [NSString stringWithFormat:@"Account Assignment"];
        NSString *accountMessage = @"";
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        if ([account.emailaddress length] > 0) {
//            accountMessage = @"Please call customer service if you wish to unassign this card from your account.";
//            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel
//                                                                handler:^(UIAlertAction * action){}];
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
//                                                                           message:accountMessage
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//
//            [alert addAction:closeAction];
//            [self showCustomUnassignAlert];
        } else {
            accountMessage = @"You can assign a card to your account if you want to be able to transfer a card and its products between your registered devices.";
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:accountMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        if ([account.emailaddress length] > 0) {
            UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel
                                                                handler:^(UIAlertAction * action){}];
            [alert addAction:closeAction];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
            UIAlertAction *assignAction = [UIAlertAction actionWithTitle:@"Assign To Account" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                     AssignOrCreateViewController *assignOrCreateViewController = [[AssignOrCreateViewController alloc] initWithNibName:@"AssignOrCreateViewController" bundle:[NSBundle baseResourcesBundle]];
                                                                     [assignOrCreateViewController setCard:self.card];
                                                                     [assignOrCreateViewController setManagedObjectContext:self.managedObjectContext];
                                                                     
                                                                     [self.navigationController pushViewController:assignOrCreateViewController animated:YES];
                                                                 }];
            [alert addAction:assignAction];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action){}];
            [alert addAction:cancelAction];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showCustomUnassignAlert {
    CustomUnassignAlertViewController *controller = [[CustomUnassignAlertViewController alloc] initWithNibName:@"CustomUnassignAlertViewController" bundle:nil];
    controller.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    controller.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

#pragma mark - UITableView Supporting methods
-(void)createAssignButtonWithCell:(CardDetailsCell *)cell andButton:(UIButton *)btnAssign{
    [btnAssign addTarget:self action:@selector(assignButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    btnAssign.frame = CGRectMake(SCREEN_WIDTH - 30 - 80, 10, 70, cell.frame.size.height-20);
    [btnAssign setTitle:@"UnAssign" forState:UIControlStateNormal];
    btnAssign.titleLabel.font = [UIFont fontWithName:@"Montserrat" size:12.0];
    [btnAssign setBackgroundColor:[UIColor colorWithRed:236.0/255 green:169.0/255 blue:0/255.0 alpha:1]];
    //btnAssign.layer.cornerRadius = 8.0;
    btnAssign.layer.masksToBounds = YES;
    [cell.contentView addSubview:btnAssign];
}
-(void)assignButtonHandler:(id)sender{
    NSString *title = [NSString stringWithFormat:@"Account Assignment"];
    NSString *accountMessage = @"";
    if ([self.card.accountEmail length] > 0) {
        accountMessage = @"Please call customer service if you wish to unassign this card from your account.";
    } else {
        accountMessage = @"You can assign a card to your account if you want to be able to transfer a card and its products between your registered devices.";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:accountMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if ([self.card.accountEmail length] > 0) {
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction * action){}];
        [alert addAction:closeAction];
    } else {
        UIAlertAction *assignAction = [UIAlertAction actionWithTitle:@"Assign To Account" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 AssignOrCreateViewController *assignOrCreateViewController = [[AssignOrCreateViewController alloc] initWithNibName:@"AssignOrCreateViewController" bundle:[NSBundle baseResourcesBundle]];
                                                                 [assignOrCreateViewController setCard:self.card];
                                                                 [assignOrCreateViewController setManagedObjectContext:self.managedObjectContext];
                                                                 
                                                                 [self.navigationController pushViewController:assignOrCreateViewController animated:YES];
                                                             }];
        [alert addAction:assignAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action){}];
        [alert addAction:cancelAction];
    }
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)getProgramInfoForBonus{
    bonusRides=@"";
    if (bonusThreshold == -1) {
        bonusRides = @"NA";
        return;
    }
    NSString *bonusstring;
    for(Product *prod in filteredProdcutArray){
        LoyaltyBonus *prodBonus=[[Singleton sharedManager] getLoyalityBonusForProduct:prod];
        if ([[prod isBonusRideEnabled] boolValue]== YES) {
            if(prodBonus){
                if ([prod.price isEqualToString:@"0"]) {
                    bonusstring = [NSString stringWithFormat:@"%@ N/A\n",prod.productDescription];
                }else if (bonusThreshold == 0){
                    bonusstring = [NSString stringWithFormat:@"%@ N/A\n",prod.productDescription];
                }else{
                    bonusstring = [NSString stringWithFormat:@"%@ %@/%i\n",prod.productDescription,prodBonus.rideCount.stringValue,bonusThreshold];
                }
                bonusRides=[bonusRides stringByAppendingString:bonusstring];
            }
            else{
                NSString *bonusstring = [NSString stringWithFormat:@"%@ %d/%i\n",prod.productDescription,0,bonusThreshold];
                bonusRides=[bonusRides stringByAppendingString:bonusstring];
            }
        }else{
            bonusstring = [NSString stringWithFormat:@"%@ N/A\n",prod.productDescription];
            bonusRides=[bonusRides stringByAppendingString:bonusstring];
        }
    }
    //read the bonus
    if (bonusRides.length ==0) {
        bonusRides = @"NA";
    }
}
-(void)getProgramInfoCappedRide{
    cappedRides=@"";
    if (cappedThreshold == -1) {
        cappedRides = @"NA";
        return;
    }
    NSString *cappedString;
    for(Product *prod in filteredProdcutArray){
        LoyaltyCapped *prodCapped=[[Singleton sharedManager] getLoyalityCappedForProduct:prod];
        if ([[prod isCappedRideEnabled] boolValue] == YES) {
            if(prodCapped){
                if ([prod.price isEqualToString:@"0"]) {
                    cappedString = [NSString stringWithFormat:@"%@ N/A\n",prod.productDescription];
                }else if (cappedThreshold == 0){
                    cappedString = [NSString stringWithFormat:@"%@ N/A\n",prod.productDescription];
                }
                else{
                    cappedString = [NSString stringWithFormat:@"%@ %@/%i\n",prod.productDescription,prodCapped.rideCount.stringValue,cappedThreshold];
                }
                cappedRides=[cappedRides stringByAppendingString:cappedString];
            }else{
                NSString *cappedString = [NSString stringWithFormat:@"%@ %d/%i\n",prod.productDescription,0,cappedThreshold];
                cappedRides=[cappedRides stringByAppendingString:cappedString];
            }
        }else{
            cappedString = [NSString stringWithFormat:@"%@ N/A\n",prod.productDescription];
            cappedRides=[cappedRides stringByAppendingString:cappedString];
        }
    }
    //read the capped
    if (cappedRides.length ==0) {
        cappedRides = @"NA";
    }
}
-(NSArray*) getLoyalityCapped  {
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_CAPPED_MODEL inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", product.ticketId.stringValue];
    // [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"activatedTime" ascending:YES];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}
-(NSArray*) getLoyalityBonus{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_BONUS_MODEL inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", product.ticketId.stringValue];
    // [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"activatedTime" ascending:YES];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    return   [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}
#pragma mark - UIButton Action Methods
- (IBAction)transferCard:(id)sender {
    NSString *email = emailaddress;
    if ([email length] > 0) {
        NSString *message = [NSString stringWithFormat:@"Enter the password for %@ to view cards assigned to its account.\n\nOnce the password is verified, this card will be released from this device and you will no longer have access to it until you select a device in which to store the card.\n\n You will also be auto logged out from your account", email];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:@"view_card_management"]
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            [textField setPlaceholder:[Utilities stringResourceForId:@"password"]];
            [textField setSecureTextEntry:YES];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"cancel"]
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action) {
                                                             }];
        [alertController addAction:cancelAction];
        NSString *password = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
        UIAlertAction *verify = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"verify"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           // [self showProgressDialog];
                                                           NSString *password = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
                                                           if (password.length > 0){
                                                                   if([password isEqualToString:currentWalletPassword] ){

                                                                   //                                                           LoginService *loginService = [[LoginService alloc] initWithListener:self username:email password:password managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
                                                                   //
                                                                   //                                                           [loginService execute];
                                                                   WalletReleaseService *walletreleaseservice = [[WalletReleaseService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
                                                                   [walletreleaseservice execute];
                                                               }else{
                                                                   NSLog(@"Enter Correct Password");
                                                                   singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"password"]
                                                                                                                message:[Utilities stringResourceForId:@"invalidPassword"]
                                                                                                               delegate:self
                                                                                                      cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                                                                      otherButtonTitles:nil,nil];
                                                                   [singleAlertView show];
                                                               }
                                                           }else{
                                                               singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"password"]
                                                                                                            message:[Utilities stringResourceForId:@"enterPassword"]
                                                                                                           delegate:self
                                                                                                  cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                                                                  otherButtonTitles:nil,nil];
                                                               [singleAlertView show];
                                                           }
                                                       }];
        [alertController addAction:verify];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Account Assignment"
                                                            message:@"Your card must first be assigned to an account before it can be transferred to another device."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
#pragma mark - Service Call Success method
- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[WalletReleaseService class]]) {
        [self dismissProgressDialog];

        [self.navigationController popToRootViewControllerAnimated:YES];
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        
        //        [CooCooAccountUtilities1 deleteAccountIfIdExists:account.accountId managedObjectContext:self.managedObjectContext];
        [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
        [[Singleton sharedManager] logOutHandler];
        GetOAuthService *oauthservice= [[GetOAuthService alloc] initWithListener:self];
        [oauthservice execute];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserLogoutSucceful" object:nil];
    }if ([service isMemberOfClass:[LoginService class]]) {
        [self dismissProgressDialog];

        releasedCardUuid = [self.card.uuid copy];
        ReleaseCardService *releaseCard = [[ReleaseCardService alloc] initWithListener:self managedObjectContext:self.managedObjectContext card:self.card];
        [releaseCard execute];
    } else if ([service isMemberOfClass:[ReleaseCardService class]]) {
        [self dismissProgressDialog];
        [self eraseStoredValue:releasedCardUuid];
        releasedCardUuid = nil;
        self.card = nil;
        [[Singleton sharedManager] logOutHandler];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserLogoutSucceful" object:nil];
        //        EligibleCardsViewController *eligibleCardsViewController = [[EligibleCardsViewController alloc] initWithNibName:@"EligibleCardsViewController"
        //                                                                                                                 bundle:[NSBundle baseResourcesBundle]];
        //        [eligibleCardsViewController setManagedObjectContext:self.managedObjectContext];
        //
        //        [self.navigationController pushViewController:eligibleCardsViewController animated:YES];
    }
}
#pragma mark - Service Call Error method
- (void)threadErrorWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[LoginService class]]) {
        if ([service isMemberOfClass:[LoginService class]]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"login_error_title"]
                                                                message:[Utilities stringResourceForId:@"login_error_msg"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    } else if ([service isMemberOfClass:[ReleaseCardService class]]) {
        NSDictionary *responseJson = (NSDictionary *)response;
        NSDictionary *errorJson = [responseJson objectForKey:@"error"];
        NSNumber *errorCode = [errorJson valueForKey:@"code"];
        if ([errorCode intValue] == 5) {
            NSString *errorMessage = [errorJson valueForKey:@"message"];
            NSString *timeString = [errorMessage substringFromIndex:([errorMessage rangeOfString:@":"].location + 2)];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'"];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSDate *validStartDate = [formatter dateFromString:timeString];
            NSString *validStartDateString = [NSDateFormatter localizedStringFromDate:validStartDate
                                                                            dateStyle:NSDateFormatterShortStyle
                                                                            timeStyle:NSDateFormatterShortStyle];
            NSString * errorString = [Utilities stringResourceForId:@"walletReleaseErrorMessage"];
            NSString *message = [NSString stringWithFormat:@"%@ %@.",errorString, validStartDateString];
            UIAlertView *firstTimeView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"walletReleaseErrorTitle"]
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                          otherButtonTitles:nil];
            [firstTimeView show];
        }
    }
}
#pragma mark - Erase StoredValue method
- (void)eraseStoredValue:(NSString *)cardUuid{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_ACCOUNT_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"association LIKE[c] %@", cardUuid];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *accounts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (StoredValueAccount *account in accounts) {
        [self.managedObjectContext deleteObject:account];
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error ! %@", error);
    }
}
@end
