//
//  AddAccountViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 9/20/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "BorderedButton.h"
#import "CAPSPageMenu.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"


@interface AddAccountViewController : BaseViewController<CAPSPageMenuDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *emailAddress;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *password;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *confirmPassword;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *firstName;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *lastName;
@property (unsafe_unretained, nonatomic) IBOutlet BorderedButton *actionButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *forgotPassword;
@property (unsafe_unretained, nonatomic)  UIViewController *addController;


- (IBAction)existingOrCreate:(id)sender;
- (IBAction)addAccount:(id)sender;

@end
