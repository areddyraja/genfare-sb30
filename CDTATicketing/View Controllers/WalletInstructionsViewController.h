//
//  WalletInstructionsViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 9/20/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "CooCooBase.h"

@interface WalletInstructionsViewController : CDTABaseViewController <ServiceListener,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *cardName;
@property (weak, nonatomic) IBOutlet UITextField *cardDescription;

- (IBAction)createNewCard:(id)sender;
-(IBAction)closeWalletWindow:(id)sender;
- (IBAction)claimProvisionedCard:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end
