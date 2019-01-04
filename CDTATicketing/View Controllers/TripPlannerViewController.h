//
//  TripPlannerViewController.h
//  CDTA
//
//  Created by CooCooTech on 10/10/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "GetNearbyStopsService.h"
#import "RoutesSearchViewController.h"

@interface TripPlannerViewController : CDTABaseViewController <UITextFieldDelegate, OnSearchedStopSelectedListener, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, ServiceListener>

@property (weak, nonatomic) IBOutlet UIImageView *nearbyImage;
@property (weak, nonatomic) IBOutlet UITextField *fromText;
@property (weak, nonatomic) IBOutlet UIImageView *switchImage;
@property (weak, nonatomic) IBOutlet UITextField *toText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *leaveSegment;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UITextField *timeText;
@property (weak, nonatomic) IBOutlet BorderedButton *planTripButton;

- (IBAction)planTrip:(id)sender;

@end
