//
//  StopsSearchViewController.h
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "GetStopsService.h"
#import "Stop.h"

@protocol OnStopSelectedListener <NSObject>

- (void)onStopSelected:(Stop *)stop arriving:(BOOL)arriving;

@end

@interface StopsSearchViewController : CDTABaseViewController <ServiceListener, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id <OnStopSelectedListener> listener;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int routeId;
@property (nonatomic) BOOL arriving;

@end
