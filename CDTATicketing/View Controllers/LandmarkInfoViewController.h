//
//  LandmarkInfoViewController.h
//  CDTA
//
//  Created by CooCooTech on 12/23/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "GetNearbyStopsService.h"

@interface LandmarkInfoViewController : CDTABaseViewController <ServiceListener, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (weak, nonatomic) IBOutlet UILabel *landmarkNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil landmarkName:(NSString *)landmarkName;
- (IBAction)planOrigin:(id)sender;
- (IBAction)planDestination:(id)sender;

@end
