//
//  AssignCardsViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 9/22/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseService.h"

@interface AssignCardsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ServiceListener>

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *header;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@end
