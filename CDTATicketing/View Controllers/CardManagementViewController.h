//
//  CardManagementViewController.h
//  CooCooBase
//
//  Created by AK on 3/15/16.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "CooCooBase.h"
#import "BorderedButton.h"

@interface CardManagementViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, ServiceListener>

@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;

@end
