//
//  Singleton.h
//  CDTATicketing
//
//  Created by Omniwyse on 4/4/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WalletContent.h"

#import "Product.h"
#import "PayAsYouGoCell.h"
#import "CDTA_AccountBasedViewController.h"
@interface Singleton : NSObject<UIAlertViewDelegate>
@property (nonatomic,retain)UINavigationController *currentNVC;
@property (nonatomic,retain)CDTA_AccountBasedViewController *ref_AccountBasedViewController;
@property (nonatomic,retain)WalletContent *userwallet;
@property (nonatomic, assign) BOOL isAppUpdateAlertPresented;
@property (nonatomic) BOOL isAppOpened;
@property (nonatomic) BOOL userJustLoggedIn;

+ (id)sharedManager;
-(BOOL)isProfileAccountBased:(NSManagedObjectContext*)context;
-(UIColor*)getYellowThemeColor;
-(void)checkProductsFOrCell:(NSArray*)array;

-(LoyaltyCapped*) getLoyalityCappedForProduct:(Product *)product;
-(LoyaltyBonus*) getLoyalityBonusForProduct:(Product *)product;
-(BOOL)isProductEligibleForBonusFreeRide:(Product *)product ;
-(BOOL)isProductEligibleForCappedRide:(Product *)product;
-(void)incrementCappedRidesByCount:(int)count andProduct:(Product *)product;
-(void)incrementBonusRidesByCount:(int)count andProduct:(Product *)product;
-(void)deleteLoyalityCappedRide:(Product*)prod;
-(void)deleteLoyalityBonusRide:(Product*)prod;
-(void)logOutHandler;
-(void)setUserWalletFromApi:(WalletContent*)wallet;
-(void)deleteCappedProducts:(Product *)product;
 -(void)isCappedValidForIncrement:(Product*)prod;
-(void)isBonusValidForIncrement:(Product*)prod;
@property UIAlertView *alert;
-(void)showAlert:(NSString*)title message:(NSString*)message;

@property (nonatomic,strong)NSManagedObjectContext *managedContext;
 @end
