//
//  CDTA_AB_PassesViewController.h
//  CDTATicketing
//
//  Created by Omniwyse on 4/4/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>



#import "AccountBaseViewController.h"


#import "BaseTicketsViewController.h"
#import "BasePageViewController.h"
#import "BaseService.h"
#import "BorderedButton.h"
#import "CardSyncService.h"
#import "TicketSyncService.h"


@class CDTATicketsViewController;
@interface CDTA_AB_PassesViewController : AccountBaseViewController <UITableViewDelegate, UITableViewDataSource, ServiceListener, TicketSyncServiceListener, CardSyncServiceListener>

@property (nonatomic, copy) BaseTicketsViewController *(^createCustomTicketsViewController)();
@property (weak, nonatomic) IBOutlet BorderedButton *purchaseButtonProperties;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *cardAccountId;
@property (strong) UIViewController *ticketsController;
@property (nonatomic,retain)NSManagedObjectContext * managedObjectContext;

- (IBAction)purchaseButton:(id)sender;

@end
