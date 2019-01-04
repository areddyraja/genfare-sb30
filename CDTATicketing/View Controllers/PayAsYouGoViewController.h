//
//  PayAsYouGoViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 8/25/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "CooCooBase.h"
#import "TicketTypeSearchViewController.h"
#import "Reachability.h"

@interface PayAsYouGoViewController : BaseViewController <ServiceListener, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, copy) BaseTicketsViewController *(^createCustomTicketsViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomBarcodeViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomSecurityViewController)();
@property (weak, nonatomic) IBOutlet UIView *balanceContainerView;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *cardUuid;
@property (strong, nonatomic) NSString *cardAccountId;
@property (strong, nonatomic) UIViewController *payAsYouGoController;
@property (weak, nonatomic) IBOutlet BorderedButton *addValueButtonProperties;


- (IBAction)addValue:(id)sender;
- (void)loadAccountData;
- (void)loadLoyaltyInfo;

@end
