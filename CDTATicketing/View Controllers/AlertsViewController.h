//
//  AlertsViewController.h
//  CDTA
//
//  Created by CooCooTech on 10/29/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "GetAlertsService.h"

@interface AlertsViewController : CDTABaseViewController <ServiceListener, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)setAlertsCount:(int)count;

@end
