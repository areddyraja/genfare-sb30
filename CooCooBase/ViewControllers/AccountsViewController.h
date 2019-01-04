//
//  AccountsViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 9/20/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseViewController.h"

@interface AccountsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addAccount:(id)sender;

@end
