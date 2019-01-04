//
//  StopInfoViewController.h
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "GetArrivalsService.h"
#import "Stop.h"

@interface StopInfoViewController : CDTABaseViewController <ServiceListener, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *stopNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet BorderedButton *originButton;
@property (weak, nonatomic) IBOutlet BorderedButton *destinationButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
               stopId:(int)stopId
             stopName:(NSString *)stopName
           servicedBy:(NSString *)servicedBy
             latitude:(double)latitude
            longitude:(double)longitude;
- (IBAction)planOrigin:(id)sender;
- (IBAction)planDestination:(id)sender;

@end
