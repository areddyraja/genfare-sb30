//
//  ChangeEmailViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//



#import "BaseViewController.h"
#import "ChangeEmailService.h"

@interface ChangeEmailViewController : BaseViewController <UITextFieldDelegate, ServiceListener, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;

- (IBAction)changeEmail:(id)sender;

@end
