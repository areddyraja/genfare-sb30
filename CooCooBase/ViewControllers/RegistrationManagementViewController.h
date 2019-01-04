//
//  RegistrationManagementViewController.h
//  CooCooBase
//
//  Created by John Scuteri on 9/11/14.
//  Updated by AK on 12/3/15
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BorderedButton.h"
#import "BaseService.h"
#import "BaseViewController.h"

@interface RegistrationManagementViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, ServiceListener>

@property (weak, nonatomic) IBOutlet UITextField *phoneNameTextField;
@property (weak, nonatomic) IBOutlet BorderedButton *registerThisDeviceButtonProperties;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;

- (IBAction)registerThisDevice:(id)sender;

@end
