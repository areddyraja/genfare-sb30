//
//  CardManagementViewController.m
//  CooCooBase
//
//  Created by AK on 3/15/16.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "CardManagementViewController.h"
#import "AppDelegate.h"
#import "IASKSettingsReader.h"

@interface CardManagementViewController ()

@end

NSString *const UNASSIGNED = @"Not Assigned To Any Device";

@implementation CardManagementViewController
{
    Account *account;
    UILabel *emptyLabel;
    
    NSMutableArray *walletHuuids;
    NSMutableDictionary *cardsDictionary;
    
    NSString *selectedCardUuid;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"card_management"]];
        
        walletHuuids = [[NSMutableArray alloc] init];
        cardsDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (id)initWithFile:(NSString *)file specifier:(IASKSpecifier *)specifier {
    if (self = [super init]) {
        [self setTitle:[Utilities stringResourceForId:@"card_management"]];
        
        walletHuuids = [[NSMutableArray alloc] init];
        cardsDictionary = [[NSMutableDictionary alloc] init];
        
        /*IASKSettingsReader *settingsReader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"PasswordSettings" applicationBundle:[NSBundle baseResourcesBundle]];
         [settingsReader setShowPrivacySettings:NO];*/
        
        /* [self setSettingsReader:settingsReader];
         
         settingsStore = [[SettingsStore alloc] init];
         [self setSettingsStore:settingsStore];*/
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    /*UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Device Management" owner:self options:nil] objectAtIndex:0];
     [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
     */
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    
    [self showProgressDialog];
    
    // Change title of back button on next screen
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"back"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    GetCardsForAccountService *cardsForAccountService = [[GetCardsForAccountService alloc] initWithListener:self
                                                                                                  accountId:account.accountId
                                                                                       managedObjectContext:self.managedObjectContext];
    [cardsForAccountService execute];
}


- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[LoginService class]]) {
        if ([[Utilities walletId] length] > 0) {
            [self dismissProgressDialog];

            AssignCardToWalletService *assignCardToWalletService = [[AssignCardToWalletService alloc] initWithListener:self
                                                                                                            walletUuid:[Utilities walletId]
                                                                                                              cardUuid:selectedCardUuid
                                                                                                  managedObjectContext:self.managedObjectContext];
            [assignCardToWalletService execute];
        }
    } else if ([service isMemberOfClass:[GetCardsForAccountService class]]) {
        [walletHuuids removeAllObjects];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:CARD_MODEL inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isTemporary == 1"];
        [fetchRequest setPredicate:predicate];
        
        NSArray *cards = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        NSMutableArray *unsortedWalletHuuids = [[NSMutableArray alloc] init];
        
        for (Card *card in cards) {
            NSString *walletHuuid = @"";
            
            if ([card.walletUuid length] == 0) {
                walletHuuid = UNASSIGNED;
            } else {
                walletHuuid = card.walletHuuid;
            }
            
            if (![unsortedWalletHuuids containsObject:walletHuuid]) {
                [unsortedWalletHuuids addObject:walletHuuid];
            }
        }
        
        for (NSString *walletHuuid in unsortedWalletHuuids) {
            if (![walletHuuid isEqualToString:UNASSIGNED]) {
                [walletHuuids addObject:walletHuuid];
            }
        }
        
        // Add Unassigned to end of walletUuids array
        if ([unsortedWalletHuuids containsObject:UNASSIGNED]) {
            [walletHuuids addObject:UNASSIGNED];
        }
        
        for (NSString *walletHuuid in walletHuuids) {
            NSMutableArray *cardsForWalletHuuid = [[NSMutableArray alloc] init];
            
            for (Card *card in cards) {
                if ([walletHuuid isEqualToString:UNASSIGNED] && ([card.walletUuid length] == 0)) {
                    [cardsForWalletHuuid addObject:card];
                } else if ([card.walletHuuid isEqualToString:walletHuuid]) {
                    [cardsForWalletHuuid addObject:card];
                }
            }
            
            [cardsDictionary setObject:[cardsForWalletHuuid copy] forKey:walletHuuid];
        }
        
        [self.deviceTableView reloadData];
        
        [self dismissProgressDialog];
    } else if ([service isMemberOfClass:[AssignCardToWalletService class]]) {
        [self dismissProgressDialog];
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = delegate.managedObjectContext;
        
        account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        GetCardsForAccountService *cardsForAccountService = [[GetCardsForAccountService alloc] initWithListener:self
                                                                                                      accountId:account.accountId
                                                                                           managedObjectContext:self.managedObjectContext];
        [cardsForAccountService execute];
        
        selectedCardUuid = nil;
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[LoginService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"login_error_title"]
                                                            message:[Utilities stringResourceForId:@"login_error_msg"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                  otherButtonTitles:nil];
        [alertView show];
    } else if ([service isMemberOfClass:[AssignCardToWalletService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"unableToAddWalletMessage"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
    }
    
    selectedCardUuid = nil;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [walletHuuids count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Wallet: %@", [walletHuuids objectAtIndex:section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[cardsDictionary objectForKey:[walletHuuids objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CardManagementCell";
    CardManagementCell *cell = (CardManagementCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Card *currentCard = [[cardsDictionary objectForKey:[walletHuuids objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    [cell.cardImage setImage:[UIImage loadOverrideImageNamed:@"card"]];
    [cell.nicknameLabel setText:currentCard.nickname];
    [cell.huuidLabel setText:currentCard.huuid];
    
    if ([currentCard accountId] > 0) {
        [cell.accountLabel setText:currentCard.accountEmail];
    } else {
        [cell.accountLabel setText:@"Not Claimed"];
    }
    
    if ([currentCard.walletUuid length] == 0) {
        [cell.assignButton setHidden:NO];
        [cell addTargetForAssignButton:self action:@selector(assignPressed:) cardUuid:currentCard.uuid];
    } else {
        [cell.assignButton setHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 260;
}

- (void)assignPressed:(id)cardUuid
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:@"assign_card"]
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *verify = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"verify"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showProgressDialog];
        
        selectedCardUuid = cardUuid;
        
        NSString *password = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
        
        LoginService *loginService = [[LoginService alloc] initWithListener:self username:account.emailaddress password:password managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
        
        [loginService execute];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"cancel"]
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       selectedCardUuid = nil;
                                                       
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:verify];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:[NSString stringWithFormat:@"%@ for %@", [Utilities stringResourceForId:@"password"], account.emailaddress]];
        [textField setSecureTextEntry:YES];
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
