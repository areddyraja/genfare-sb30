//
//  CardSelectionViewController.m
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 3/23/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CardSelectionViewController.h"
#import "Card.h"
#import "CardSelectionCell.h"
#import "CDTATicketsViewController.h"
#import "NewTicketPurchaseViewController.h"
#import "RuntimeData.h"
#import "TicketPurchaseViewController.h"
#import "Utilities.h"
#import "WalletInstructionsViewController.h"

@interface CardSelectionViewController ()
{
    NSArray <Card *> *cards;
}

@end

@implementation CardSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Select Card"];
        
        cards = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.cardTableView registerNib:[UINib nibWithNibName:CARD_SELECTION_CELL bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CARD_SELECTION_CELL];
    
    cards = [Utilities getCards:self.managedObjectContext];
  
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Select Card" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];

    if ([cards count] == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        [self launchWalletInstructions];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Get the cards again to prevent issues where the cards have been gathered, but were deleted via a concurrent action.
    //cards = [Utilities getCards:self.managedObjectContext];
    //[self.cardTableView reloadData];
    
    if ([cards count] == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        [self launchWalletInstructions];
    } else {
        /*
        GetCardsService *getCardsService = [[GetCardsService alloc] initWithListener:self
                                                                          walletUuid:[Utilities walletId]
                                                                managedObjectContext:self.managedObjectContext];
        [getCardsService execute];
         */
    }
}

#pragma mark - Background service declaration and callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetCardsService class]]) {
        cards = [[Utilities getCards:self.managedObjectContext] copy];
        
        if ([cards count] == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            [self launchWalletInstructions];
        } else {
            [self.cardTableView reloadData];
        }
    }
    [self dismissProgressDialog];

}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];

    [self threadSuccessWithClass:service response:response];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CardSelectionCell *cell = (CardSelectionCell *)[tableView dequeueReusableCellWithIdentifier:CARD_SELECTION_CELL];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:CARD_SELECTION_CELL owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Card *card = [cards objectAtIndex:indexPath.row];
    
    NSString *nickname = @"Full Fare Card";
    if ([card.nickname length] > 0) {
        nickname = card.nickname;
    }
    
    [cell.nicknameLabel setText:nickname];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Card *card = [cards objectAtIndex:indexPath.row];
    
    [RuntimeData commitTicketSourceId:card.uuid];
    
    if ([card accountId] > 0) {
        BaseTicketPurchaseController *purchaseView = nil;
        
        if (NSClassFromString(@"WKWebView")) {
            purchaseView = [[NewTicketPurchaseViewController alloc] initWithNibName:@"NewTicketPurchaseViewController"
                                                                             bundle:[NSBundle baseResourcesBundle]];
        } else {
            purchaseView = [[TicketPurchaseViewController alloc] initWithNibName:@"TicketPurchaseViewController"
                                                                          bundle:[NSBundle baseResourcesBundle]];
        }
        
        [purchaseView setCreateCustomTicketsViewController:^BaseTicketsViewController *{
            return [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
        }];
        [purchaseView setManagedObjectContext:self.managedObjectContext];
        [purchaseView setAccountUuid:(NSString *)card.accountId];
        
        [self.navigationController pushViewController:purchaseView animated:YES];
    } else {
        BaseTicketPurchaseController *purchaseView = nil;
        
        if (NSClassFromString(@"WKWebView")) {
            purchaseView = [[NewTicketPurchaseViewController alloc] initWithNibName:@"NewTicketPurchaseViewController"
                                                                             bundle:[NSBundle baseResourcesBundle]];
        } else {
            purchaseView = [[TicketPurchaseViewController alloc] initWithNibName:@"TicketPurchaseViewController"
                                                                          bundle:[NSBundle baseResourcesBundle]];
        }
        
        [purchaseView setCreateCustomTicketsViewController:^BaseTicketsViewController *{
            return [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
        }];
        [purchaseView setManagedObjectContext:self.managedObjectContext];
        
        [self.navigationController pushViewController:purchaseView animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220.0;
}

#pragma mark - Other methods

- (void)launchWalletInstructions
{
    NSString * nibName = [Utilities walletInstructionsViewController];
    WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName
                                                                                                                            bundle:[NSBundle mainBundle]];
    [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:walletInstructionsViewController animated:YES];
}

@end
