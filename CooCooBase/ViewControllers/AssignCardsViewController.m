//
//  AssignCardsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 9/22/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "AssignCardsViewController.h"
#import "AssignCardService.h"
#import "Card.h"
#import "CardManagementCell.h"
#import "CooCooAccountUtilities1.h"
#import "IASKSpecifier.h"
#import "LoginService.h"
#import "RuntimeData.h"
#import "Utilities.h"

@interface AssignCardsViewController ()

@end

@implementation AssignCardsViewController
{
    Account *currentAccount;
    NSArray *cards;
    UILabel *emptyLabel;
    Card *cardToAssign;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Assign Cards"];
        
        cards = [[NSArray alloc] init];
    }
    
    return self;
}

- (id)initWithFile:(NSString *)file specifier:(IASKSpecifier *)specifier {
    if (self = [super init]) {
        [self setTitle:@"Assign Cards"];
        
        cards = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.managedObjectContext = [[RuntimeData instance] managedObjectContext];
    
    currentAccount = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    
    [self.header setText:[NSString stringWithFormat:@"You can assign cards to %@ if you want to be able to transfer the cards and their products between the account's registered devices. All cards on this device that have not yet been assigned to an account are shown below.",
                          currentAccount.emailaddress]];
    
    cards = [self loadUnassignedCards];
    
    NSLog(@"cards count: %lu", (unsigned long)[cards count]);
    
    [self showInformation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CardManagementCell";
    CardManagementCell *cell = (CardManagementCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Card *currentCard = [cards objectAtIndex:indexPath.row];
    
    [cell.cardImage setImage:[UIImage loadOverrideImageNamed:@"card"]];
    [cell.nicknameLabel setText:currentCard.nickname];
    [cell.huuidLabel setText:currentCard.huuid];
    
    if ([currentCard accountId] > 0) {
        [cell.accountLabel setText:currentCard.accountEmail];
    } else {
        [cell.accountLabel setText:@"Not Claimed"];
    }
    
    [cell.assignButton setTitle:[Utilities stringResourceForId:@"assign"] forState:UIControlStateNormal];
    
    [cell addTargetForAssignButton:self action:@selector(assignPressed:) cardUuid:currentCard.uuid];
    
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
    
    UIAlertAction *verify = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"verify"]
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self showProgressDialog];
                                                       
                                                       cardToAssign = [self cardWithUuid:cardUuid];
                                                       
                                                       NSString *password = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
                                                       
                                                       LoginService *loginService = [[LoginService alloc] initWithListener:self username:currentAccount.emailaddress password:password managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
                                                       
                                                       [loginService execute];
                                                   }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"cancel"]
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       cardToAssign = nil;
                                                       
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:verify];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:[NSString stringWithFormat:@"%@ for %@", [Utilities stringResourceForId:@"password"], currentAccount.emailaddress]];
        [textField setSecureTextEntry:YES];
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[LoginService class]]) {
        [self dismissProgressDialog];

        Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
        
        AssignCardService *assignCardService = [[AssignCardService alloc] initWithListener:self
                                                                      managedObjectContext:self.managedObjectContext
                                                                                      card:cardToAssign
                                                                               accoundUuid:loggedInAccount.accountId];
        [assignCardService execute];
    } else if ([service isMemberOfClass:[AssignCardService class]]) {
        [self dismissProgressDialog];
        
        cards = [self loadUnassignedCards];
        
        [self showInformation];
        
        cardToAssign = nil;
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
    } else if ([service isMemberOfClass:[AssignCardService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"unableToAssignWalletMessage"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    cardToAssign = nil;
}

#pragma mark - Other methods

- (void)showInformation
{
    if ([cards count] > 0) {
        [self.tableView setHidden:NO];
        
        if (emptyLabel != nil) {
            [emptyLabel setHidden:YES];
        }
    } else {
        [self.tableView setHidden:YES];
        
        if (emptyLabel != nil) {
            [emptyLabel setHidden:NO];
        } else {
            CGRect applicationFrame = [[UIScreen mainScreen] bounds];
            
            emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, applicationFrame.size.width - 16.0f, 0.0f)];
            [emptyLabel setText:@"This device has no unassigned cards. All cards on this device have been assigned to an account."];
            [emptyLabel setTextAlignment:NSTextAlignmentCenter];
            [emptyLabel setFont:[UIFont systemFontOfSize:16]];
            [emptyLabel setNumberOfLines:0];
            [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [emptyLabel sizeToFit];
            [emptyLabel setFrame:CGRectMake(8.0f,
                                            self.header.frame.origin.y + self.header.frame.size.height
                                            + (emptyLabel.frame.size.height * 2),
                                            emptyLabel.frame.size.width,
                                            emptyLabel.frame.size.height)];
            [emptyLabel setHidden:NO];
            
            [self.view addSubview:emptyLabel];
        }
    }
    
    [self.tableView reloadData];
}

- (NSArray *)loadUnassignedCards
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CARD_MODEL inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isTemporary == 0"];
    [fetchRequest setPredicate:predicate];
    
    // Sorting cards from oldest to newest
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDateTime" ascending:YES];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *temporaryCards = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *unassignedCards = [[NSMutableArray alloc] init];
    
    for (Card *card in temporaryCards) {
        if ([card accountId] == 0) {
            [unassignedCards addObject:card];
        }
    }
    
    return unassignedCards;
}

/*
 * In order to reuse CardManagementCell's assign butten, we have to do the run-around
 * of looking up a card by its cardUuid
 */
- (Card *)cardWithUuid:(NSString *)cardUuid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CARD_MODEL inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", cardUuid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *matchingCards = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([matchingCards count] == 1) {
        return [matchingCards objectAtIndex:0];
    }
    
    return nil;
}

@end

