//
//  ChangePasswordViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "ChangePasswordService.h"
#import "ChangeEmailService.h"

@interface ChangePasswordViewController : BaseViewController <UITextFieldDelegate, ServiceListener, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordText;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordText;

@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;

- (IBAction)changePassword:(id)sender;

@end
