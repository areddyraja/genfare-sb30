//
//  TicketsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTA_AB_PassesViewController.h"
#import "AppConstants.h"
#import "CardEvent.h"
#import "GetEncryptionService.h"
#import "GetServiceDayService.h"
#import "GetTicketsService.h"
#import "GetTokensService.h"
#import "GetWalletsService.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Ticket.h"
#import "TicketCell.h"
#import "TicketHistoryViewController.h"
#import "TicketPageViewController.h"
#import "TicketPurchaseViewController.h"
#import "NewTicketPurchaseViewController.h"
#import "UIColor+HexString.h"
#import "Utilities.h"
#import "TicketsListViewController.h"
#import "GetWalletContents.h"
#import "WalletContents.h"
#import "GetProductsService.h"
#import "Product.h"
#import "GetWalletContentUsage.h"
#import "GetEncryptionKeysService.h"
#import "Singleton.h"
//#import "SignInViewController.h"
//#import "payas"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

NSString *const PASSES_PENDING_ACTIVE = @"pending_active";
NSString *const PASSES_PENDING_ACTIVATION = @"pending_activation";

@interface CDTA_AB_PassesViewController ()

@end

const int TICKET_IMAGE_TAG = 1;
const float TICKET_TIMEOUT = 10.0f;

@implementation CDTA_AB_PassesViewController
{
    UILabel *emptyLabel;
    NSMutableArray *activeTickets;
    NSMutableArray *inactiveTickets;
    NSString *documentsPath;
    UIAlertView *syncAlertView;
    NSTimer *timeoutTimer;
    TicketPageViewController *pageView;
    NSString *ticketSourceId;
    float firstCellHeight;
    NSArray *wallet_Contents;
    NSArray *totalProdcutArray;
    NSArray *ticketIdentifier;
    float ticketidValue;
    NSMutableArray  *ticketIdentifier1;
    NSMutableArray *wallet_Contents1;
    NSMutableDictionary *passesWithStatusDictionary;
    
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    activeTickets = [[NSMutableArray alloc] init];
    inactiveTickets = [[NSMutableArray alloc] init];
    documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                     stringByAppendingPathComponent:TICKET_IMAGES];
 
    passesWithStatusDictionary=[[NSMutableDictionary alloc] init];
    
//    [self getTicketsFromServer];
    
    /////
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTickets) name:@"updateTickets" object:nil];
    
    // Change title of back button on next screen
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"back"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"history"]
                                                                                style:UIBarButtonItemStyleBordered
                                                                               target:self
                                                                               action:@selector(goToHistory:)]];
    
    [_purchaseButtonProperties setTitle:[Utilities stringResourceForId:@"purchase_tickets"] forState:UIControlStateNormal];
    [_purchaseButtonProperties setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_purchaseButtonProperties setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]]];
    
    
    GetEncryptionService *encryptionService = [[GetEncryptionService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
    [encryptionService execute];
    //
    GetEncryptionKeysService *getEncryptionService = [[GetEncryptionKeysService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
    [getEncryptionService execute];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTickets) name:@"reloadTickets" object:nil];
    
}

-(void)refreshView {
    [self updateTickets];
}

-(void)updateTickets{
    [self getTicketsFromServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help My Tickets" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    [self fetchingWalletContentsFromDB];
    NSDate *date = [NSDate date];
    NSLog(@"Time: %f", floor([date timeIntervalSince1970] * 1000));
    NSLog(@"Time: %f", floor([date timeIntervalSince1970]));
    NSLog(@"Time: %lli", [@(floor([date timeIntervalSince1970] * 1000)) longLongValue]);
    NSLog(@"Time: %lli", [@(floor([date timeIntervalSince1970])) longLongValue]);
    
    
    
    
    
    ticketSourceId = [RuntimeData ticketSourceId:self.managedObjectContext];
    
    // Load local copy of tickets
    // [self loadTableData];
    
    // If local ticket activation queue is populated,
    // continue running offline until CardSyncService is successful and ticketsQueue is empty
    // NSArray *ticketsQueue = [StoredData ticketsQueue];
    NSFetchRequest *cardEventsFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *cardEventEntity = [NSEntityDescription entityForName:CARD_EVENT_MODEL
                                                       inManagedObjectContext:self.managedObjectContext];
    [cardEventsFetchRequest setEntity:cardEventEntity];
    
    NSError *error;
    NSArray *cardEvents = [self.managedObjectContext executeFetchRequest:cardEventsFetchRequest error:&error];
    
    if ([cardEvents count] == 0) {
        
        
//          [self getTickets];
        
    } else {
        if ([[RuntimeData ticketSourceId:self.managedObjectContext] isEqualToString:[Utilities deviceId]]) {
            TicketSyncService *syncService = [[TicketSyncService alloc] initWithContext:self.managedObjectContext];
            [syncService setListener:self];
            [syncService execute];
        } else {
            CardSyncService *cardSyncService = [[CardSyncService alloc] initWithContext:self.managedObjectContext];
            [cardSyncService setListener:self];
            [cardSyncService execute];
        }
    }
    
    // Reset ticket events
    [[RuntimeData instance] setTicketEvents:[NSArray new]];
    
    pageView = nil;

    self.view.backgroundColor = [UIColor colorWithHexString:@"#dadada"];
    self.tableView.backgroundColor = UIColor.clearColor;
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self updateTickets];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help My Tickets" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

-(void)reloadTickets{
    [self fetchingWalletContentsFromDB];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    
    if (syncAlertView) {
        [syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    if (timeoutTimer) {
        [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setTableView:nil];
}

#pragma mark - Background service declaration and callbacks
- (void)getTicketsFromServer{
    [self showProgressDialog];
     GetWalletContents *contents = [[GetWalletContents alloc]initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
    [contents execute];
    
    //        [NSTimer scheduledTimerWithTimeInterval:2.0
    //                                         target:self
    //                                       selector:@selector(fetchingWalletContentsFromDB)
    //                                       userInfo:nil
    //                                        repeats:nil];
    
}


-(void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
    if([service isMemberOfClass:[GetWalletContents class]]){
        
        [self fetchingWalletContentsFromDB];
     }
    
}
-(void)fetchingWalletContentsFromDB{
    NSFetchRequest *cardEventsFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *cardEventEntity = [NSEntityDescription entityForName:WALLET_CONTENT_MODEL
                                                       inManagedObjectContext:self.managedObjectContext];
    [cardEventsFetchRequest setEntity:cardEventEntity];
    
    NSError *error;
    wallet_Contents = [self.managedObjectContext executeFetchRequest:cardEventsFetchRequest error:&error];
    
    // wallet_Contents = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_CONTENTS"];
    
    
    ticketIdentifier1 = [[NSMutableArray alloc] init];
    for (int i =0; i < wallet_Contents.count; i++) {
        ticketIdentifier =  [[wallet_Contents objectAtIndex:i]valueForKey:@"ticketIdentifier"];
        if(ticketIdentifier)
            [ticketIdentifier1 addObject:ticketIdentifier];
        NSLog(@"%lu",(unsigned long)ticketIdentifier1.count);
        
    }
    [self FilteredPasses ];
    if (wallet_Contents1.count >0) {
        self.tableView.hidden=NO;
        emptyLabel.hidden=YES;
         [self.tableView reloadData];
    }
    else{
        self.tableView.hidden=YES;
        emptyLabel.hidden=NO;
    }
    
}


-(Product *)getPassAsYouGoTicketWithStoreValueFalse
{
    
    NSArray *fetchedObjects;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRODUCT_MODEL  inManagedObjectContext: context];
    [fetch setEntity:entityDescription];
    
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@) AND isActivationOnly == 0 ",@"Stored Value"]];
    NSError * error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count] >0)
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
    
}


-(NSArray *)getPassesFromWalletContent
{
    
    Product * storedValueFalseProduct = [self getPassAsYouGoTicketWithStoreValueFalse];
    
    
    NSArray *fetchedObjects;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:WALLET_CONTENT_MODEL  inManagedObjectContext: context];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ticketIdentifier != %@) or ticketSource ==%@" ,storedValueFalseProduct.ticketId,@"local"]];
    NSError * error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    
    return fetchedObjects;
    
}

/*
 -(void)PurchaseTickets{
 
 NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
 NSError *error = nil;
 totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
 if (totalProdcutArray.count >0) {
 NSMutableArray *filteredProdcutArray = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@) AND isActivationOnly == 0 ",@"Stored Value"] ];
 for (int i =0; i < filteredProdcutArray.count; i++) {
 [[NSUserDefaults standardUserDefaults]setObject:[[filteredProdcutArray objectAtIndex:i] valueForKey:@"ticketId"] forKey:@"ticketIdOfPayasyougo"];
 [[NSUserDefaults standardUserDefaults]synchronize];
 }
 NSUserDefaults *ticketIdOfPayasyougo = [NSUserDefaults standardUserDefaults];
 ticketidValue = [ticketIdOfPayasyougo floatForKey:@"ticketIdOfPayasyougo"];
 NSLog(@"%f",ticketidValue);
 }
 }
 
 */
-(void)FilteredPasses{
    
    wallet_Contents1= [[NSMutableArray alloc] initWithArray:[self getPassesFromWalletContent]];
    
    [passesWithStatusDictionary removeAllObjects];
    NSArray *distinctStatus;
    distinctStatus = [wallet_Contents1 valueForKeyPath:@"@distinctUnionOfObjects.status"];
    for (NSString *name in distinctStatus) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %@", name];
        NSArray *passes = [wallet_Contents1 filteredArrayUsingPredicate:predicate];
        NSMutableArray *new_ride_passes = [[NSMutableArray alloc] initWithArray:passes];

        //Remove expired passes except currently active
        for (int i=0; i<new_ride_passes.count; i++) {
            WalletContents *wc = new_ride_passes[i];
            long exptime = (long long)([[NSDate date] timeIntervalSince1970] );
            if(wc.ticketActivationExpiryDate.doubleValue<exptime && wc.valueRemaining.integerValue <= 0){
                [new_ride_passes removeObject:wc];
                i--;
            }
        }

        [passesWithStatusDictionary setObject:new_ride_passes forKey:name];
    }
    
    
    for(NSString *key in passesWithStatusDictionary.allKeys){
        NSArray *wArray=passesWithStatusDictionary[key];
        NSLog(@"staus key ----- %@",key);
        NSMutableArray *tempWalletArray = [[NSMutableArray alloc] initWithArray:wArray];
        for(WalletContents *wallet in wArray){
            if([wallet.status isEqualToString:ACTIVE]&&wallet.instanceCount.integerValue>0){
                
                NSArray *wArray=passesWithStatusDictionary[PASSES_PENDING_ACTIVATION];
                NSMutableArray *ptempWalletArray = [[NSMutableArray alloc] initWithArray:wArray];
                for (int i=0;i<wallet.instanceCount.integerValue;i++){
                    WalletContents *pWallet=[wallet duplicateUnassociated];
                    pWallet.allowInteraction=[NSNumber numberWithBool:NO];
                    pWallet.status=PASSES_PENDING_ACTIVATION;
                    [ptempWalletArray addObject:pWallet];
                }
                [passesWithStatusDictionary removeObjectForKey:PASSES_PENDING_ACTIVATION];
                [passesWithStatusDictionary setObject:ptempWalletArray forKey:PASSES_PENDING_ACTIVATION];
                
            }
            else if(![wallet.status isEqualToString:ACTIVE]&&wallet.instanceCount.integerValue>0){
                for (int i=0;i<wallet.instanceCount.integerValue;i++){
                    WalletContents *pWallet=[wallet duplicateUnassociated];
                    pWallet.allowInteraction=[NSNumber numberWithBool:YES];
                    [tempWalletArray addObject:pWallet];
                }
                [passesWithStatusDictionary removeObjectForKey:key];
                [passesWithStatusDictionary setObject:tempWalletArray forKey:key];
            }
        }
        
    }
    if(passesWithStatusDictionary.count==0){
        
        
        if (emptyLabel == nil) {
            CGRect applicationFrame = [[UIScreen mainScreen] bounds];
            
            emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH - 40, 100)];
            [emptyLabel setText:[Utilities stringResourceForId:[Utilities noPassesAlert]]];
//            NSString *tenantId = [Utilities tenantId];
//            if ([tenantId isEqualToString:@"COTA"]) {
//                [emptyLabel setText:[Utilities noPassesAlert]];
////                [emptyLabel setText:@"This tab shows the activated passes. No Passes are activated."];
//            }else if ([tenantId isEqualToString:@"CDTA"]){
//                [emptyLabel setText:[Utilities noPassesAlert]];
////                [emptyLabel setText:[NSString stringWithFormat:@"%@ \n\nTap on the Purchase Passes button to make new purchases with your mobile card.",[Utilities stringResourceForId:@"tickets_quick_start"]]];
////                [emptyLabel setText:[NSString stringWithFormat:@"%@ \nNo Passes are activated.",[Utilities stringResourceForId:@"tickets_quick_start"]]];
//            }else{}
//            [emptyLabel setText:[Utilities noPassesAlert]];
            [emptyLabel setTextAlignment:NSTextAlignmentLeft];
            [emptyLabel setFont:[UIFont fontWithName:@"Avenir Next Medium" size:20]];
            [emptyLabel setNumberOfLines:0];
            [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [emptyLabel sizeToFit];
            [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                              (applicationFrame.size.height / 6)  // - NAVIGATION_BAR_HEIGHT
                                              )];
//            [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
//                                              (self.view.frame.size.height / 2) - (emptyLabel.frame.size.height/2))];
            [emptyLabel setHidden:NO];
            emptyLabel.font = [UIFont fontWithName:@"Montserrat" size:15];
            
        }
        
        [self.view addSubview:emptyLabel];
        
        [self.tableView setHidden:YES];
    }
    else{
        if (emptyLabel ){
            emptyLabel.hidden=YES;
        }
        
        
        NSMutableArray *activetickets=[passesWithStatusDictionary objectForKey:ACTIVE];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticketSource = %@", @"local"];
        NSArray *passesasyou = [activetickets filteredArrayUsingPredicate:predicate];
        
        NSPredicate *periodPassesPredicate = [NSPredicate predicateWithFormat:@"ticketSource != %@", @"local"];
        NSArray *periodPasses = [activetickets filteredArrayUsingPredicate:periodPassesPredicate];
        
        NSMutableArray *activeticketMutable=[[NSMutableArray alloc] initWithArray:activetickets];
        for(WalletContents *wc in passesasyou){
            long exptime = (long long)([[NSDate date] timeIntervalSince1970] );
            if(wc.ticketActivationExpiryDate.doubleValue<exptime){
                [activeticketMutable removeObject:wc];
            }
        }
        
        for(WalletContents *wc in periodPasses){
            long exptime = (long long)([[NSDate date] timeIntervalSince1970] );//if it’s High Expired
            long expirationDate = (long long)([[Utilities dateFromUTCString:wc.expirationDate] timeIntervalSince1970] );//if it’s High Valid
            long expirationDateFromCurrentDate = (long long)([[Utilities getExpirationDateFromCurrentDate:wc] timeIntervalSince1970] );//if it’s High Valid
            if(expirationDate<exptime && [wc.instanceCount intValue] == 0){
                [activeticketMutable removeObject:wc];
                wc.activationCount = 0;
                wc.expirationDate = nil;
                wc.activationDate = nil;
            }else if([wc.status isEqualToString:@"active"] && expirationDate<exptime && [wc.instanceCount intValue] > 0){
                wc.expirationDate = nil;
                wc.activationDate = nil;
                wc.status = PENDING_ACTIVATION;
                wc.instanceCount = [NSNumber numberWithInt:wc.instanceCount.intValue - 1];
                wc.activationCount = 0;
                wc.ticketActivationExpiryDate = nil;
            }else if ([wc.status isEqualToString:@"active"] && expirationDateFromCurrentDate<expirationDate && [wc.instanceCount intValue] > 0){
                //wc.ticketActivationExpiryDate = nil;
            }
        }
        
        [passesWithStatusDictionary removeObjectForKey:ACTIVE];
        if(activeticketMutable.count >0){
            [passesWithStatusDictionary setObject:activeticketMutable forKey:ACTIVE];
        }
        NSError *error1;
        if (![self.managedObjectContext  save:&error1]) {
            NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
        }
        [self.tableView setHidden:NO];
//        [self.tableView reloadData];
        
        
    }
    [self.tableView reloadData];
    
    //    ;
    //   // wallet_Contents3= [[NSMutableArray alloc] init];
    //    for (int i =0; i < ticketIdentifier1.count; i++) {
    //        if(!([[ticketIdentifier1 objectAtIndex:i] floatValue] == ticketidValue)){
    //        NSMutableArray *wallet_Contents2 = [wallet_Contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketIdentifier== %@) ",[ticketIdentifier1 objectAtIndex:i]] ];
    //        [wallet_Contents1 addObjectsFromArray:wallet_Contents2];
    //        }
    //        else{
    //             NSMutableArray *wallet_Contents4 = [wallet_Contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketIdentifier== %@) ",[ticketIdentifier1 objectAtIndex:i]] ];
    //
    //            [[NSUserDefaults standardUserDefaults]setObject:[[wallet_Contents objectAtIndex:i] valueForKey:@"balance"] forKey:@"balancePayasyougo"];
    //            [[NSUserDefaults standardUserDefaults]synchronize];
    //        }
    //   }
    //
    
    
}

- (NSArray *)generateSortedPassesList {
    NSMutableArray *activePassList = [[NSMutableArray alloc] init];
    NSMutableArray *sortedFullArray = [[NSMutableArray alloc] initWithArray:[self getFullListArray]];
    NSMutableArray *inActivePeriodPasses = [[NSMutableArray alloc] init];

    NSDate *now = [NSDate date];
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    
    for (int i=0; i<sortedFullArray.count; i++) {
        WalletContents *wc = sortedFullArray[i];
        NSInteger remainingActiveTime = wc.ticketActivationExpiryDate.longLongValue-epochSecondsDecimals;
        if ([wc.status isEqualToString:@"active"] && remainingActiveTime > 0) {
            [activePassList addObject:wc];
        }
    }
    
    for (int i=0; i<sortedFullArray.count; i++) {
        WalletContents *wc = sortedFullArray[i];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *exDate = [df dateFromString:[wc valueForKey:@"expirationDate"]];
        NSNumber *dateNum = [NSNumber numberWithLong:[exDate timeIntervalSince1970]];
        
        NSInteger remainingActiveTime = [dateNum longValue] - epochSecondsDecimals;
        if ([wc.status isEqualToString:@"active"] && remainingActiveTime <= 0) {
            [inActivePeriodPasses addObject:wc];
        }
    }

    
    [sortedFullArray removeObjectsInArray:activePassList];
    [sortedFullArray removeObjectsInArray:inActivePeriodPasses];

    [activePassList addObjectsFromArray:sortedFullArray];
    
    return activePassList;
}

- (NSArray *)getFullListArray {
    NSMutableArray *fullArray = [[NSMutableArray alloc] init];
    NSArray *sortedArray = [passesWithStatusDictionary.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (int i=0; i<passesWithStatusDictionary.allKeys.count; i++) {
        [fullArray addObjectsFromArray:[passesWithStatusDictionary objectForKey:[sortedArray objectAtIndex:i]]];
    }
    
    return fullArray;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; //passesWithStatusDictionary.allKeys.count;
}


-(WalletContents*) copyWallet:(WalletContents*)actualWallet
{
    WalletContents *copy = [[WalletContents  alloc] init];
    
    [copy setIdentifier: actualWallet.identifier];
    [copy setValueRemaining: actualWallet.valueRemaining];
    [copy setValueOriginal: actualWallet.valueOriginal];
    [copy setType: actualWallet.type];
    [copy setTicketGroup: actualWallet.ticketGroup];
    [copy setTicketExpiryDate: actualWallet.ticketExpiryDate];
    [copy setTicketEffectiveDate: actualWallet.ticketEffectiveDate];
    [copy setStatus: actualWallet.status];
    [copy setSlot: actualWallet.slot];
    [copy setPurchasedDate: actualWallet.purchasedDate];
    [copy setMember: actualWallet.member];
    [copy setInstanceCount: actualWallet.instanceCount];
    [copy setGroup: actualWallet.group];
    [copy setFare: actualWallet.fare];
    [copy setDesignator:actualWallet.designator];
    [copy setDescriptation: actualWallet.descriptation];
    [copy setBalance: actualWallet.balance];
    [copy setAgencyId:actualWallet.agencyId];
    [copy setAllowInteraction: actualWallet.allowInteraction];
    
    return copy;
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getFullListArray].count;
}

-(UIColor *)colorFromHexString:(NSString *)hexString {
    if(!hexString)
        return nil;
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TicketCell";
    TicketCell *cell = (TicketCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSArray *particularStatusArray = [self generateSortedPassesList];
    
    cell.timeRemainingLabel.hidden = YES;
    cell.dateLabel.hidden = YES;

    WalletContents *wc = particularStatusArray[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy hh:mm aa"];
    UIColor *activationColor = [self colorFromHexString:@"#669342"];
    NSMutableAttributedString *activationCountMutStr;
    NSMutableAttributedString *activationsMutStr;
    UIColor *activationColor1 = [self colorFromHexString:@"#959595"];
    NSDate *expiryDate = [NSDate dateWithTimeIntervalSince1970:[wc.ticketExpiryDate doubleValue]];

    NSDate *validDate = [NSDate dateWithTimeIntervalSince1970:[wc.purchasedDate doubleValue]/1000];
    activationsMutStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"\nActivation"] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11.0],  NSForegroundColorAttributeName:activationColor1}];
    
    [cell.dateLabel setText:[NSString stringWithFormat:@"Expires %@", [dateFormatter stringFromDate:validDate]]];
    [cell.noteLabel setText:wc.descriptation];
    if([wc.type isEqualToString:@"1"]){
        wc.type = @"Single ride";
    }
    NSString *typeString = [wc.type stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    typeString = [Utilities capitalizedOnlyFirstLetter:typeString];
    [cell.zoneLabel setText:wc.descriptation];
    cell.activeBtn.hidden = YES;
    cell.inActiveBtn.hidden = YES;
    cell.activeRideBtn.hidden = YES;

    if([wc.status  isEqual: @"pending_activation"]){
        cell.inActiveBtn.hidden = NO;

        if(wc.allowInteraction.boolValue==NO){
            [cell.icon setImage:[UIImage loadOverrideImageNamed:@"ic_ticket_pending"]];
        }
        else{
            [cell.icon setImage:[UIImage loadOverrideImageNamed:@"ic_ticket_inactive"]];
            
        }
        activationCountMutStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"0"] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:23],  NSForegroundColorAttributeName:activationColor}];
        [activationCountMutStr appendAttributedString:activationsMutStr];
        
        [cell.activationsLabel setAttributedText:activationCountMutStr];
        
    }else if ([wc.status  isEqual: @"active"])
    {
        [cell.icon setImage:[UIImage loadOverrideImageNamed:@"ic_ticket_active"]];
        NSDate *now = [NSDate date];
        NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
        NSInteger remainingActiveTime = wc.ticketActivationExpiryDate.longLongValue-epochSecondsDecimals;
        
        if (remainingActiveTime > 0) {
            cell.activeRideBtn.hidden = NO;
        }else{
            cell.activeBtn.hidden = NO;
        }
        if([wc.type isEqualToString:@"stored_ride"]){
            activationCountMutStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@",wc.valueRemaining.stringValue] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:23],  NSForegroundColorAttributeName:activationColor}];
            cell.timeRemainingLabel.hidden = NO;
            cell.timeRemainingLabel.text = [NSString stringWithFormat:@"%@ Rides",wc.valueRemaining];
        }else{
            activationCountMutStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@",[wc.ticketSource isEqualToString:@"local"]?@"1/1": wc.activationCount.stringValue] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:23],  NSForegroundColorAttributeName:activationColor}];
            [activationCountMutStr appendAttributedString:activationsMutStr];
            
            [cell.activationsLabel setAttributedText:activationCountMutStr];
            
            cell.timeRemainingLabel.hidden = NO;

            NSDate *expDate = [NSDate dateWithTimeIntervalSince1970:wc.ticketExpiryDate.doubleValue];
            
            NSCalendar *grCalender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [grCalender components:NSCalendarUnitDay fromDate:now toDate:expDate options:0];
            NSInteger remainingDays = [components day];
            
            if (remainingDays < 0) {
                remainingDays = [wc.valueRemaining integerValue];
            }
            
            if (remainingDays == 1) {
                cell.timeRemainingLabel.text = [NSString stringWithFormat:@"%ld Day",(long)remainingDays];
            }else{
                cell.timeRemainingLabel.text = [NSString stringWithFormat:@"%ld Days",(long)remainingDays];
            }
            
            cell.dateLabel.hidden = NO;
            
            if ([wc.ticketExpiryDate longValue] > 0) {
                [cell.dateLabel setText:[NSString stringWithFormat:@"Expires %@", [dateFormatter stringFromDate:expiryDate]]];
            }else{
                [cell.dateLabel setText:@""];
            }
        }

    }
    else{
        [cell.icon setImage:[UIImage loadOverrideImageNamed:@"ic_ticket_inactive"]];
        activationCountMutStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%li",wc.activationCount.integerValue] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:23],  NSForegroundColorAttributeName:activationColor}];
        [activationCountMutStr appendAttributedString:activationsMutStr];
        
        [cell.activationsLabel setAttributedText:activationCountMutStr];
        
    }
    
    [cell.descriptionLabel setText:[NSString stringWithFormat:@"Fare: $ %.2f",[wc.fare floatValue]]];
    cell.backgroundColor = UIColor.clearColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *passList = [self generateSortedPassesList];
    
    if (passList.count <= 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [tableView reloadData];
        return;
    }

    WalletContents *wc = passList[indexPath.row];

    
    if(wc.allowInteraction.boolValue==false){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return ;
    }
    
     id walletContentUsageIdentifier =wc.identifier;
   
    
    
    
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970]);
    
    
    if(wc.purchasedDate.stringValue.length==0||wc.purchasedDate==nil){
        wc.purchasedDate=[NSNumber numberWithLong:milliseconds];
    }
    NSDate *now = [NSDate date];
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    NSInteger remainingActiveTime = wc.ticketActivationExpiryDate.longLongValue-epochSecondsDecimals;
    
    if ([wc.type isEqualToString:@"stored_ride"] && remainingActiveTime <= 0 && wc.valueRemaining.integerValue <= 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self reloadTickets];
        return;
    }

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *exDate = [df dateFromString:wc.expirationDate];

    if ([wc.type isEqualToString:@"period_pass"] && [wc.status isEqualToString:ACTIVE] && remainingActiveTime <= 0 && [now compare:exDate] == NSOrderedDescending) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self reloadTickets];
        return;
    }

    // long exptime = (long long)([[NSDate date] timeIntervalSince1970] );
    if(remainingActiveTime<=0 && [wc.ticketSource isEqualToString:@"local"]){
        NSLog(@"expired");
        [self reloadTickets];
    }
    else{
        pageView = [[TicketPageViewController alloc] initWithNibName:@"TicketPageViewController" bundle:[NSBundle baseResourcesBundle]];
        [pageView setTicketSourceId:ticketSourceId];
        [pageView setWalletContent:wc];
        [pageView setManagedObjectContext:self.managedObjectContext];
        if ([self.cardAccountId length] > 0) {
            [pageView setCardAccountId:self.cardAccountId];
        }
        
        
        
        
        [[[Singleton sharedManager]currentNVC] pushViewController:pageView animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)threadErrorWithClass:(id)service response:(id)response
{
    [super threadErrorWithClass:service response:response];
    [self dismissProgressDialog];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - View controls



- (IBAction)purchaseButton:(id)sender
{
    TicketsListViewController *ticketview = [[TicketsListViewController alloc]initWithNibName:@"TicketsListViewController" bundle:nil];
    [ticketview setManagedObjectContext:self.managedObjectContext];
    
    [self.ticketsController.navigationController pushViewController:ticketview animated:YES];
    
    
}

#pragma mark - Other methods

- (void)loadTableData
{
    if (emptyLabel != nil) {
        [emptyLabel setHidden:YES];
    }
    
    [activeTickets removeAllObjects];
    [inactiveTickets removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TICKET_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceId == %@ AND (type == %@ OR type == %@) AND isStaging == %@",
                              ticketSourceId, ACTIVE, INACTIVE, [NSNumber numberWithBool:NO]];
    [fetchRequest setPredicate:predicate];
    
    // Sorting tickets from oldest to newest
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"purchaseDateTime" ascending:YES];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    
    NSError *error;
    NSArray *tickets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSDate *currentDate = [NSDate date];
    
    for (Ticket *ticket in tickets) {
        [ticket evaluateState:currentDate];
        
 
        if ([ticket.type isEqualToString:ACTIVE] || [[ticket.status substringToIndex:9] isEqualToString:@"Activated"]) {
            [activeTickets addObject:ticket];
        }
        
        else if ([ticket.type isEqualToString:INACTIVE]) {
            [inactiveTickets addObject:ticket];
        }
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)dismissAlert
{
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    
    [syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end

