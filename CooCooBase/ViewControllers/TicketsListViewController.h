//
//  TicketsListViewController.h
//  CooCooBase
//
//  Created by ibasemac3 on 12/14/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "Reachability.h"
#import <CoreData/CoreData.h>

@interface TicketsListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,ServiceListener>
@property (weak, nonatomic) IBOutlet UITableView *productsTableView;
@property (weak, nonatomic) IBOutlet UILabel *mailLabel;
@property (weak, nonatomic) IBOutlet UITextField *payasgoTextfield;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UILabel *pageButton1;
@property (weak, nonatomic) IBOutlet UILabel *pageButton2;
@property (weak, nonatomic) IBOutlet UILabel *pageButton3;
@property (weak, nonatomic) IBOutlet UILabel *pageButton4Done;

@property (strong) UIViewController *ticketsController;
@end
