//
//  CDTA_AB_PayAsYouGoViewController.h
//  CDTATicketing
//
//  Created by Omniwyse on 4/4/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CooCooBase.h"
#import "TicketTypeSearchViewController.h"
#import "Reachability.h"
#import "AccountBaseViewController.h"

@interface CDTA_AB_PayAsYouGoViewController : AccountBaseViewController
@property (nonatomic, copy) BaseTicketsViewController *(^createCustomTicketsViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomBarcodeViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomSecurityViewController)();
  @property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *cardUuid;
@property (strong, nonatomic) NSString *cardAccountId;
@property (strong, nonatomic) UIViewController *payAsYouGoController;
@property (weak, nonatomic) IBOutlet BorderedButton *addValueButtonProperties;
@property (nonatomic,retain)NSManagedObjectContext * managedObjectContext;

- (IBAction)addValue:(id)sender;
- (void)loadAccountData;
- (void)loadLoyaltyInfo;
@end
