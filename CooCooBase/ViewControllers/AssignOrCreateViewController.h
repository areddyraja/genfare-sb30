//
//  AssignOrCreateViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 9/22/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseService.h"
#import "BorderedButton.h"
#import "Card.h"

@interface AssignOrCreateViewController : BaseViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ServiceListener>

@property (nonatomic, weak) Card *card;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *selectOrEnterEmail;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *password;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *confirmPassword;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *firstName;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *lastName;
@property (unsafe_unretained, nonatomic) IBOutlet BorderedButton *actionButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *forgotPassword;

- (IBAction)existingOrCreate:(id)sender;
- (IBAction)assignOrCreate:(id)sender;

@end
