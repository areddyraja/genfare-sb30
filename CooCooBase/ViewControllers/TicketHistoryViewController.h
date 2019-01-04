//
//  TicketHistoryViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "BasePageViewController.h"
#import "BaseService.h"

@interface TicketHistoryViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, ServiceListener>

@property (nonatomic, copy) BasePageViewController *(^createCustomBarcodeViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomSecurityViewController)();
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *ticketSourceId;
@property (strong) UIViewController *ticketsController;

- (void)loadHistory;

@end
