//
//  TicketsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TicketsViewController.h"
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
//#import "SignInViewController.h"
#import "WalletContent.h"
#import "Wallet.h"
#import "AppConstants.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

NSString *const PENDING_ACTIVE = @"pending_active";

@interface TicketsViewController ()<CAPSPageMenuDelegate>{

}
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;
@property (nonatomic) CAPSPageMenu *pagemenu;
@end

const int TICKET_IMAGE_TAG = 1;
const float TICKET_TIMEOUT = 10.0f;
@implementation TicketsViewController
{
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
    NSMutableArray *wallet_Contents1;
    NSMutableDictionary *passesWithStatusDictionary;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"my_tickets"]];
        
        activeTickets = [[NSMutableArray alloc] init];
        inactiveTickets = [[NSMutableArray alloc] init];
        documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                         stringByAppendingPathComponent:TICKET_IMAGES];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    passesWithStatusDictionary=[[NSMutableDictionary alloc] init];
    
    [self getTicketsFromServer];
    
    /////
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTickets) name:@"updateTickets" object:nil];
    
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
    [super viewWillAppear:animated];
    
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
        
        
        //  [self getTickets];
        
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
    [self updateUiBasedOnWalletState];
    
    self.view.backgroundColor = UIColor.clearColor;
    self.tableView.backgroundColor = UIColor.clearColor;
    
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
        [_purchaseButtonProperties setUserInteractionEnabled:NO];
        [_purchaseButtonProperties setBackgroundColor:[UIColor lightGrayColor]];
    }else{
        NSLog(@"Active");
        [_purchaseButtonProperties setUserInteractionEnabled:YES];
        [_purchaseButtonProperties setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]]];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    
    //[super viewDidAppear:animated];
    id obj =self.parentViewController;
    
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
}


-(void)threadSuccessWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    if([service isMemberOfClass:[GetWalletContents class]]){
        
        [self fetchingWalletContentsFromDB];
        [self dismissProgressDialog];
    }
    
}
- (void)threadErrorWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
}
-(void)fetchingWalletContentsFromDB{
    NSFetchRequest *cardEventsFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *cardEventEntity = [NSEntityDescription entityForName:WALLET_CONTENT_MODEL
                                                       inManagedObjectContext:self.managedObjectContext];
    [cardEventsFetchRequest setEntity:cardEventEntity];
    
    NSError *error;
    wallet_Contents = [self.managedObjectContext executeFetchRequest:cardEventsFetchRequest error:&error];
    // wallet_Contents = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_CONTENTS"];
    [self FilteredPasses ];
    if (wallet_Contents1.count >0) {
        self.tableView.hidden=NO;
        self.emptyListLabel.hidden=YES;
        [self dismissProgressDialog];
        [self.tableView reloadData];
    }
    else{
        self.tableView.hidden=YES;
        self.emptyListLabel.hidden=NO;
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
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(type != %@ AND type != %@ AND ticketIdentifier != %@) or ticketSource ==%@",@"stored_value",@"Stored Value",storedValueFalseProduct.ticketId,@"local"]];
    // [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ticketIdentifier != %@) or ticketSource ==%@" ,storedValueFalseProduct.ticketId,@"local"]];
    NSError * error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    
    return fetchedObjects;
    
}

-(void)FilteredPasses{
    
    
    
    wallet_Contents1= [[NSMutableArray alloc] initWithArray:[self getPassesFromWalletContent]];
    
    [passesWithStatusDictionary removeAllObjects];
    NSArray *distinctStatus;
    distinctStatus = [wallet_Contents1 valueForKeyPath:@"@distinctUnionOfObjects.status"];
    for (NSString *name in distinctStatus) {
        
        //   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status = %@ AND valueRemaining > %d", name,0];
        NSPredicate *stored_ride_passes_predicate = [NSPredicate predicateWithFormat:@"status == %@ AND valueRemaining >= %d AND type == %@", name,0,@"stored_ride"];
        NSArray *stored_ride_passes = [wallet_Contents1 filteredArrayUsingPredicate:stored_ride_passes_predicate];
        NSMutableArray *new_ride_passes = [[NSMutableArray alloc] initWithArray:stored_ride_passes];
        
        //Remove expired passes except currently active
        for (int i=0; i<new_ride_passes.count; i++) {
            WalletContents *wc = new_ride_passes[i];
            long exptime = (long long)([[NSDate date] timeIntervalSince1970] );
            if(wc.ticketActivationExpiryDate.doubleValue<exptime && wc.valueRemaining.integerValue <= 0){
                [new_ride_passes removeObject:wc];
                i--;
            }
        }
        
        NSPredicate *passes_predicate = [NSPredicate predicateWithFormat:@"status == %@ AND type == %@", name,@"period_pass"];
        NSArray * passes = [wallet_Contents1 filteredArrayUsingPredicate:passes_predicate];
        
        
        NSPredicate *localpasses_predicate = [NSPredicate predicateWithFormat:@"status == %@ AND ticketSource == %@", name,@"local"];
        NSArray * localpasses = [wallet_Contents1 filteredArrayUsingPredicate:localpasses_predicate];
        
        
        
        
        
        NSMutableArray *myPasses = [[NSMutableArray alloc] initWithArray:passes];
        [myPasses addObjectsFromArray:new_ride_passes];
        [myPasses addObjectsFromArray:localpasses];
        [passesWithStatusDictionary setObject:myPasses forKey:name];
    }
    
    
    for(NSString *key in passesWithStatusDictionary.allKeys){
        NSArray *wArray=passesWithStatusDictionary[key];
        NSLog(@"staus key ----- %@",key);
        NSMutableArray *tempWalletArray = [[NSMutableArray alloc] initWithArray:wArray];
        for(WalletContents *wallet in wArray){
            if([wallet.status isEqualToString:ACTIVE]&&wallet.instanceCount.integerValue>0){
                
                NSArray *wArray=passesWithStatusDictionary[PENDING_ACTIVATION];
                NSMutableArray *ptempWalletArray = [[NSMutableArray alloc] initWithArray:wArray];
                for (int i=0;i<wallet.instanceCount.integerValue;i++){
                    WalletContents *pWallet=[wallet duplicateUnassociated];
                    pWallet.allowInteraction=[NSNumber numberWithBool:NO];
                    pWallet.status=PENDING_ACTIVATION;
                    [ptempWalletArray addObject:pWallet];
                }
                [passesWithStatusDictionary removeObjectForKey:PENDING_ACTIVATION];
                [passesWithStatusDictionary setObject:ptempWalletArray forKey:PENDING_ACTIVATION];
                
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
        [self.tableView setHidden:YES];
        [self.emptyListLabel setHidden:NO];
        [self.emptyListLabel setText:[Utilities stringResourceForId:[Utilities noPassesAlert]]];
    }else{
        [self.tableView setHidden:NO];
        [self.emptyListLabel setHidden:YES];
        NSMutableArray *activetickets=[passesWithStatusDictionary objectForKey:ACTIVE];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticketSource = %@", @"local"];
        NSArray *passesasyou = [activetickets filteredArrayUsingPredicate:predicate];
        NSMutableArray *activeticketMutable=[[NSMutableArray alloc] initWithArray:activetickets];
        for(WalletContents *wc in passesasyou){
            long exptime = (long long)([[NSDate date] timeIntervalSince1970] );
            if(wc.ticketActivationExpiryDate.doubleValue<exptime){
                [activeticketMutable removeObject:wc];
            }
        }
        [passesWithStatusDictionary removeObjectForKey:ACTIVE];
        if(activeticketMutable.count >0){
            [passesWithStatusDictionary setObject:activeticketMutable forKey:ACTIVE];
        }
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    }
}

- (NSArray *)generateSortedPassesList {
    NSMutableArray *activePassList = [[NSMutableArray alloc] init];
    NSMutableArray *inActivePeriodPasses = [[NSMutableArray alloc] init];
    
    NSMutableArray *sortedFullArray = [[NSMutableArray alloc] initWithArray:[self getFullListArray]];
    
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
        if ([wc.status isEqualToString:@"active"] && remainingActiveTime <= 0 && wc.expirationDate != nil) {
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
    return 1; //return passesWithStatusDictionary.allKeys.count;
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

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
    
    UIView *vi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    UILabel *lblSectionName = [[UILabel alloc] initWithFrame:CGRectMake(10, -15, self.view.frame.size.width-20, 50)];
    [lblSectionName setTextColor:[UIColor whiteColor]];
    lblSectionName.font = [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
    [vi addSubview:lblSectionName];
    [vi setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities tableViewHeaderBGColor]]]];
    NSString *sectionName;
    NSArray *sortedArray = [passesWithStatusDictionary.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    NSString *status = [sortedArray objectAtIndex:section];
    // NSString *status = [passesWithStatusDictionary.allKeys objectAtIndex:section];
    status = [NSString stringWithFormat:@"%@%@",[[status substringToIndex:1] uppercaseString],[status substringFromIndex:1]];
    //  [lblSectionName setText:[passesWithStatusDictionary.allKeys objectAtIndex:section]];
    if([status  isEqual:@"Pending_activation"])
    {
        lblSectionName.text = @"Ready";
    }else{
        lblSectionName.text = status;
    }
    return vi;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self generateSortedPassesList].count;
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
    if([wc.type isEqualToString:@"stored_ride"]){
        activationsMutStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"\nRemaining"] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11.0],  NSForegroundColorAttributeName:activationColor1}];
    }else{
        activationsMutStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"\nActivation"] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11.0],  NSForegroundColorAttributeName:activationColor1}];
    }
    
    [cell.noteLabel setText:wc.descriptation];
    
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
        }
        else{
            activationCountMutStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@",[wc.ticketSource isEqualToString:@"local"]?@"1/1": wc.activationCount.stringValue] attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:23],  NSForegroundColorAttributeName:activationColor}];
            
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
        
        [activationCountMutStr appendAttributedString:activationsMutStr];
        [cell.activationsLabel setAttributedText:activationCountMutStr];

    }
    else{
        [cell.icon setImage:[UIImage loadOverrideImageNamed:@"ic_ticket_inactive"]];
        cell.activeBtn.hidden = NO;
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

    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970]  );
    
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
        
        
        if (self.createCustomBarcodeViewController) {
            [pageView setCreateCustomBarcodeViewController:self.createCustomBarcodeViewController];
        }
        
        if (self.createCustomSecurityViewController) {
            [pageView setCreateCustomSecurityViewController:self.createCustomSecurityViewController];
        }
        
        [self.ticketsController.navigationController pushViewController:pageView animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - View controls

- (void)goToHistory:(id)sender
{
    TicketHistoryViewController *historyView = [[TicketHistoryViewController alloc] initWithNibName:@"TicketHistoryViewController" bundle:nil];
    [historyView setManagedObjectContext:self.managedObjectContext];
    
    if (self.createCustomBarcodeViewController) {
        [historyView setCreateCustomBarcodeViewController:self.createCustomBarcodeViewController];
    }
    
    if (self.createCustomSecurityViewController) {
        [historyView setCreateCustomSecurityViewController:self.createCustomSecurityViewController];
    }
    
    [self.ticketsController.navigationController pushViewController:historyView animated:YES];
}

- (IBAction)purchaseButton:(id)sender
{
    TicketsListViewController *ticketview = [[TicketsListViewController alloc]initWithNibName:@"TicketsListViewController" bundle:nil];
    [ticketview setManagedObjectContext:self.managedObjectContext];
    
    [self.navigationController pushViewController:ticketview animated:YES];

}

#pragma mark - Other methods

- (void)loadTableData
{
    self.emptyListLabel.hidden = YES;
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
        
        int nowEpochTime = [[NSDate date] timeIntervalSince1970];
        int expirationEpochTime = [ticket.expirationDateTime doubleValue];
        
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
