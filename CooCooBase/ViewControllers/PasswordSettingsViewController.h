//
//  PasswordSettingsViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 7/23/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "BaseSettingsViewController.h"
#import "ChangePasswordService.h"
#import "LoginService.h"

@interface PasswordSettingsViewController : BaseSettingsViewController <UITextFieldDelegate, ServiceListener, UIAlertViewDelegate>

@end
