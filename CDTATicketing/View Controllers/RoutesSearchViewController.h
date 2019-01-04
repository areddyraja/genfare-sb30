//
//  RoutesSearchViewController.h
//  CDTA
//
//  Created by CooCooTech on 10/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "SearchStopsService.h"
#import "Stop.h"
#import "StopsSearchViewController.h"

@protocol OnSearchedStopSelectedListener <NSObject>

- (void)onSearchedStopSelected:(int)stopId
                          name:(NSString *)name
                      arriving:(BOOL)arriving
                      latitude:(double)latitude
                     longitude:(double)longitude;

@end

@interface RoutesSearchViewController : CDTABaseViewController <UISearchBarDelegate, UISearchDisplayDelegate, ServiceListener, UITableViewDataSource, UITableViewDelegate, OnStopSelectedListener>

@property (weak, nonatomic) id <OnSearchedStopSelectedListener> listener;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL arriving;

@end
