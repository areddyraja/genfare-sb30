//
//  TripRoutesViewController.h
//  CDTA
//
//  Created by CooCooTech on 12/18/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"

@interface TripRoutesViewController : CDTABaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *originName;
@property (nonatomic) NSInteger originId;
@property (strong, nonatomic) NSString *destinationName;
@property (nonatomic) NSInteger destinationId;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
