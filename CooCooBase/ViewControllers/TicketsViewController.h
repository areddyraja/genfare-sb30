//
//  TicketsViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseTicketsViewController.h"
#import "BasePageViewController.h"
#import "BaseService.h"
#import "BorderedButton.h"
#import "CardSyncService.h"
#import "TicketSyncService.h"
#import "CAPSPageMenu.h"


@class CDTATicketsViewController;
@interface TicketsViewController : BaseTicketsViewController <UITableViewDelegate, UITableViewDataSource, ServiceListener, TicketSyncServiceListener, CardSyncServiceListener>

@property (nonatomic, copy) BaseTicketsViewController *(^createCustomTicketsViewController)();
@property (weak, nonatomic) IBOutlet BorderedButton *purchaseButtonProperties;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *cardAccountId;
@property (strong) UIViewController *ticketsController;

- (IBAction)purchaseButton:(id)sender;

@end
