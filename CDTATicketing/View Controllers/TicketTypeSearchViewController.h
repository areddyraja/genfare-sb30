//
//  TicketTypeSearchViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 8/26/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "CooCooBase.h"
#import "StoredValueProduct.h"

@protocol OnTicketTypeSelectedListener <NSObject>

- (void)onTicketTypeSelected:(StoredValueProduct *)storedValueProduct;

@end

@interface TicketTypeSearchViewController : BaseViewController <ServiceListener, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id <OnTicketTypeSelectedListener> listener;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) NSString *cardId;

@end
