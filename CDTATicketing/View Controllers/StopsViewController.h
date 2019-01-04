//
//  StopsViewController.h
//  CDTA
//
//  Created by CooCooTech on 11/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "CooCooBase.h"
#import <CoreLocation/CoreLocation.h>

@interface StopsViewController : CDTABaseViewController <UISearchDisplayDelegate, ServiceListener, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
