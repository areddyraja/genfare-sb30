//
//  AccountSettingsViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "AuthorizeTokenService.h"
#import "BorderedButton.h"

@interface AccountSettingsViewController : BaseViewController <ServiceListener, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *verifiedLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet BorderedButton *storedValueButtonProperties;
@property (weak, nonatomic) IBOutlet BorderedButton *savedPaymentsProperties;
@property (weak, nonatomic) IBOutlet BorderedButton *viewDeviceRegistrationStatusProperties;

- (IBAction)goToWallet:(id)sender;
- (IBAction)changeEmail:(id)sender;
- (IBAction)changePassword:(id)sender;
- (IBAction)viewDeviceRegistration:(id)sender;
- (IBAction)storedValue:(id)sender;

@end
