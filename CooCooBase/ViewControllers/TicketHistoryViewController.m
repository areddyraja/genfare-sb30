//
//  TicketHistoryViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TicketHistoryViewController.h"
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

@interface TicketHistoryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;

@end

@implementation TicketHistoryViewController
{
  //  UIActivityIndicatorView *spinner;
    NSMutableDictionary *ticketsDictionary;
    NSMutableArray *headers;
    NSDateFormatter *dateFormatter;
     NSArray *totalProdcutArray;
    NSMutableArray *productsListArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:[Utilities historyTitle]]];
        
      //  spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        ticketsDictionary = [[NSMutableDictionary alloc] init];
        headers = [[NSMutableArray alloc] init];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/YY       hh:mm aa"];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GetWalletActivity *getTicketService = [[GetWalletActivity alloc] initWithListener:self
                                                                 managedObjectContext:self.managedObjectContext];
    [getTicketService execute];
    
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

 //   [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
  //  [spinner startAnimating];
    
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
//        GetTicketsService *getTicketService = [[GetTicketsService alloc] initWithListener:self
//                                                                     managedObjectContext:self.managedObjectContext];
//        [getTicketService execute];
    }
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
        totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket History" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    [self loadHistory1];
    self.view.backgroundColor = UIColor.clearColor;
    self.tableView.backgroundColor = UIColor.clearColor;

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    CGRect tableFrame = self.view.frame;
    tableFrame.size.height += 44.0f; //Here 50 is adding for the Pagmenu Height.
    self.view.frame = tableFrame;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    
    [super viewDidUnload];
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetTicketsService class]]) {
        [Utilities commitTickets:self.ticketSourceId managedObjectContext:self.managedObjectContext];
        [self loadHistory1];
    }
   else if ([service isMemberOfClass:[GetWalletActivity class]]) {
     //   [Utilities commitTickets:self.ticketSourceId managedObjectContext:self.managedObjectContext];
        [self loadHistory1];
   }
   // [spinner stopAnimating];
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
   // [spinner stopAnimating];
    [self dismissProgressDialog];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; //[headers count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [headers objectAtIndex:section];
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//
//    return 35.0f;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//    [header.textLabel setTextColor:[UIColor whiteColor]];
//
//    header.contentView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:120.0/255.0 blue:185.0/255.0 alpha:1.0];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ticketsDictionary.allKeys count]; //return [[ticketsDictionary objectForKey:[headers objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    //[cell.noteLabel setText:ticket.event];
    [cell.dateLabel setText:[ticketsDictionary.allKeys objectAtIndex:indexPath.row]];
    
    cell.backgroundColor = UIColor.clearColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    return ;
    
    Ticket *ticket = [[ticketsDictionary objectForKey:[headers objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
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
-(void)loadHistory{
    {
        self.emptyListLabel.hidden = YES;
        [ticketsDictionary removeAllObjects];
        [headers removeAllObjects];
   
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:WALLET_ACTIVITY_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Sorting tickets from oldest to newest
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
        
        NSError *error;
        NSArray *tickets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if ([tickets count] == 0) {
            [self.tableView setHidden:YES];
            [self.emptyListLabel setHidden:NO];
            [self.emptyListLabel setText:[Utilities stringResourceForId:[Utilities noUsedTickets]]];
        }else{
            [self.tableView setHidden:NO];
            [self.emptyListLabel setHidden:YES];
        }
        
        int nowEpochTime = [[NSDate date] timeIntervalSince1970];
        
        for (WalletActivity *ticket in tickets) {
            int expirationEpochTime = [ticket.date doubleValue];
            
        }
        
        // Load HISTORY tickets
        
        fetchRequest = [[NSFetchRequest alloc] init];
        entity = [NSEntityDescription entityForName:WALLET_ACTIVITY_MODEL
                             inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
      sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
        
        tickets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        NSMutableArray *ticketDates = [[NSMutableArray alloc] init];
        
        // Get all ticket date headers
        for (WalletActivity *ticket in tickets) {
            NSTimeInterval timeInterval=[ticket.date doubleValue]/1000;
            [ticketDates addObject:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
          // [ticketDates addObject:[NSDate dateWithTimeIntervalSince1970:[ticket.date doubleValue]]];
           // [[ticketDates addObject:[NSDate [ticket.date]];
        }
        
        NSArray *sortedHeaderDates = ticketDates ;
        
        NSMutableArray *sortedHeaders = [[NSMutableArray alloc] init];
        for (NSDate *date in sortedHeaderDates) {
            NSString *dateString = [dateFormatter stringFromDate:date];
            
            [sortedHeaders addObject:dateString];
        }
        
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:sortedHeaders];
        NSSet *uniqueHeaders = [orderedSet set];
        
        for (NSString *uniqueHeader in uniqueHeaders) {
            [headers addObject:uniqueHeader];
            
            NSMutableArray *ticketsForDate = [[NSMutableArray alloc] init];
            
            for (WalletActivity *ticket in tickets) {
                 NSTimeInterval timeInterval=[ticket.date doubleValue]/1000;
                NSString *dateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
                
                if ([dateString isEqualToString:uniqueHeader]) {
                    [ticketsForDate addObject:ticket];
                }
            }
            
            [ticketsDictionary setObject:[ticketsForDate copy] forKey:uniqueHeader];
        }
        

        [self.tableView reloadData];
    }

}

-(void)loadHistory1{
    {
        self.emptyListLabel.hidden = YES;
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
            [self.emptyListLabel setHidden:NO];
            [self.emptyListLabel setText:[Utilities stringResourceForId:[Utilities noUsedTickets]]];
        }else{
            [self.tableView setHidden:NO];
            [self.emptyListLabel setHidden:YES];
        }
        
        [self.tableView reloadData];
    }
    
}

@end
