//
//  EligibleCardsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 9/21/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "EligibleCardsViewController.h"
#import "CooCooAccountUtilities1.h"
#import "AssignCardToWalletService.h"
#import "Card.h"
#import "CardManagementCell.h"
#import "GetCardsForAccountService.h"
#import "Utilities.h"

@interface EligibleCardsViewController ()

@end

NSString *const NOT_ASSIGNED = @"Not Assigned To Any Device";

@implementation EligibleCardsViewController
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    account = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
    
    [self showProgressDialog];
    
    GetCardsForAccountService *cardsForAccountService = [[GetCardsForAccountService alloc] initWithListener:self accountId:account.accountId managedObjectContext:self.managedObjectContext];
    [cardsForAccountService execute];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[GetCardsForAccountService class]]) {
        [walletHuuids removeAllObjects];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:CARD_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isTemporary == 1"];
        [fetchRequest setPredicate:predicate];
        
        NSArray *cards = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        NSMutableArray *unsortedWalletHuuids = [[NSMutableArray alloc] init];
        
        for (Card *card in cards) {
            NSString *walletHuuid = @"";
            
            if ([card.walletUuid length] == 0) {
                walletHuuid = NOT_ASSIGNED;
            } else {
                walletHuuid = card.walletHuuid;
            }
            
            if (![unsortedWalletHuuids containsObject:walletHuuid]) {
                [unsortedWalletHuuids addObject:walletHuuid];
            }
        }
        
        for (NSString *walletHuuid in unsortedWalletHuuids) {
            if (![walletHuuid isEqualToString:NOT_ASSIGNED]) {
                [walletHuuids addObject:walletHuuid];
            }
        }
        
        // Add Not Assigned to end of walletUuids array
        if ([unsortedWalletHuuids containsObject:NOT_ASSIGNED]) {
            [walletHuuids addObject:NOT_ASSIGNED];
        }
        
        for (NSString *walletHuuid in walletHuuids) {
            NSMutableArray *cardsForWalletHuuid = [[NSMutableArray alloc] init];
            
            for (Card *card in cards) {
                if ([walletHuuid isEqualToString:NOT_ASSIGNED] && ([card.walletUuid length] == 0)) {
                    [cardsForWalletHuuid addObject:card];
                } else if ([card.walletHuuid isEqualToString:walletHuuid]) {
                    [cardsForWalletHuuid addObject:card];
                }
            }
            
            [cardsDictionary setObject:[cardsForWalletHuuid copy] forKey:walletHuuid];
        }
        
        [self.tableView reloadData];
        
        [self dismissProgressDialog];
    } else if ([service isMemberOfClass:[AssignCardToWalletService class]]) {
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
    
    if ([service isMemberOfClass:[GetCardsForAccountService class]]) {
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

#pragma mark - UITableView methods

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
    [self showProgressDialog];
    
    if ([[Utilities walletId] length] > 0) {
        AssignCardToWalletService *assignCardToWalletService = [[AssignCardToWalletService alloc] initWithListener:self walletUuid:[Utilities walletId] cardUuid:cardUuid managedObjectContext:self.managedObjectContext];
        [assignCardToWalletService execute];
    }
}

@end
