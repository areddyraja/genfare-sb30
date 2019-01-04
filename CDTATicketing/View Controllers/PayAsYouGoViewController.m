//
//  PayAsYouGoViewController.m//  CDTATicketing
//
//  Created by CooCooTech on 8/25/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "PayAsYouGoViewController.h"
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
#import "Singleton.h"
#import "LoyaltyCapped.h"
#import "AccountBalance.h"
#import "AppConstants.h"


typedef enum {
    NotElegibleCappedRide = 0,
    ElegibleCappedRide,
    FreeCappedRide
} CappedRideType;

int const PASSBACK_MINUTES = 10;
NSString *const KEY_FIRST_TIME_PAY_AS_YOU_GO = @"firstTimePayAsYouGo";

@interface PayAsYouGoViewController ()

@end
#pragma mark - Variables Declarations
@implementation PayAsYouGoViewController
{
    float currentBalance;
    StoredValueProduct *currentStoredValueProduct;  // Reference to product selected in table view
    UIActivityIndicatorView *spinner;
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
     NSMutableArray *wallet_Contents1;
    NSArray *wallet_Contents;
    NSArray *ticketIdentifier;
    NSMutableArray *wallet_Contents3;
    Event *event;
    NSIndexPath *SelectedIndexpath;
    BOOL isCappedRide;
    float deductionAmount;
    int cappedDelay;
    BOOL isBonusRide;
}
#pragma mark - View lifecycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        loyaltyInfo = [[NSArray alloc] init];
        storedValueProducts = [[NSMutableArray alloc] init];
        rules = [[NSArray alloc] init];
        currentRiderCount = 1;
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"PayAsYouGoCell" bundle:nil] forCellReuseIdentifier:@"PayAsYouGoCell"];
    [_addValueButtonProperties setTitle:[Utilities stringResourceForId:@"add_balance"] forState:UIControlStateNormal];
    [_addValueButtonProperties setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [_addValueButtonProperties setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]]];
    cappedDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_DELAY"]).intValue;;
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self targetMethod];
//    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTickets) name:@"updateTickets" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBalanceViewColor) name:@"reloadBalance" object:nil];
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable){
        [event setValue:@"no" forKey:@"identifier"];
    }else{
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTickets) name:@"reloadTickets" object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBalanceViewColor];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Pay As You Go" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
//    [self targetMethod];
    [self displayPassesEmptyLabel];
    [self updateUiBasedOnWalletState];
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
        [_addValueButtonProperties setUserInteractionEnabled:NO];
        [_addValueButtonProperties setBackgroundColor:[UIColor lightGrayColor]];
    }else{
        NSLog(@"Active");
        [_addValueButtonProperties setUserInteractionEnabled:YES];
        [_addValueButtonProperties setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]]];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (syncAlertView) {
        [syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
        syncAlertView = nil;
    } else if (spinner) {
        [spinner stopAnimating];
        spinner = nil;
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Selector Methods
-(void)reloadTickets{
    [self getTicketsFromServer];
    [self targetMethod];
    [self updateBalanceViewColor];}

-(void)updateTickets{
    [self getTicketsFromServer];
    [self targetMethod];
    [self updateBalanceViewColor];
}
- (void)getTicketsFromServer{
    [self showProgressDialog];
    GetWalletContents *contents = [[GetWalletContents alloc]initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
    [contents execute];
}
-(void)targetMethod{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    NSError *error = nil;
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (totalProdcutArray.count >0) {
        filteredProdcutArray = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@) AND isActivationOnly == 1 ",@"Stored Value"]];
    }
    [self fetchingWalletContentsFromDB];
}
-(void)fetchingWalletContentsFromDB{
        [self FilteredPasses ];
    [self updateBalanceViewColor];
    if (filteredProdcutArray.count >0) {
        self.tableView.hidden=NO;
        emptyLabel.hidden=YES;
        [self dismissProgressDialog];
        [self.tableView reloadData];
    }else{
        self.tableView.hidden=YES;
        emptyLabel.hidden=NO;
    }
}
-(Product *)getPassAsYouGoTicketWithStoreValueFalse{
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
-(NSArray *)getPassesFromWalletContent{
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
-(void)FilteredPasses{
    wallet_Contents1= [[NSMutableArray alloc] initWithArray:[self getPassesFromWalletContent]];
    if(wallet_Contents1.count>0){
        WalletContents *wc=wallet_Contents1.firstObject;
        [self.balanceLabel setText:[NSString stringWithFormat:@"Balance: $%.2f", [wc.balance floatValue]]];
    }
}
- (void)showFirstTimeMessage{
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
                                                      cancelButtonTitle:[Utilities closeButtonTitle]
                                                      otherButtonTitles:nil];
        [firstTimeView show];
        [defaults setBool:YES forKey:KEY_FIRST_TIME_PAY_AS_YOU_GO];
        [defaults synchronize];
    }
}
-(void)activatepayasYougo{
    id Identifier = [[filteredProdcutArray objectAtIndex:SelectedIndexpath.row ]valueForKey:@"productDescription"];
    NSLog(@"%@",Identifier);
    Product *product=[filteredProdcutArray objectAtIndex:SelectedIndexpath.row];
    [self preparingWallet:product];
    WalletContents *passesWC;
    if(wallet_Contents1.count>0){
        passesWC=wallet_Contents1.firstObject;
    }
    isCappedRide = [[Singleton sharedManager] isProductEligibleForCappedRide:product];
    isBonusRide = [[Singleton sharedManager] isProductEligibleForBonusFreeRide:product];
    [[Singleton sharedManager] isCappedValidForIncrement:product];
    [[Singleton sharedManager] isBonusValidForIncrement:product];
    if(isBonusRide&&!isCappedRide){
        [[Singleton sharedManager] deleteLoyalityBonusRide:product];
    }
    event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:Event_Model inManagedObjectContext:self.managedObjectContext];
    [event setTicketid:passesWC.ticketIdentifier];
    LoyaltyCapped *capped=[[Singleton sharedManager] getLoyalityCappedForProduct:product];
    if(isCappedRide){
        capped.referenceActivatedTime=[NSDate date];
        NSError *saveError = nil;
        [self.managedObjectContext save:&saveError];
        isCappedRide = YES;
    }
    if(isCappedRide == NO && isBonusRide == NO){
        [event setFare:[NSNumber numberWithDouble:[product.price doubleValue]]];
        [event setTicketid:passesWC.ticketIdentifier];
    }else  if (isCappedRide == YES){
        int cappedTicketid = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_TICKETID"]).intValue;
        [event setFare:[NSNumber numberWithDouble:0]];
        [event setTicketid:[NSString stringWithFormat:@"%d", cappedTicketid]];
    }else if (isBonusRide == YES){
        int bonusTicketid = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_TICKETID"]).intValue;
        [event setFare:[NSNumber numberWithDouble:0]];
        [event setTicketid:[NSString stringWithFormat:@"%d", bonusTicketid]];
    }
    // [event setFare:[NSNumber numberWithDouble:[product.price doubleValue]]];
    [self commonEvent:event and:passesWC];
    AppDelegate *adelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [adelegate isReachable:nil];
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
-(BOOL)checkActivationTimeInLimits:(NSDate*)referenceDate offset:(int)offset{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:referenceDate];
    [components setHour:offset/60];
    [components setMinute:offset%60];
    [components setTimeZone:[NSTimeZone localTimeZone]];
    [components setSecond:0];
    NSDate *todayOffsetTime = [calendar dateFromComponents:components];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:todayOffsetTime options:0];
    return  [self date:[NSDate date] isBetweenDate:todayOffsetTime andDate:nextDate];
}
-(NSDate*)getReferenceDateForoffset:(int)offset{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    if(hour*60+minute<offset){
        dayComponent.day = -1;
    }else{
        dayComponent.day = 0;
    }
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    return [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
}
- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    return YES;
}
-(void)displayPassesEmptyLabel{
    if ([storedValueProducts count] > 0 || [filteredProdcutArray count] >0 ) {
        [self.tableView setHidden:NO];
        [emptyLabel setHidden:YES];
    }else{
        [self.tableView setHidden:YES];
        [emptyLabel setHidden:NO];
        if (!emptyLabel) {
            CGRect applicationFrame = [[UIScreen mainScreen] bounds];
            // Should only ever happen if there is a server request error on the very first load of this View Controller
            //            CGRect applicationFrame = [[UIScreen mainScreen] bounds];
            emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,self.view.frame.size.height / 2.0, self.view.frame.size.width - 2 * 20, 30)];
            [emptyLabel setText:[Utilities stringResourceForId:@"no_products"]];
            [emptyLabel setTextAlignment:NSTextAlignmentCenter];
            [emptyLabel setFont:[UIFont systemFontOfSize:16]];
            [emptyLabel setNumberOfLines:0];
            [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
            //            [emptyLabel sizeToFit];
            //            [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
            //                                              (applicationFrame.size.height / 2) - NAVIGATION_BAR_HEIGHT -50)];
            [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                              (self.view.frame.size.height / 2) - (emptyLabel.frame.size.height/2))];
            [self.view addSubview:emptyLabel];
        }
    }
}
-(void)preparingWallet:(Product*)prod{
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    WalletContents *passesWC;
    if(wallet_Contents1.count>0){
        passesWC=wallet_Contents1.firstObject;
    }
    if(passesWC){
        Product *prod=[filteredProdcutArray objectAtIndex:SelectedIndexpath.row];
        if (isBonusRide==NO&&isCappedRide==NO){
            passesWC.balance=[NSString stringWithFormat:@"%.2f",passesWC.balance.floatValue-prod.price.floatValue];
        }
        [self.balanceLabel setText:[NSString stringWithFormat:@"Balance: $%.2f", [passesWC.balance floatValue]]];
        WalletContents *wc = (WalletContents *)[NSEntityDescription insertNewObjectForEntityForName:WALLET_CONTENT_MODEL inManagedObjectContext:self.managedObjectContext];
        if (isBonusRide||isCappedRide){
            wc.fare = 0;
        }else{
            wc.fare=[NSNumber numberWithDouble:prod.price.doubleValue];
        }
        wc.ticketGroup=passesWC.ticketGroup;
        wc.member=passesWC.member;
        wc.agencyId=passesWC.agencyId;
        wc.descriptation=passesWC.descriptation;
        wc.type=passesWC.type;
        wc.ticketIdentifier=[prod.ticketId stringValue];
        wc.allowInteraction=[NSNumber numberWithBool:true];
        wc.designator=[NSNumber numberWithDouble:prod.designator.doubleValue];
        wc.identifier=[NSString stringWithFormat:@"%@$%lli",passesWC.identifier,milliseconds];
        wc.valueRemaining=passesWC.valueRemaining;
        wc.group=passesWC.group;
        wc.instanceCount=0;
        wc.status=ACTIVE;
        wc.purchasedDate=[NSNumber numberWithLong:milliseconds];
        wc.activationDate=[NSNumber numberWithLong:milliseconds];
        wc.generationDate=[NSNumber numberWithLong:milliseconds];
        wc.ticketEffectiveDate=[NSNumber numberWithLong:milliseconds];
        long exptime = (long long)([[NSDate date] timeIntervalSince1970] );
        wc.ticketActivationExpiryDate=[NSNumber numberWithLong:exptime+prod.barcodeTimer.longValue];
        wc.ticketSource=@"local";
        NSDateFormatter *df=[[NSDateFormatter alloc]init];
        [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        TicketActivation *ticketactivation = (TicketActivation *)[NSEntityDescription insertNewObjectForEntityForName:Activation_Model inManagedObjectContext:self.managedObjectContext];
        NSDate *expDate=[NSDate dateWithTimeIntervalSince1970:wc.ticketActivationExpiryDate.doubleValue];
        [ticketactivation setActivationDate:[df stringFromDate:[NSDate date]]];
        [ticketactivation setActivationExpDate:[df stringFromDate:expDate]];
        [ticketactivation setTicketIdentifier:prod.productId];
        NSError *saveError = nil;
        [self.managedObjectContext save:&saveError];
        TicketPageViewController *pageView = [[TicketPageViewController alloc] initWithNibName:@"TicketPageViewController" bundle:[NSBundle baseResourcesBundle]];
        [pageView setWalletContent:wc];
        [pageView setProduct:prod];
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
        [self.payAsYouGoController.navigationController pushViewController:pageView animated:YES];
    }
}
/*
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
 */
/*
 This is a dummy method - nned to be removed
 */
//-(void)resetBonusRidesByCount:(Product *)product{
//    LoyaltyBonus *bonus = [[Singleton sharedManager] getLoyalityBonusForProduct:product];
//    bonus.rideCount = [NSNumber numberWithInt:0];
//    bonus.activatedTime = [NSDate date];
//    bonus.productId = product.ticketId.stringValue;
//    NSError *error;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
//    }
//}

//-(void)resetCappedRidesByCount:(Product *)product{
//    LoyaltyBonus *bonus = [[Singleton sharedManager] getLoyalityCappedForProduct:product];
//    bonus.rideCount = [NSNumber numberWithInt:0];
//    bonus.activatedTime = [NSDate date];
//    bonus.productId = product.ticketId.stringValue;
//    NSError *error;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
//    }
//}
//-(void)updateEntryForBonusLoyalty:(LoyaltyBonus *)bonus withProduct:(Product *)product andCount:(int)count{
//    bonus.rideCount = [NSNumber numberWithInt:count];
//    bonus.activatedTime = [NSDate date];
//    bonus.productId = product.ticketId.stringValue;
//    NSError *error;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
//    }
//}
#pragma mark - UITableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Products";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [filteredProdcutArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"PayAsYouGoCell";
    PayAsYouGoCell *cell = (PayAsYouGoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Product *prod = [filteredProdcutArray objectAtIndex:indexPath.row ];
    cell.prod=prod;
    if(prod.price.floatValue > 0){
        [cell.totalFareLabel setText:[NSString stringWithFormat:@"Fare: $ %.2f",prod.price.floatValue]];
    }
    [cell startTimer];
    [cell.ticketTypeLabel setText:prod.productDescription];
    [cell.descriptionLabel setText:prod.productDescription];
    if (cell.activationsLabel.text.length > 0) {
        cell.activationsLabelWidthConstraint.constant = 98;
    }else{
        cell.activationsLabelWidthConstraint.constant = 0;
    }
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
    // [self preparingWallet:prod];
    WalletContents *passesWC;
    if(wallet_Contents1.count>0){
        passesWC=wallet_Contents1.firstObject;
    }
    isBonusRide = [[Singleton sharedManager] isProductEligibleForBonusFreeRide:prod];
    isCappedRide = [[Singleton sharedManager] isProductEligibleForCappedRide:prod ];
    currentBalance= passesWC.balance.floatValue;
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
    }
    else {
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}
#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self activatepayasYougo];
    }
}
#pragma mark - UIButton Action Methods
- (IBAction)addValue:(id)sender{
    TicketsListViewController *ticketview = [[TicketsListViewController alloc]initWithNibName:@"TicketsListViewController" bundle:nil];
    [ticketview setManagedObjectContext:self.managedObjectContext];
    //   [self.ticketsController.navigationController pushViewController:ticketview animated:YES];
    [self.payAsYouGoController.navigationController pushViewController:ticketview animated:YES];
}
#pragma mark - Service Call Success method
- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
    if([service isMemberOfClass:[GetWalletContents class]]){
        [self fetchingWalletContentsFromDB];
    }else if ([service isMemberOfClass:[GetWalletContentUsagePayAsYouGo class]]) {
    }else if ([service isMemberOfClass:[GetStoredValueProductsService class]]) {
        if ([storedValueProducts count] > 0) {
            [self.tableView setHidden:NO];
            [emptyLabel setHidden:YES];
            [self.tableView reloadData];
        } else {
            [self displayPassesEmptyLabel];
        }
        if (syncAlertView) {
            [syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
            syncAlertView = nil;
        } else if (spinner) {
            [spinner stopAnimating];
            spinner = nil;
        }
        [self showFirstTimeMessage];
    }
    //   else if([service isMemberOfClass:[AccountBalance class]]){
    //       NSString *accbalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountbalance"];
    //       [self updateBalanceViewColor:accbalance];
    //       self.balanceLabel.text=[NSString stringWithFormat:@"Account Balance : $%.2f",accbalance.floatValue];
    //   }
}
#pragma mark - Service Call Error method
- (void)threadErrorWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    [self threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetWalletContentUsagePayAsYouGo class]]) {
    }
}
#pragma mark - Other methods
- (void)updateBalanceViewColor{
    wallet_Contents1= [[NSMutableArray alloc] initWithArray:[self getPassesFromWalletContent]];
    WalletContents *wc=wallet_Contents1.firstObject;
    self.balanceLabel.text=[NSString stringWithFormat:@"Account Balance : $%.2f",[wc balance].floatValue];
    if ([wc.balance floatValue] < 5.0f) {
        [self.balanceContainerView setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"balance_red"]]];
    }else {
        [self.balanceContainerView setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"balance_green"]]];
    }
}
@end
