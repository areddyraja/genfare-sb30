//
//  Singleton.m
//  CDTATicketing
//
//  Created by Omniwyse on 4/4/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "Singleton.h"
#import "Account.h"
#import "CooCooAccountUtilities1.h"
#import "Product.h"
#import "WalletActivity.h"
#import "PayAsYouGoCell.h"
#import "LoyaltyCapped.h"
#import "LoyaltyBonus.h"
int const APP_UPDATE_TAG = 99;

@interface Singleton()
    @property BOOL _isAppOpened;
@end

@implementation Singleton

+ (id)sharedManager {
    static Singleton *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:sharedMyManager selector:@selector(logoutUserIFfWalletInActive) name:@"logoutuser" object:nil];
    });
    return sharedMyManager;
}
@synthesize isAppUpdateAlertPresented;


-(void)logoutUserIFfWalletInActive
{
    
    [self logOutHandler];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Logout"
                                 message:@"Your wallet is suspended.You will be loggout from app."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    // [self logOutHandler];
                                    [(UINavigationController*)[self topViewController]   popToRootViewControllerAnimated:true];
                                }];
    
    
    
    [alert addAction:yesButton];
    
    
    [[self topViewController]   presentViewController:alert animated:YES completion:nil];
    
    
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)viewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navContObj = (UINavigationController*)viewController;
        return [self topViewControllerWithRootViewController:navContObj.visibleViewController];
    } else if (viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed) {
        UIViewController* presentedViewController = viewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    else {
        for (UIView *view in [viewController.view subviews])
        {
            id subViewController = [view nextResponder];
            if ( subViewController && [subViewController isKindOfClass:[UIViewController class]])
            {
                if ([(UIViewController *)subViewController presentedViewController]  && ![subViewController presentedViewController].isBeingDismissed) {
                    return [self topViewControllerWithRootViewController:[(UIViewController *)subViewController presentedViewController]];
                }
            }
        }
        UINavigationController *navController=viewController.navigationController;
        if(navController){
            return navController;
        }
        
        return viewController;
    }
}

-(UIColor*)getYellowThemeColor{
    return  [UIColor colorWithRed:230.0/255.0 green:172.0/255.0 blue:16.0/255.0 alpha:1.0];
}

-(BOOL)isProfileAccountBased:(NSManagedObjectContext*)context{
    Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:context];
    if([loggedInAccount.profileType isEqualToString:@"Account-Based"]){
        loggedInAccount.profileType = @"ACCOUNT_BASED";
    }
    BOOL cond =  [loggedInAccount.profileType isEqualToString:@"ACCOUNT_BASED"];
    [[NSUserDefaults standardUserDefaults] setBool:cond forKey:@"accountbased"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return cond;
}


-(void)setUserWalletFromApi:(WalletContent*)wallet{
    self.userwallet=wallet;
    //    if(wallet.accMemberId&&wallet.accTicketGroupId){
    if (![wallet.accMemberId isEqual:[NSNull null]] || ![wallet.accTicketGroupId isEqual:[NSNull null]]) {
        [[NSUserDefaults standardUserDefaults] setObject:wallet.accMemberId forKey:@"accmemberid"];
        [[NSUserDefaults standardUserDefaults] setObject:wallet.accTicketGroupId forKey:@"accticketgroupid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(LoyaltyCapped*) getLoyalityCappedForProduct:(Product *)product  {
    
    if(product.productDescription==nil||[product.productDescription isKindOfClass:[NSNull class]]||[product.productDescription isEqualToString:@"(null)"] || [product.productDescription isEqualToString:@""]){
        return nil;
    }
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_CAPPED_MODEL inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    
    NSString *walletid = [[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"] stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@ && walletId == %@", product.ticketId.stringValue,walletid];
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"activatedTime" ascending:YES];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    
    NSArray *cappedArray = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Capped Loyalty: %@", cappedArray);
    
    LoyaltyCapped *capped ;
    if(cappedArray.count == 0 ){
        capped = (LoyaltyCapped *)[NSEntityDescription insertNewObjectForEntityForName:LOYALTY_CAPPED_MODEL inManagedObjectContext:self.managedContext];
        capped.rideCount = [NSNumber numberWithInt:0];
        capped.activatedTime= nil;
        capped.productId = product.ticketId.stringValue;
        capped.productName=product.productDescription;
        capped.referenceActivatedTime = [NSDate dateWithTimeIntervalSince1970:0];
        capped.walletId = walletid;
        NSError *error1;
        if (![self.managedContext save:&error1]) {
            NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
        }
    } else {
        capped = (LoyaltyCapped *)[cappedArray lastObject];
    }
    return capped;
}
-(LoyaltyBonus*) getLoyalityBonusForProduct:(Product *)product  {
    if(product.productDescription==nil||[product.productDescription isKindOfClass:[NSNull class]]||[product.productDescription isEqualToString:@"(null)"] || [product.productDescription isEqualToString:@""]){
        return nil;
    }
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_BONUS_MODEL inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    
    NSString *walletid = [[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"] stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@ && walletId == %@", product.ticketId.stringValue,walletid];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"activatedTime" ascending:YES];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    
    NSArray *bonusArray = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    //    NSLog(@"Bonus Loyalty: %@", bonusArray);
    
    LoyaltyBonus *bonus ;
    if(bonusArray.count == 0 ){
        bonus = (LoyaltyBonus *)[NSEntityDescription insertNewObjectForEntityForName:LOYALTY_BONUS_MODEL inManagedObjectContext:self.managedContext];
        bonus.rideCount = [NSNumber numberWithInt:0];
        bonus.activatedTime = nil;
        bonus.referenceActivatedTime = [NSDate dateWithTimeIntervalSince1970:0];
        bonus.productId = product.ticketId.stringValue;
        bonus.productName=product.productDescription;
        bonus.walletId = walletid;
        NSError *error1;
        if (![self.managedContext save:&error1]) {
            NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
        }
    } else {
        bonus = (LoyaltyBonus *)[bonusArray lastObject];
    }
    return bonus;
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

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    return YES;
}

-(NSDate*)getReferenceDateForoffset:(int)offset activatedDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    if(hour*60+minute<offset)
    {
        dayComponent.day = -1;
    }
    else{
        dayComponent.day = 0;
    }
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    return [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
}


-(BOOL)isProductEligibleForCappedRide:(Product *)product{
    BOOL isCappedRide = NO;
    int cappedDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_DELAY"]).intValue;;
    long cappedThreshold = product.cappedThreshold.integerValue;
    if(cappedThreshold==-1 || cappedThreshold == 0){
        return NO;
    }
    int offset = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"OFFSET_VALUE"]).intValue;
    LoyaltyCapped *capped = [self getLoyalityCappedForProduct:product];
    //NSLog(@"capped ride count %@",capped.rideCount);
    NSDate *refDate=[self getReferenceDateForoffset:offset activatedDate:capped.activatedTime?capped.activatedTime:[NSDate date]];
    
    
    if ([self checkActivationTimeInLimits:refDate offset:offset]) {
        if (capped.rideCount.intValue >= cappedThreshold) {
            NSDate *currentDate = [NSDate date];
            if([currentDate timeIntervalSinceDate:capped.referenceActivatedTime]>cappedDelay){
                isCappedRide = YES;
            }
        }
    }
    return isCappedRide;
}

-(BOOL)isProductEligibleForBonusFreeRide:(Product *)product  {
    
    BOOL isFreeRide = NO;
    long bonusThreshold = product.bonusThreshold.integerValue;
    
    if(bonusThreshold==-1 || bonusThreshold == 0){
        return NO;
    }
    LoyaltyBonus *bonus = [self getLoyalityBonusForProduct:product];
    
    if (bonus.rideCount.intValue >= bonusThreshold   ) {
        isFreeRide = YES;
    }
    return isFreeRide;
}


-(void)checkProductsFOrCell:(NSArray*)array{
    if (array.count != 2) {
        return;
    }
    PayAsYouGoCell *cell=array[0];
    Product *prod=array[1];
    [self deleteCappedProducts:prod];
    [cell.ticketTypeLabel setText:prod.productDescription];
    [cell.descriptionLabel setText:prod.productDescription];
    if(prod.price.floatValue > 0){
        [cell.totalFareLabel setText:[NSString stringWithFormat:@"Fare: $ %.2f",prod.price.floatValue]];
    }
    if(prod.price.doubleValue == 0){
        [cell.activationsLabel setText:[NSString stringWithFormat:@""]];
        return;
    }
    [cell.activationsLabel setText:[self displayCellText:prod]];
}
-(NSString *)displayCellText:(Product *)product{
    NSString * dislayString;
    LoyaltyBonus *bonus = [self getLoyalityBonusForProduct:product];
    LoyaltyCapped *capped = [self getLoyalityCappedForProduct:product];
    BOOL is_capped =[self isProductEligibleForCappedRide:product];
    BOOL is_bonus=[self isProductEligibleForBonusFreeRide:product];
    int cappedDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_DELAY"]).intValue;
    int bonusDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_DELAY"]).intValue;
    long cappedThreshold = product.cappedThreshold.integerValue;
    long bonusThreshold = product.bonusThreshold.integerValue;
    
    if (is_bonus == NO && is_capped == NO) {
        if([[NSDate date] timeIntervalSinceDate:capped.referenceActivatedTime]<cappedDelay && capped.rideCount.integerValue == cappedThreshold){
            return [self stringForCappedToGetFreeRide:capped];
        }else{
            if (cappedThreshold !=-1) {
                return [self stringForCappedToEarnFreeRide:capped Product:product];
            }else if (bonusThreshold != -1 && cappedThreshold == -1){
                return [self stringForBonusToEarnFreeRide:bonus Product:product];
            }else{
                return @"";
            }
        }
    }else if (is_capped == YES || is_bonus == YES){
        return @"The next ride\nis free!";
    }
    return dislayString;
}
-(NSString *)stringForCappedToGetFreeRide:(LoyaltyCapped *)capped{
    int cappedDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_DELAY"]).intValue;
    long delaytimelimit = (long)[[NSDate date]timeIntervalSinceDate:capped.referenceActivatedTime];
    long timelimit = cappedDelay- delaytimelimit;
    long minutes =  timelimit/60;
    long seconds = timelimit%60;
    if(minutes>0){
        return [NSString stringWithFormat:@"Wait for %.0ld minutes to get a free ride",minutes];
    }else if (seconds>0){
        return [NSString stringWithFormat:@"Wait for %.0ld seconds to get a free ride",seconds];
    }else{
        return @"";
    }
}
-(NSString *)stringForCappedToEarnFreeRide:(LoyaltyCapped *)capped Product:(Product *)product{
    int cappedDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_DELAY"]).intValue;
    long cappedThreshold = product.cappedThreshold.integerValue;
    if (capped.activatedTime == nil) {
        if (cappedThreshold == -1 || cappedThreshold == 0) {
            return @"";
        }
        return [NSString stringWithFormat:@"%li more activations for free ride",cappedThreshold-capped.rideCount.integerValue];
    }
    long delaytimelimit = (long)[[NSDate date]timeIntervalSinceDate:capped.activatedTime?capped.activatedTime:[NSDate date]];
    long timelimit = cappedDelay- delaytimelimit;
    long minutes =  timelimit/60;
    long seconds = timelimit%60;
    if(minutes>0){
        return [NSString stringWithFormat:@"%.0ld minutes untill activations can earn free rides",minutes];
    }else if (seconds>0){
        return [NSString stringWithFormat:@"%.0ld Seconds untill activations can earn free rides",seconds];
    }else{
        return [NSString stringWithFormat:@"%li more activations for free ride",cappedThreshold-capped.rideCount.integerValue];
    }
}
-(NSString *)stringForBonusToEarnFreeRide:(LoyaltyBonus *)bonus Product:(Product *)product{
    int bonusDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_DELAY"]).intValue;
    long bonusThreshold = product.bonusThreshold.integerValue;
    if (bonusThreshold == -1 || bonusThreshold == 0) {
        return @"";
    }
    long delaytimelimit = (long)[[NSDate date]timeIntervalSinceDate:bonus.activatedTime?bonus.activatedTime:[NSDate date]];
    long timelimit = bonusDelay- delaytimelimit;
    long minutes =  timelimit/60;
    long seconds = timelimit%60;
    if(minutes>0){
        return [NSString stringWithFormat:@"%.0ld minutes untill activations can earn free rides",minutes];
    }else if (seconds>0){
        return [NSString stringWithFormat:@"%.0ld Seconds untill activations can earn free rides",seconds];
    }else{
        return [NSString stringWithFormat:@"%li more activations for free ride",bonusThreshold-bonus.rideCount.integerValue];
    }
}




-(void)isCappedValidForIncrement:(Product*)prod{
    int offset = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"OFFSET_VALUE"]).intValue;
    LoyaltyCapped *capped = [self getLoyalityCappedForProduct:prod];
    long cappedThreshold = prod.cappedThreshold.integerValue;
    NSDate * referenceValidationDate = [self getReferenceDateForoffset:offset activatedDate:capped.activatedTime?capped.activatedTime:[NSDate date]];
    if([self checkActivationTimeInLimits:referenceValidationDate offset:offset]){
        int cappedDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_DELAY"]).intValue;;
        if([[NSDate date] timeIntervalSinceDate:capped.activatedTime]>= cappedDelay || capped.activatedTime == nil){
            if (![self isProductEligibleForCappedRide:prod] && capped.rideCount.integerValue<cappedThreshold && ![self isProductEligibleForBonusFreeRide:prod]) {
                [self incrementCappedRidesByCount:1 andProduct:prod];
                
            }
        }
    }
    else{
        [self deleteCappedProducts:prod];
    }
}
-(void)isBonusValidForIncrement:(Product*)prod{
    int offset = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"OFFSET_VALUE"]).intValue;
    LoyaltyBonus *bonus = [self getLoyalityBonusForProduct:prod];
    long bonusThreshold = prod.bonusThreshold.integerValue;
    //    NSDate * referenceValidationDate = [self getReferenceDateForoffset:offset activatedDate:bonus.activatedTime?bonus.activatedTime:[NSDate date]];
    int bonusDelay = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_DELAY"]).intValue;;
    if([[NSDate date] timeIntervalSinceDate:bonus.activatedTime] >= bonusDelay || bonus.activatedTime == nil){
        if (![self isProductEligibleForBonusFreeRide:prod] && bonus.rideCount.integerValue<bonusThreshold && ![self isProductEligibleForCappedRide:prod]) {
            [self incrementBonusRidesByCount:1 andProduct:prod];
        }
    }
}


-(void)deleteLoyalityCappedRide:(Product*)prod{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_CAPPED_MODEL  inManagedObjectContext:self.managedContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", prod.ticketId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSError *saveError = nil;
    NSArray *products = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    for (LoyaltyCapped *product in products) {
        [self.managedContext deleteObject:product];
    }
    [self.managedContext save:&saveError];
    
}
-(void)deleteLoyalityBonusRide:(Product*)prod{
    
    NSError *saveError = nil;
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_BONUS_MODEL inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", prod.ticketId.stringValue];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"activatedTime" ascending:YES];
    [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    
    NSArray *bonusArray = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    for (LoyaltyBonus *product in bonusArray) {
        [self.managedContext deleteObject:product];
        
    }
    [self.managedContext save:&saveError];
    
}
-(void)incrementCappedRidesByCount:(int)count andProduct:(Product *)product{
    LoyaltyCapped *capped = [self getLoyalityCappedForProduct:product];
    long cappedThreshold = product.cappedThreshold.integerValue;
    capped.rideCount = [NSNumber numberWithInt:([capped.rideCount intValue] + 1)];
    if (capped.rideCount.integerValue == cappedThreshold) {
        capped.referenceActivatedTime = [NSDate date];
    }
    capped.activatedTime=[NSDate date];
    capped.productName=product.productDescription;
    capped.productId = product.ticketId.stringValue;
    NSError *error;
    if (![self.managedContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    }
    
}


-(void)incrementBonusRidesByCount:(int)count andProduct:(Product *)product{
    LoyaltyBonus *bonus = [[Singleton sharedManager] getLoyalityBonusForProduct:product];
    bonus.rideCount = [NSNumber numberWithInt:([bonus.rideCount intValue] + count)];
    bonus.activatedTime=[NSDate date];
    bonus.productName=product.productDescription;
    bonus.productId = product.ticketId.stringValue;
    NSError *error;
    if (![self.managedContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    }
}
-(void)logOutHandler{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accmemberid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accticketgroupid"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_KEY_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WALLET_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:COMMON_KEY_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedContext];
    
    // Logout out of all accounts
    [CooCooAccountUtilities1 logoutAllAccounts:self.managedContext];
    
    // Remove account
    [CooCooAccountUtilities1 deleteAccountIfIdExists:account.accountId managedObjectContext:self.managedContext];
    [self deleteAllTickets];
    [self deleteAllproducts];
    [self deleteAllproductModel];
    [self deleteAllWalletActitity];
    [self deleteAllLoyaltyCapped];
    [self deleteAllLoyaltyBonus];
    // [passesWithStatusDictionary removeAllObjects];
    
}


-(void)deleteAllWalletActitity{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:WALLET_ACTIVITY_MODEL
                                              inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *WalletActivities = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    
    NSError *saveError = nil;
    
    for(WalletActivity *walletActivity in WalletActivities){
        [self.managedContext deleteObject:walletActivity];
    }
    [self.managedContext save:&saveError];
}

-(void)deleteAllTickets{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TICKET_MODEL
                                              inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *tickets = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    
    NSError *saveError = nil;
    
    for(Ticket *ticket in tickets){
        [self.managedContext deleteObject:ticket];
    }
    [self.managedContext save:&saveError];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"ticketSourceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)deleteAllproducts{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:WALLET_CONTENT_MODEL  inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSError *saveError = nil;
    NSArray *products = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    for (Product *product in products) {
        [self.managedContext deleteObject:product];
    }
    [self.managedContext save:&saveError];
    
}
-(void)deleteAllproductModel{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:PRODUCT_MODEL  inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSError *saveError = nil;
    NSArray *products = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    for (Product *product in products) {
        [self.managedContext deleteObject:product];
    }
    [self.managedContext save:&saveError];
    
}

-(void)deleteCappedProducts:(Product *)product{
    LoyaltyCapped *capped = [self getLoyalityCappedForProduct:product];
    if(capped==nil||capped.activatedTime==nil){
        return;
    }
    int offset = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"OFFSET_VALUE"]).intValue;
    
    if (![self checkActivationTimeInLimits:[self getReferenceDateForoffset:offset activatedDate:capped.activatedTime] offset:offset]) {
        [self deleteLoyalityCappedRide:product];
    }else{
    }
}
-(void)deleteAllLoyaltyCapped{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_CAPPED_MODEL
                                              inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *loyaltyCapped = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    
    NSError *saveError = nil;
    
    for(LoyaltyCapped *capped in loyaltyCapped){
        [self.managedContext deleteObject:capped];
    }
    [self.managedContext save:&saveError];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"ticketSourceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)deleteAllLoyaltyBonus{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:LOYALTY_BONUS_MODEL
                                              inManagedObjectContext:self.managedContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *loyaltyBonus = [self.managedContext executeFetchRequest:fetchRequest error:&error];
    
    NSError *saveError = nil;
    
    for(LoyaltyBonus *bonus in loyaltyBonus){
        [self.managedContext deleteObject:bonus];
    }
    [self.managedContext save:&saveError];
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"ticketSourceId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isAppOpened {
    return __isAppOpened;
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"appOpenedStatusForSideMenu"];
}

-(void)setIsAppOpened:(BOOL)isAppOpened {
    __isAppOpened = isAppOpened;
    return;
    [[NSUserDefaults standardUserDefaults] setBool:isAppOpened forKey:@"appOpenedStatusForSideMenu"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)showAlert:(NSString*)title message:(NSString*)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.alert){
            [self.alert dismissWithClickedButtonIndex:0 animated:NO];
            self.alert=nil;
        }
        self.alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [self.alert setTag:APP_UPDATE_TAG];
        [self.alert show];
    });
}
#pragma mark - UIAlertView Delegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == APP_UPDATE_TAG) {
        if (buttonIndex == 0) {
            //            [alertView dismissWithClickedButtonIndex:1 animated:YES];
            if ([[[Utilities apiEnvironment] lowercaseString] containsString:@"st"]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities stagingLink]]]];
            }else if ([[[Utilities apiEnvironment] lowercaseString] containsString:@"ua"]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities uatLink]]]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities appstoreLink]]]];
            }
            self.alert = nil;
        }
    }
}
@end
