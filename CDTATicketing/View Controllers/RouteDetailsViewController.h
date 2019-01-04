//
//  RouteDetailsViewController.h
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import <QuickLook/QuickLook.h>
#import "GetStopsService.h"
#import "Route.h"

@interface RouteDetailsViewController : CDTABaseViewController <ServiceListener, UITableViewDataSource, UITableViewDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *routeBadge;
@property (weak, nonatomic) IBOutlet UILabel *routeName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Route *route;
@property (weak, nonatomic) IBOutlet BorderedButton *scheduleButtonProperty;
@property (weak, nonatomic) IBOutlet BorderedButton *mapButtonProperty;
@property (weak, nonatomic) IBOutlet BorderedButton *aboutButtonProperty;

- (IBAction)viewSchedule:(id)sender;
- (IBAction)viewMap:(id)sender;
- (IBAction)viewDescription:(id)sender;

@end
