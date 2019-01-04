
//
//  PayAsYouGoViewController.m//  CDTATicketing
//
//  Created by CooCooTech on 8/25/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "CDTA_AB_PayAsYouGoViewController.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "CDTATicketsViewController.h"
#import "GetStoredValueAccountService.h"
#import "GetStoredValueProductsService.h"
#import "PayAsYouGoCell.h"
#import "StoredValueAccount.h"
#import "StoredValueLoyalty.h"
#import "StoredValueProgramRule.h"
#import "StoredValueRange.h"
#import "StoredValueRuleCriteria.h"
#import "StoredValueSyncService.h"
#import "Tenant.h"
#import "Product.h"
#import "GetProductsService.h"
#import "GetWalletContents.h"
#import "WalletContents.h"
#import "GetWalletContentUsagePayAsYouGo.h"
#import "TicketsListViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import "LoyaltyBonus.h"
#import "LoyaltyCapped.h"
#import "Singleton.h"

typedef enum {
    NotElegibleCappedRide = 0,
    ElegibleCappedRide,
    FreeCappedRide
} CappedRideType;

int const PASSBACK_MINUTES = 10;
NSString *const KEY_FIRST_TIME_PAY_AS_YOU_GO = @"firstTimePayAsYouGo";

@interface CDTA_AB_PayAsYouGoViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation CDTA_AB_PayAsYouGoViewController
{
    float currentBalance;
    StoredValueProduct *currentStoredValueProduct;  // Reference to product selected in table view
  //  UIActivityIndicatorView *spinner;
    UIAlertView *syncAlertView;
    NSArray *loyaltyInfo;
    NSMutableArray *storedValueProducts;
    NSArray *rules;
    UILabel *emptyLabel;
    UILabel *quickStartLabel;
    int currentRiderCount;
    float futureBalance;
    NSArray *totalProdcutArray;
    NSArray *filteredProdcutArray;
    float ticketidValue;
    NSMutableArray  *ticketIdentifier1;
    NSArray *ticketIdentifier;
    Event *event;
    NSIndexPath *SelectedIndexpath;
    BOOL isCappedRide;
    float deductionAmount;
    int cappedDelay;
    BOOL isBonusRide;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        loyaltyInfo = [[NSArray alloc] init];
        storedValueProducts = [[NSMutableArray alloc] init];
        rules = [[NSArray alloc] init];
        
        currentRiderCount = 1;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTickets) name:@"reloadTickets" object:nil];
    cappedDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_DELAY"]).intValue;;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTickets) name:@"updateTickets" object:nil];
    GetProductsService *prodecutservice=[[GetProductsService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
    [prodecutservice execute];
    
    
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
        
    {
        [event setValue:@"no" forKey:@"identifier"];
        
    }
    else
    {
        
    }
  
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    NSError *error = nil;
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    [self targetMethod];
    
}

-(void)reloadTickets{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    NSError *error = nil;
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    [self targetMethod];
}

-(void)updateTickets
{
    [self getTicketsFromServer];
}

- (void)getTicketsFromServer
{
    GetWalletContents *contents = [[GetWalletContents alloc]initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
    [contents execute];
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
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ticketIdentifier == %@)" ,storedValueFalseProduct.ticketId]];
    NSError * error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    
    return fetchedObjects;
    
}


-(void)targetMethod{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    NSError *error = nil;
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (totalProdcutArray.count >0) {
        filteredProdcutArray = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@) AND isActivationOnly == 1 ",@"Stored Value"]];
    }
    if (filteredProdcutArray.count >0) {
        self.tableView.hidden=NO;
        emptyLabel.hidden=YES;
        [self.tableView reloadData];
    }
    else{
        self.tableView.hidden=YES;
        emptyLabel.hidden=NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Text Screens" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    [self targetMethod];
    [self displayPassesEmptyLabel];
    
    self.tableView.backgroundColor = UIColor.clearColor;
    self.view.backgroundColor = UIColor.clearColor;

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (syncAlertView) {
        [syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        syncAlertView = nil;
    }else{
        [self dismissProgressDialog];
    }
//    else if (spinner) {
//        [spinner stopAnimating];
//
//        spinner = nil;
//    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if([service isMemberOfClass:[GetProductsService class]]){
        
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
        NSError *error = nil;
        totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
        [self targetMethod];
        
    }
    else if ([service isMemberOfClass:[GetWalletContentUsagePayAsYouGo class]]) {
        
        
    }
    else if ([service isMemberOfClass:[GetStoredValueAccountService class]]) {
        [self loadAccountData];
    } else if ([service isMemberOfClass:[GetStoredValueProductsService class]]) {
        
        if ([storedValueProducts count] > 0) {
            [self.tableView setHidden:NO];
            [emptyLabel setHidden:YES];
            [self.tableView reloadData];
        } else {
            [self displayPassesEmptyLabel];
        }
//        [self loadTableData];
//        if ([storedValueProducts count] > 0) {
//            [self.tableView reloadData];
//        } else {
//            if (!emptyLabel) {
//                // Should only ever happen if there is a server request error on the very first load of this View Controller
//                CGRect applicationFrame = [[UIScreen mainScreen] bounds];
//
//                emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width - 20, 0)];
//                [emptyLabel setText:[Utilities stringResourceForId:@"no_products"]];
//                [emptyLabel setTextAlignment:NSTextAlignmentCenter];
//                [emptyLabel setFont:[UIFont systemFontOfSize:16]];
//                [emptyLabel setNumberOfLines:0];
//                [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
//                [emptyLabel sizeToFit];
//                [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
//                                                  (applicationFrame.size.height / 2) - NAVIGATION_BAR_HEIGHT)];
//                [emptyLabel setHidden:NO];
//
//                [self.view addSubview:emptyLabel];
//            }
//        }
        if (syncAlertView) {
            [syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
            
            syncAlertView = nil;
        }else{
            [self dismissProgressDialog];
        }
//        else if (spinner) {
//            [spinner stopAnimating];
//
//            spinner = nil;
//        }
        
        [self showFirstTimeMessage];
    }
    [self dismissProgressDialog];
}
-(void)displayPassesEmptyLabel{
    if ([filteredProdcutArray count] > 0) {
        [self.tableView setHidden:NO];
        [emptyLabel setHidden:YES];
    }else{
        [self.tableView setHidden:YES];
        [emptyLabel setHidden:NO];
        if (!emptyLabel) {
            // Should only ever happen if there is a server request error on the very first load of this View Controller
            CGRect applicationFrame = [[UIScreen mainScreen] bounds];
            emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width - 20, 0)];
            [emptyLabel setText:[Utilities stringResourceForId:@"no_products"]];
            [emptyLabel setTextAlignment:NSTextAlignmentCenter];
            [emptyLabel setFont:[UIFont systemFontOfSize:16]];
            [emptyLabel setNumberOfLines:0];
            [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [emptyLabel sizeToFit];
//            [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
//                                              (applicationFrame.size.height / 2) - NAVIGATION_BAR_HEIGHT -50)];
            [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                              (self.view.frame.size.height / 2) - (emptyLabel.frame.size.height/2))];
            [self.view addSubview:emptyLabel];
        }
        
    }
    
    
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [super threadErrorWithClass:service response:response];
    [self dismissProgressDialog];
    [self threadSuccessWithClass:service response:response];
    if([service isMemberOfClass:[GetProductsService class]]){
        
    }
    if ([service isMemberOfClass:[GetWalletContentUsagePayAsYouGo class]]) {
    }
    
}

#pragma mark - View controls

- (void)showFirstTimeMessage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL hasSeenMessage = [defaults boolForKey:KEY_FIRST_TIME_PAY_AS_YOU_GO];
    
    if (!hasSeenMessage) {
        NSString *passbackMinutesString = @"";
        
        if (PASSBACK_MINUTES == 1) {
            passbackMinutesString = @"1 minute";
        } else {
            passbackMinutesString = [NSString stringWithFormat:@"%d minutes", PASSBACK_MINUTES];
        }
        
        UIAlertView *firstTimeView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:[Utilities payAsYouGoAlertTitle]]
                                                                message:[Utilities stringResourceForId:[Utilities payAsYouGoMessage]]
                                                               delegate:nil
                                                      cancelButtonTitle:[Utilities stringResourceForId:[Utilities closeButtonTitle]]
                                                      otherButtonTitles:nil];
        [firstTimeView show];
        
        [defaults setBool:YES forKey:KEY_FIRST_TIME_PAY_AS_YOU_GO];
        
        [defaults synchronize];
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self activatepayasYougo];
    }
    
}
-(void)commonEvent:(Event *)event and:(WalletContents *)passesWC{
    NSDate *now = [NSDate date];
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    NSInteger epochSeconds = [[NSNumber numberWithDouble:epochSecondsDecimals] integerValue];
    [event setType:@"payasyougo"];
    [event setIdentifier:@"no"];
    [event setAmountRemaining:[NSNumber numberWithDouble:[passesWC.balance doubleValue]]];
    [event setClickedTime:[NSNumber numberWithInteger:epochSeconds*1000]];
    [event setWalletContentUsageIdentifier:passesWC.identifier];
    NSError *error1;
    if (![self.managedObjectContext save:&error1]) {
        NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
    } else {
        NSLog(@"Saved ");
    }
    
}

-(void)activatepayasYougo{
    
    id Identifier = [[filteredProdcutArray objectAtIndex:SelectedIndexpath.row ]valueForKey:@"productDescription"];
    NSLog(@"%@",Identifier);
    Product *product=[filteredProdcutArray objectAtIndex:SelectedIndexpath.row];
    BOOL cond =  [self preparingWallet:product];
    if(cond==NO){
    event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:Event_Model inManagedObjectContext:self.managedObjectContext];
    [event setTicketid:product.ticketId.stringValue];
    }
    
    isCappedRide = [[Singleton sharedManager] isProductEligibleForCappedRide:product];
    isBonusRide = [[Singleton sharedManager] isProductEligibleForBonusFreeRide:product];
    [[Singleton sharedManager] isCappedValidForIncrement:product];
    [[Singleton sharedManager] isBonusValidForIncrement:product];


    if(isCappedRide == NO && isBonusRide == NO){
//        [[Singleton sharedManager] incrementCappedRidesByCount:1 andProduct:product];
//        [[Singleton sharedManager] incrementBonusRidesByCount:1 andProduct:product];
        
        NSString * accbalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountbalance"];
        double amountbalance = accbalance.doubleValue-product.price.doubleValue;
        if(event){
        [event setFare:[NSNumber numberWithDouble:[product.price doubleValue]]];
        [event setTicketid:product.ticketId.stringValue];
        [event setAmountRemaining:[NSNumber numberWithDouble:amountbalance]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:amountbalance] forKey:@"accountbalance"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    else  if (isCappedRide == YES){
        LoyaltyCapped *capped=[[Singleton sharedManager] getLoyalityCappedForProduct:product];
        capped.referenceActivatedTime=[NSDate date];
        NSError *saveError = nil;
        [self.managedObjectContext save:&saveError];
        int cappedTicketid = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_TICKETID"]).intValue;
        if(event){
        [event setFare:[NSNumber numberWithDouble:0]];
        [event setTicketid:[NSString stringWithFormat:@"%d", cappedTicketid]];
        }
    }
    
    else if (isBonusRide == YES){
        int bonusTicketid = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_TICKETID"]).intValue;
        if(event){
        [event setFare:[NSNumber numberWithDouble:0]];
        [event setTicketid:[NSString stringWithFormat:@"%d", bonusTicketid]];
        }
        [[Singleton sharedManager] deleteLoyalityBonusRide:product];
    }
    
    
    if(cond==NO&&event){
        NSString * balance = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountbalance"];
        [self commonEvent:event balance:balance.doubleValue product:product];
    }
    
    
    AppDelegate *adelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [adelegate isReachable:nil];
    
}
-(void)commonEvent:(Event *)event balance:(double)balance product:(Product*)prod {
    NSDate *now = [NSDate date];
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    NSInteger epochSeconds = [[NSNumber numberWithDouble:epochSecondsDecimals] integerValue];
    [event setType:@"payasyougo"];
    [event setIdentifier:@"no"];
    [event setAmountRemaining:[NSNumber numberWithDouble:balance]];
    [event setClickedTime:[NSNumber numberWithInteger:epochSeconds*1000]];
    [event setWalletContentUsageIdentifier:prod.ticketId.stringValue];
    NSError *error1;
    if (![self.managedObjectContext save:&error1]) {
        NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
    } else {
        NSLog(@"Saved ");
    }
    
}



-(void)addEntryForCappedLoyaltyWithRideType:(CappedRideType)ridetype andProduct:(Product *)product{
    LoyaltyCapped *capped = (LoyaltyCapped *)[NSEntityDescription insertNewObjectForEntityForName:LOYALTY_CAPPED_MODEL inManagedObjectContext:self.managedObjectContext];
    capped.rideCount = [NSNumber numberWithInt:ridetype];
    capped.activatedTime = [NSDate date];
    capped.productId = product.ticketId.stringValue;
    capped.productName=product.productDescription;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    }
}


/*
 This is a dummy method - nned to be removed
 */
/*
-(void)deleteLoyalityBonusRide:(Product*)prod{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_BONUS_MODEL  inManagedObjectContext:self.managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", prod.ticketId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSError *saveError = nil;
    NSArray *products = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (LoyaltyCapped *product in products) {
        [self.managedObjectContext deleteObject:product];
        
    }
    [self.managedObjectContext save:&saveError];
    
}
 */

/*
-(void)resetBonusRidesByCount:(Product *)product{
    LoyaltyBonus *bonus = [[Singleton sharedManager] getLoyalityBonusForProduct:product];
    bonus.rideCount = [NSNumber numberWithInt:0];
    bonus.activatedTime = [NSDate date];
    bonus.productId = product.ticketId.stringValue;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    }
}
 */


/*
-(void)resetCappedRidesByCount:(Product *)product{
    LoyaltyCapped *capped = [[Singleton sharedManager] getLoyalityCappedForProduct:product];
    capped.rideCount = [NSNumber numberWithInt:0];
    capped.activatedTime = [NSDate date];
    capped.productId = product.ticketId.stringValue;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    }
}
*/


/*
-(void)updateEntryForBonusLoyalty:(LoyaltyBonus *)bonus withProduct:(Product *)product andCount:(int)count{
    bonus.rideCount = [NSNumber numberWithInt:count];
    bonus.activatedTime = [NSDate date];
    bonus.productId = product.ticketId.stringValue;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    }
}
 */

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Products";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredProdcutArray count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PayAsYouGoCell";
    PayAsYouGoCell *cell = (PayAsYouGoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Product *prod=[filteredProdcutArray objectAtIndex:indexPath.row];
    
    cell.prod=prod;
    
    [cell startTimer];
    
    [cell.ticketTypeLabel setText:prod.productDescription];
    [cell.descriptionLabel setText:prod.productDescription];
    [cell.totalFareLabel setText:[NSString stringWithFormat:@"Fare: $ %.2f",prod.price.floatValue]];
    if (cell.activationsLabel.text.length > 0) {
        cell.activationsLabelWidthConstraint.constant = 94;
    }else{
        cell.activationsLabelWidthConstraint.constant = 0;
    }
    cell.backgroundColor = UIColor.clearColor;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
-(BOOL)preparingWallet:(Product*)prod{
    
    BOOL cond=NO;
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    //ticketIdentifier
    
    NSArray *fetchedObjects;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:WALLET_CONTENT_MODEL  inManagedObjectContext: context];
    [fetch setEntity:entityDescription];
    long timeint = [[NSDate date] timeIntervalSince1970];
    
   
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"ticketIdentifier == %@ && status == %@ && fare == %ld && ticketActivationExpiryDate > %lli",prod.ticketId.stringValue,@"active",0,timeint]];
    NSError * error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    
    WalletContents *wc;
    if([fetchedObjects count] == 0)
    {
        
        wc = (WalletContents *)[NSEntityDescription insertNewObjectForEntityForName:WALLET_CONTENT_MODEL inManagedObjectContext:self.managedObjectContext];
        if (isBonusRide||isCappedRide){
            wc.fare = 0;
        }else{
            wc.fare=[NSNumber numberWithDouble:prod.price.doubleValue];
        }
//        wc.fare=[NSNumber numberWithDouble:prod.price.doubleValue];
        //wc.ticketGroup=[[[Singleton sharedManager] userwallet] accTicketGroupId];
        wc.ticketGroup= [[NSUserDefaults standardUserDefaults]objectForKey:@"accticketgroupid"];
        NSNumber *agencyIdNum = [[NSUserDefaults standardUserDefaults]objectForKey:@"AGENCY_ID"];
        NSString *memberId = [[NSUserDefaults standardUserDefaults] objectForKey:@"accmemberid"];
        wc.member=memberId;
        wc.purchasedDate=[NSNumber numberWithLong:milliseconds];
        wc.agencyId=agencyIdNum;
        wc.descriptation=prod.productDescription;
        wc.type=prod.ticketTypeId;
        wc.ticketIdentifier=prod.ticketId.stringValue;
        wc.allowInteraction=[NSNumber numberWithBool:true];
        wc.designator=[NSNumber numberWithDouble:prod.designator.doubleValue];
        wc.identifier=[NSString stringWithFormat:@"%@$%lli",prod.ticketId,milliseconds];
        //  wc.valueRemaining=passesWC.valueRemaining;
        //   wc.group=passesWC.group;
        wc.instanceCount=0;
        wc.status=ACTIVE;
        wc.purchasedDate=[NSNumber numberWithLong:milliseconds];
        wc.activationDate=[NSNumber numberWithLong:milliseconds];
        wc.generationDate=[NSNumber numberWithLong:milliseconds];
        wc.ticketEffectiveDate=[NSNumber numberWithLong:milliseconds];
        
        long exptime = (long long)([[NSDate date] timeIntervalSince1970] );
        wc.ticketActivationExpiryDate=[NSNumber numberWithLong:exptime+prod.barcodeTimer.longValue];
        wc.ticketSource=@"local";
        cond=NO;
        
        TicketActivation *ticketactivation = (TicketActivation *)[NSEntityDescription insertNewObjectForEntityForName:Activation_Model inManagedObjectContext:self.managedObjectContext];
        NSDate *expDate=[NSDate dateWithTimeIntervalSince1970:wc.ticketActivationExpiryDate.doubleValue];
        
        NSDateFormatter *df=[[NSDateFormatter alloc]init];
        [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        [ticketactivation setActivationDate:[df stringFromDate:[NSDate date]]];
        [ticketactivation setActivationExpDate:[df stringFromDate:expDate]];
        [ticketactivation setTicketIdentifier:prod.productId];
        
        NSError *saveError = nil;
        [self.managedObjectContext save:&saveError];
        
    }
    else{
        wc=fetchedObjects.firstObject;
        cond=YES;
    }
    
    
  
    
    
    
    TicketPageViewController *pageView = [[TicketPageViewController alloc] initWithNibName:@"TicketPageViewController" bundle:[NSBundle baseResourcesBundle]];
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
    [[[Singleton sharedManager]currentNVC] pushViewController:pageView animated:YES];
    return cond;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    //PRODUCT_MODEL * managedObject = [filteredProdcutArray objectAtIndex:indexPath.row];
    // NSLog(@"dataDict is:%@",managedObject);
    
    SelectedIndexpath=indexPath;
    Product *prod=[filteredProdcutArray objectAtIndex:indexPath.row];
    
    if ([prod.isBonusRideEnabled boolValue]== YES) {
        NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_THRESHOLD"];
        prod.bonusThreshold = value;
    }else{
        prod.bonusThreshold = [NSNumber numberWithInteger:-1];
    }
    
    if ([prod.isCappedRideEnabled boolValue]== YES) {
        NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_THRESHOLD"];
        prod.cappedThreshold = value;
    }else{
        prod.cappedThreshold = [NSNumber numberWithInteger:-1];
    }

    
    isBonusRide = [[Singleton sharedManager] isProductEligibleForBonusFreeRide:prod];
    isCappedRide = [[Singleton sharedManager] isProductEligibleForCappedRide:prod ];
    
    NSString *accbalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountbalance"];
    
    currentBalance= accbalance.floatValue;
    
    if(isCappedRide == NO){
        deductionAmount = prod.price.floatValue;
        futureBalance = currentBalance - deductionAmount;
    }
    
    if (isBonusRide == NO){
        deductionAmount = prod.price.floatValue;
        futureBalance = currentBalance - deductionAmount;
    }
    
    if (isBonusRide||isCappedRide){
        deductionAmount = 0;
        futureBalance = currentBalance;
    }
    if (futureBalance >= 0.0f || prod.price.doubleValue == 0) {
        
        NSString *newBalanceMessage = nil;
        if (deductionAmount == 0.0f) {
            newBalanceMessage = @"Your Balance will remain at";
        } else {
            newBalanceMessage = @"Your new Balance will be";
        }
        
        if (isBonusRide||isCappedRide){
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isFreeRide"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_ticket_title"]
                                                                    message:[NSString stringWithFormat:@"%@",
                                                                             [Utilities stringResourceForId:@"activate_msg"]]
                                                                   delegate:self
                                                          cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                                          otherButtonTitles:[Utilities stringResourceForId:@"yes"], nil];
                [alertView show];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isFreeRide"];
            if (prod.price.doubleValue != 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_ticket_title"]
                                                                    message:[NSString stringWithFormat:@"$%.2f %@\n%@\n%@ $%.2f.\n\n%@",
                                                                             currentBalance - futureBalance,
                                                                             @"will be deducted from your",
                                                                             @"Pay As You Go Balance.",
                                                                             newBalanceMessage,
                                                                             futureBalance,
                                                                             [Utilities stringResourceForId:@"activate_msg"]]
                                                                   delegate:self
                                                          cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                                          otherButtonTitles:[Utilities stringResourceForId:@"yes"], nil];
                [alertView show];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_ticket_title"]
                                                                    message:[NSString stringWithFormat:@"%@",
                                                                             [Utilities stringResourceForId:@"activate_msg"]]
                                                                   delegate:self
                                                          cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                                          otherButtonTitles:[Utilities stringResourceForId:@"yes"], nil];
                [alertView show];
            }
        }

        

     
        
    } else {
        
        currentStoredValueProduct = nil;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"notEnoughValueTitle"]
                                                            message:[Utilities stringResourceForId:@"notEnoughValueMessage"]
                                                           delegate:nil
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - Other methods

- (void)loadAccountData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_ACCOUNT_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *accounts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([accounts count] > 0) {
        StoredValueAccount *account;
        for (StoredValueAccount *thisStoredValueAccount in accounts) {
            if ([thisStoredValueAccount.association isEqualToString:self.cardUuid]) {
                account = thisStoredValueAccount;
            }
        }
        
        currentBalance = [account.amount floatValue];
        
    }
    
    [self updateCurrentBalance];
    
}

- (void)loadLoyaltyInfo
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_LOYALTY_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cardUuid == %@", self.cardUuid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    loyaltyInfo = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [self.tableView reloadData];
}

- (void)updateCurrentBalance
{
    
    
}

- (void)loadTableData
{
    
    if (quickStartLabel != nil ) {
        [quickStartLabel setHidden:YES];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_PRODUCT_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isForSale == 1"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    storedValueProducts = [[NSMutableArray alloc] initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:STORED_VALUE_PROGRAM_RULE_MODEL
                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *unsortedRules = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Sort from lowest requirement magnitude to highest so that 3-ride program comes before 10-ride
    rules = [unsortedRules sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        StoredValueRuleCriteria *requirement1 = [NSKeyedUnarchiver unarchiveObjectWithData:[(StoredValueProgramRule *)obj1 requirement]];
        StoredValueVector *requirementAmount1 = requirement1.amount;
        float requirementAmountMagnitude1 = requirementAmount1.magnitude;
        
        StoredValueRuleCriteria *requirement2 = [NSKeyedUnarchiver unarchiveObjectWithData:[(StoredValueProgramRule *)obj2 requirement]];
        StoredValueVector *requirementAmount2 = requirement2.amount;
        float requirementAmountMagnitude2 = requirementAmount2.magnitude;
        
        return requirementAmountMagnitude1 > requirementAmountMagnitude2;
    }];
}

/*
 * Returns StoredValueProgramRule if current ticket options and saved loyalty info are eligible,
 * otherwise returns a nil object
 */

/*
- (StoredValueProgramRule *)eligibleProgramRuleForProduct:(StoredValueProduct *)product
{
    if (product) {
        for (StoredValueProgramRule *rule in rules) {
            StoredValueRuleCriteria *requirement = [NSKeyedUnarchiver unarchiveObjectWithData:rule.requirement];
            
            for (NSString *productCode in requirement.productIds) {
                BOOL requirementsMet = NO;
                
                if ([product.code isEqualToString:productCode]) {
                    // Current window default values:
                    // offset = 14,400 seconds = 4 hours = Number of seconds after midnight when window begins
                    // duration = 86,400 seconds = 24 hours = Number of seconds after window start when window ends
                    StoredValueDuration *requirementWindow = requirement.window;
                    
                    NSDate *now = [NSDate date];
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    
                    NSDateComponents *midnightComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
                    [midnightComponents setHour:0];
                    [midnightComponents setMinute:0];
                    [midnightComponents setSecond:0];
                    
                    NSDate *dateAtMidnight = [calendar dateFromComponents:midnightComponents];
                    
                    // If the current time is AFTER the offset, then the starting midnight is the same midnight as the offset
                    // If the current time is BEFORE the offset (e.g. currently 2AM and offset is 4AM), start at "yesterday's" midnight
                    int nowSecondsFromMidnight = [now timeIntervalSince1970] - [dateAtMidnight timeIntervalSince1970];
                    
                    if (nowSecondsFromMidnight < requirementWindow.offset) {
                        dateAtMidnight = [calendar dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:dateAtMidnight options:0];
                    }
                    
                    NSTimeInterval windowStartSeconds = [dateAtMidnight timeIntervalSince1970] + requirementWindow.offset;
                    //NSTimeInterval windowEndDateTime = windowStartSeconds + requirementWindow.duration;
                    // NSDate *windowEnd = [NSDate dateWithTimeIntervalSince1970:windowEndDateTime];
                    
                    if (([now compare:[NSDate dateWithTimeIntervalSince1970:windowStartSeconds]] == NSOrderedDescending)
                        //&& ([now compare:windowEnd] == NSOrderedAscending)) {
                        NSLog(@"requirement window GOOD, start: %@", [[NSDate dateWithTimeIntervalSince1970:windowStartSeconds] description]);
                        
                        requirementsMet = YES;
                    } else {
                        NSLog(@"requirement window BAD, start: %@", [[NSDate dateWithTimeIntervalSince1970:windowStartSeconds] description]);
                        
                        requirementsMet = NO;
                    }
                    
                    // Requirement is based on number of activations, TODO: Handle any other attributes created in the future
                    if (requirementsMet && [requirement.attribute isEqualToString:CRITERIA_ATTRIBUTE_ACTIVATIONS]) {
                        StoredValueVector *requirementAmount = requirement.amount;
                        float requirementAmountMagnitude = requirementAmount.magnitude;
                        
                        NSLog(@"requirementAmountMagnitude: %f", requirementAmountMagnitude);
                        
                        StoredValueLoyalty *matchingLoyaltyItem;
                        
                        for (StoredValueLoyalty *loyaltyItem in loyaltyInfo) {
                            if ([loyaltyItem.productCode isEqualToString:product.code]) {
                                if ([requirementAmount.type isEqualToString:VECTOR_TYPE_NUMERICAL]) {   // TODO: Handle any other types created in the future
                                    if ([loyaltyItem.requirementMagnitude floatValue] == requirementAmount.magnitude) {
                                        matchingLoyaltyItem = loyaltyItem;
                                        break;
                                    }
                                }
                            }
                        }
                        
                        if (matchingLoyaltyItem) {
                            int loyaltyActivations = [matchingLoyaltyItem.activationCount intValue];
                            
                            NSLog(@"loyaltyThreshold: %f", [matchingLoyaltyItem.requirementMagnitude floatValue]);
                            NSLog(@"loyaltyActivationCount: %d", loyaltyActivations);
                            
                            if (loyaltyActivations >= requirementAmountMagnitude) {
                                // Determine if current product is also eligible within rule criteria's benefit time window
                                // Delete StoredValueLoyalty item if already past benefit window
                                if ([now compare:matchingLoyaltyItem.expirationDateTime] == NSOrderedDescending) {
                                    [self.managedObjectContext deleteObject:matchingLoyaltyItem];
                                    
                                    NSError *saveError = nil;
                                    [self.managedObjectContext save:&saveError];
                                } else {
                                    float requirementMagnitude = [matchingLoyaltyItem.requirementMagnitude floatValue];
                                    
                                    // Return 3-ride benefit if past the passback window
                                    if (requirementMagnitude == 3) {
                                        NSDate *passbackWindowEnd = [NSDate dateWithTimeInterval:(PASSBACK_MINUTES * 60)
                                                                                       sinceDate:matchingLoyaltyItem.modifiedDateTime];
                                        
                                        if ([now compare:passbackWindowEnd] == NSOrderedDescending) {
                                            NSLog(@"Returning benefit from %f ride program", requirementMagnitude);
                                            
                                            return rule;
                                        }
                                    } else if (requirementMagnitude == 10) {
                                        NSLog(@"Returning benefit from %f ride program", requirementMagnitude);
                                        
                                        return rule;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    return nil;
}

*/


/*
 * Not used in Account based View Controller
*/

/*
 
- (float)eligibleAmountForBenefit:(StoredValueRuleCriteria *)benefit product:(StoredValueProduct *)product
{
    if (benefit && product) {
        StoredValueRange *benefitEntrants = benefit.entrants;
        
        if (currentRiderCount >= benefitEntrants.minimum) {
            if ([benefit.attribute isEqualToString:CRITERIA_ATTRIBUTE_AMOUNT]) {    // Benefit applies to StoredValueProduct amount
                StoredValueVector *benefitAmountVector = benefit.amount;
                
                if ([benefitAmountVector.type isEqualToString:VECTOR_TYPE_PERCENTAGE]) {
                    return benefitAmountVector.magnitude * [product.amount floatValue];
                }
            } else if ([benefit.attribute isEqualToString:CRITERIA_ATTRIBUTE_SUBSTITUTION]) {
                NSString *substitutionProductCode = [benefit.productIds objectAtIndex:0];
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_PRODUCT_MODEL
                                                          inManagedObjectContext:self.managedObjectContext];
                [fetchRequest setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isForSale == 0"];
                [fetchRequest setPredicate:predicate];
                
                NSError *error;
                NSArray *benefitProducts = [[NSArray alloc] initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
                
                for (StoredValueProduct *product in benefitProducts) {
                    if ([product.code isEqualToString:substitutionProductCode]) {
                        return [product.amount floatValue];
                    }
                }
            }
        }
    }
    
    return 0.0f;
}
*/

/*
 * Nout used in Account Based Implementation. Kept here as a reference.
- (Ticket *)createTicketForProduct:(StoredValueProduct *)product transitId:(NSString *)transitId amount:(float)amount
{
    NSDate *now = [NSDate date];
    
    NSLog(@"This is product description %@",product);
    
    Ticket *ticket = (Ticket *)[NSEntityDescription insertNewObjectForEntityForName:TICKET_MODEL inManagedObjectContext:self.managedObjectContext];
    
    ticket.isStaging = [NSNumber numberWithBool:NO];
    ticket.isStoredValue = [NSNumber numberWithBool:YES];
    ticket.type = ACTIVE;
    ticket.status = STATUS_ACTIVATED;
    ticket.activationType = ACTIVATION_TYPE;
    ticket.eventType = EVENT_TYPE_ACTIVATE;
    ticket.transitId = transitId;
    //ticket.deviceId = [Utilities deviceId];
    ticket.deviceId = self.cardUuid;
    ticket.ticketGroupId = product.ticketGroupId;
    ticket.memberId = product.memberId;
    ticket.ticketAmount = [NSNumber numberWithFloat:amount];
    ticket.riderCount = [NSNumber numberWithInt:currentRiderCount];
    ticket.fareCode = product.code;
    
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    NSInteger epochSeconds = [[NSNumber numberWithDouble:epochSecondsDecimals] integerValue];
    ticket.activationDateTime = [NSNumber numberWithInteger:epochSeconds];
    ticket.firstActivationDateTime = [NSNumber numberWithInteger:epochSeconds];
    ticket.activatedSeconds = [NSNumber numberWithInteger:epochSeconds];
    ticket.lastUpdated = [NSNumber numberWithInteger:epochSeconds];
    ticket.purchaseDateTime = [NSNumber numberWithInteger:epochSeconds];
    ticket.validStartDateTime = [NSNumber numberWithInteger:epochSeconds]; // Verify
    
    NSDictionary *ticketSettings = [NSKeyedUnarchiver unarchiveObjectWithData:product.ticketSettings];
    int activationLiveTime = [[ticketSettings valueForKey:@"activationtime"] intValue];
    
    ticket.activationLiveTime = [NSNumber numberWithInt:activationLiveTime];
    
    // TODO: Get real values from API
    ticket.id = [NSString stringWithFormat:@"%d", (int) [[NSDate new] timeIntervalSince1970]];
    ticket.firstName = @"";
    ticket.lastName = @"";
    ticket.activationResetTime = [NSNumber numberWithInt:40];
    ticket.activationTransitionTime = [NSNumber numberWithInt:60];
    
    // TODO: Need correct approach
    //ticket.creditCard = @"CC";//Removed this so that the field doesnt get displayed
    ticket.statusCode = [NSNumber numberWithInt:99];
    //ticket.invoiceId = @"InvoiceId";//Removed this so that the field doesnt get displayed
    ticket.sellerId = @"App";
    ticket.szType = @"SzType";
    ticket.departId = @"DepartId";
    ticket.arriveId = @"ArriveId";
    ticket.departStationId = @"DepartStationId";
    ticket.arriveStationId = @"ArriveStationId";
    ticket.serviceCode = @"ServiceCode";
    ticket.riderTypeCode = @"RiderTypeCode";
    ticket.fareZoneCode = @"FareZoneCode";
    ticket.fareZoneCodeDesc = @"FareZoneCodeDesc";
    //ticket.bfp = @"Bfp";    // TEMP: Have bfp store the revisionId needed in the updated ticketevents/add endpoint
    ticket.bfp = [product.revisionId stringValue];
    ticket.riderTypeDesc = @"RiderTypeDesc";
    
    // TODO: Verify
    ticket.ticketTypeCode = product.code;
    ticket.ticketTypeDesc = product.productDescription;
    ticket.ticketTypeNote = product.note;
    
    // TODO: Need to determine, set as 24 hours for now
    long expirationSpan = 60 * 60 * 24; // 24 hours
    ticket.expirationSpan = [NSNumber numberWithLong:expirationSpan];
    
    [ticket setExpirationDateForTicketFromDate:now usingManagedObjectContext:self.managedObjectContext];
    
    NSLog(@"createTicket expirationDate: %@", ticket.expirationDateTime);
    
    // TODO: Verify that each Pay As You Go is just 1 activation
    ticket.activationCount = [NSNumber numberWithInt:1];
    ticket.inspections = [NSNumber numberWithInt:0];
    ticket.activationCountMax = [NSNumber numberWithInt:1];
    
    // TODO
    ticket.eventLat = [NSNumber numberWithDouble:0.0];
    ticket.eventLng = [NSNumber numberWithDouble:0.0];
    
    NSLog(@"Ticket creation: %@", ticket);
    
    
    // Save ticket
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"PayAsYouGo Create Ticket Error, couldn't save: %@", [saveError localizedDescription]);
    }
    
    CardEvent *redeemEvent = (CardEvent *)[NSEntityDescription insertNewObjectForEntityForName:CARD_EVENT_MODEL inManagedObjectContext:self.managedObjectContext];
    
    [redeemEvent setOccurredOnDateTime:now];
    [redeemEvent setType:CARD_EVENT_TYPE_REDEEM];
    [redeemEvent setDetail:@"Redemption"];
    
    CardEventContent *cardEventContent = [[CardEventContent alloc] init];
    
    [cardEventContent setTicketGroupId:ticket.ticketGroupId];
    [cardEventContent setMemberId:ticket.memberId];
    [cardEventContent setBornOnDateTime:now];
    
    CardEventFare *cardEventFare = [[CardEventFare alloc] init];
    
    [cardEventFare setCode:ticket.fareCode];
    
    CardEventRevision *cardEventRevision = [[CardEventRevision alloc] init];
    
    [cardEventRevision setRevisionId:[product.revisionId longValue]];
    
    [cardEventFare setRevision:cardEventRevision];
    
    [cardEventContent setFare:cardEventFare];
    
    NSData *contentData = [NSKeyedArchiver archivedDataWithRootObject:cardEventContent];
    
    [redeemEvent setContent:contentData];
    
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"PayAsYouGo Create Redeem Event Error, couldn't save: %@", [saveError localizedDescription]);
    }
    
    CardEvent *activateEvent = (CardEvent *)[NSEntityDescription insertNewObjectForEntityForName:CARD_EVENT_MODEL inManagedObjectContext:self.managedObjectContext];
    
    [activateEvent setOccurredOnDateTime:now];
    [activateEvent setType:CARD_EVENT_TYPE_ACTIVATE];
    [activateEvent setDetail:@"Activation"];
    [activateEvent setContent:contentData];
    
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"PayAsYouGo Create Activate Event Error, couldn't save: %@", [saveError localizedDescription]);
    }
    
    CardSyncService *cardSyncService = [[CardSyncService alloc] initWithContext:self.managedObjectContext];
    [cardSyncService execute];
    
    
    
    return ticket;
}
 
 */

@end


