//
//  CardSelectionViewController.h
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 3/23/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface CardSelectionViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ServiceListener>

@property (weak, nonatomic) IBOutlet UITableView *cardTableView;

@end
