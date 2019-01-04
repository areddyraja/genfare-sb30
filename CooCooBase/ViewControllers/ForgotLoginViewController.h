//
//  ForgotLoginViewController.h
//  CooCooBase
//
//  Created by John Scuteri on 5/29/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "ForgotPasswordService.h"

@interface ForgotLoginViewController : BaseViewController <UITextFieldDelegate, UIAlertViewDelegate, ServiceListener>

@property (strong, nonatomic) NSString *defaultEmail;
@property (weak, nonatomic) IBOutlet UITextField *fieldEmail;

- (IBAction)buttonReset:(id)sender;

@end
