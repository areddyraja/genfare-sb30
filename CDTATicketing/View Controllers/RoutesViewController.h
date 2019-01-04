//
//  RoutesViewController.h
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "CooCooBase.h"

@interface RoutesViewController : CDTABaseViewController <ServiceListener, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
