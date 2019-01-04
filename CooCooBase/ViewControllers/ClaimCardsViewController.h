//
//  ClaimCardsViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 9/19/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginService.h"

@interface ClaimCardsViewController : BaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ServiceListener>

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *selectOrEnterEmail;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *password;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *forgotPassword;

- (IBAction)viewCards:(id)sender;

@end
