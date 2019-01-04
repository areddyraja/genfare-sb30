//
//  RouteScheduleViewController.h
//  CDTA
//
//  Created by CooCooTech on 11/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "GetCDTASchedulesService.h"
#import "Route.h"

@interface RouteScheduleViewController : CDTABaseViewController <ServiceListener, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Route *route;

@end
