//
//  TicketHistoryViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTA_AB_HistoryViewController.h"
#import "AppConstants.h"
#import "CardEvent.h"
#import "GetWalletActivity.h"
#import "GetTicketsService.h"
#import "Ticket.h"
#import "TicketHistoryCell.h"
#import "TicketPageViewController.h"
#import "Utilities.h"
#import "WalletActivity.h"
#import "Product.h"
#import "CooCooBase.h"
#import "Singleton.h"

@interface CDTA_AB_HistoryViewController ()

@end

@implementation CDTA_AB_HistoryViewController
{
    UILabel *emptyLabel;
   // UIActivityIndicatorView *spinner;
    NSMutableDictionary *ticketsDictionary;
     NSDateFormatter *dateFormatter;
    NSArray *totalProdcutArray;
    NSMutableArray *productsListArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:[Utilities historyTitle]]];
        
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        ticketsDictionary = [[NSMutableDictionary alloc] init];
 
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/YY HH:mm"];
    }
    
    return self;
}

#pragma mark - View lifecycle


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Text Screens" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    GetWalletActivity *getTicketService = [[GetWalletActivity alloc] initWithListener:self
                                                                 managedObjectContext:self.managedObjectContext];
    [getTicketService execute];
    [self loadHistory1];
    self.view.backgroundColor = UIColor.clearColor;
    self.tableView.backgroundColor = UIColor.clearColor;

}
- (void)viewDidLoad
{
    [super viewDidLoad];

    
    //spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    ticketsDictionary = [[NSMutableDictionary alloc] init];
 
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/YY    HH:mm aa"];
    
    
   // [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
  //  [spinner startAnimating];
    [self showProgressDialog];
   
    // If local ticket activation queue is populated,
    // continue running offline until CardSyncService is successful and ticketsQueue is empty
    NSFetchRequest *cardEventsFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *cardEventEntity = [NSEntityDescription entityForName:CARD_EVENT_MODEL
                                                       inManagedObjectContext:self.managedObjectContext];
    [cardEventsFetchRequest setEntity:cardEventEntity];
    
    NSError *error;
    NSArray *cardEvents = [self.managedObjectContext executeFetchRequest:cardEventsFetchRequest error:&error];
    
    if ([cardEvents count] == 0) {
        GetWalletActivity *getTicketService = [[GetWalletActivity alloc] initWithListener:self
                                                                     managedObjectContext:self.managedObjectContext];
        [getTicketService execute];
       
    }
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    
    [super viewDidUnload];
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
      [self dismissProgressDialog];
    if ([service isMemberOfClass:[GetTicketsService class]]) {
        [Utilities commitTickets:self.ticketSourceId managedObjectContext:self.managedObjectContext];
     }
    else if ([service isMemberOfClass:[GetWalletActivity class]]) {
         [self loadHistory1];
    }
  //  [spinner stopAnimating];

}

- (void)threadErrorWithClass:(id)service response:(id)response
{
      [self dismissProgressDialog];
   // [spinner stopAnimating];

}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1; //[ticketsDictionary.allKeys count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [ticketsDictionary.allKeys objectAtIndex:section];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ticketsDictionary.allKeys count]; //[[ticketsDictionary objectForKey:[ticketsDictionary.allKeys objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TicketHistoryCell";
    TicketHistoryCell *cell = (TicketHistoryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    WalletActivity *ticket = [[ticketsDictionary objectForKey:[ticketsDictionary.allKeys objectAtIndex:indexPath.row]] firstObject];
    productsListArray = [[NSMutableArray alloc]init];
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSNumber *cappedTicketid = [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_TICKETID"];
    NSNumber *bonusTicketid = [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_TICKETID"];
    
    for(int j = 0; j <ticketsDictionary.count ; j++){
        for (int i =0; i < totalProdcutArray.count; i++) {
            if([[[totalProdcutArray objectAtIndex:i] valueForKey:@"ticketId"] isEqual:[ticket ticketId]]) {
                
                [cell.noteLabel setText:[[totalProdcutArray objectAtIndex:i] valueForKey:@"productDescription"]];
            }
            
            else if(cappedTicketid!=nil && [[ticket ticketId] isEqualToNumber:cappedTicketid])
            {
                [cell.noteLabel setText:@"Capped"];
            }
            else if (bonusTicketid!=nil && [[ticket ticketId] isEqualToNumber:bonusTicketid]){
                [cell.noteLabel setText:@"Bonus"];
            }
        }
    }
    
    NSString *myString = [NSString stringWithFormat: @"%@ $%.2f",ticket.event,[ticket.amountCharged floatValue]];
    [cell.typeLabel setText:myString];
    [cell.noteLabel setText:@"Single Ride"];
    [cell.dateLabel setText:[ticketsDictionary.allKeys objectAtIndex:indexPath.row]];
    
    cell.backgroundColor = UIColor.clearColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    return ;
    Ticket *ticket = [[ticketsDictionary objectForKey:[ticketsDictionary.allKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    // Set selected ticket as "current" so that ticket views can safely query the ticket
    // from CoreData instead of relying on passed objects that can be nullified
    [Utilities setCurrentTicket:self.ticketSourceId
                  ticketGroupId:ticket.ticketGroupId
                       memberId:ticket.memberId
        firstActivationDateTime:[ticket.firstActivationDateTime doubleValue]
           managedObjectContext:self.managedObjectContext];
    
    TicketPageViewController *pageView = [[TicketPageViewController alloc] initWithNibName:@"TicketPageViewController" bundle:[NSBundle baseResourcesBundle]];
    [pageView setTicketSourceId:self.ticketSourceId];
    
    [pageView setManagedObjectContext:self.managedObjectContext];
    
    if (self.createCustomBarcodeViewController) {
        [pageView setCreateCustomBarcodeViewController:self.createCustomBarcodeViewController];
    }
    
    if (self.createCustomSecurityViewController) {
        [pageView setCreateCustomSecurityViewController:self.createCustomSecurityViewController];
    }
    
    [self.ticketsController.navigationController pushViewController:pageView animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - Other methods



-(void)loadHistory1{
    {
        if (emptyLabel != nil) {
            [emptyLabel setHidden:YES];
        }
        
        [ticketsDictionary removeAllObjects];
 
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:WALLET_ACTIVITY_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Sorting tickets from oldest to newest
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
        
        NSError *error;
        NSArray *tickets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
 
        
        
        // Load HISTORY tickets
        
        
        NSMutableArray *sortedHeaders = [[NSMutableArray alloc] init];
        
        // Get all ticket date headers
        for (WalletActivity *ticket in tickets) {
            NSTimeInterval timeInterval=[ticket.date doubleValue]/1000;
            NSDate *tdate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSString *datestr = [dateFormatter stringFromDate:tdate];
            
            [sortedHeaders addObject:datestr];
            
            
            NSMutableArray *ticketsForDate =  [ticketsDictionary objectForKey:datestr];
            if(ticketsForDate==nil){
                ticketsForDate=[[NSMutableArray alloc] init];
            }
            [ticketsForDate addObject:ticket];
             [ticketsDictionary setObject:ticketsForDate forKey:datestr];

         }
        
        
        
        
        
        if ([tickets count] == 0) {
            [self.tableView setHidden:YES];
            [emptyLabel setHidden:NO];
            if (emptyLabel == nil) {
                CGRect applicationFrame = [[UIScreen mainScreen] bounds];
                emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width - 20, 0)];
                [emptyLabel setText:[Utilities stringResourceForId:[Utilities noUsedTickets]]];
                [emptyLabel setTextAlignment:NSTextAlignmentCenter];
                [emptyLabel setFont:[UIFont systemFontOfSize:16]];
                [emptyLabel setNumberOfLines:0];
                [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [emptyLabel sizeToFit];
//                [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
//                                                  (applicationFrame.size.height / 2) - NAVIGATION_BAR_HEIGHT - 50)];
                [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                                  (self.view.frame.size.height / 2) - (emptyLabel.frame.size.height/2))];
                [self.view addSubview:emptyLabel];
            } else {}
        }else{
            [self.tableView setHidden:NO];
            [emptyLabel setHidden:YES];
        }
        
        [self.tableView reloadData];
    }
    
}

@end

