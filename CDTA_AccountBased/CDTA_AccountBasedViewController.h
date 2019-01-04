//
//  CDTA_AccountBasedViewController.h
//  CDTATicketing
//
//  Created by Omniwyse on 4/4/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AccountBaseViewController.h"
#import "Utilities.h"

@interface CDTA_AccountBasedViewController : AccountBaseViewController
{
    IBOutlet UIView *addFundsView;
    IBOutlet UILabel *fundsLabel;
    IBOutlet UILabel *cardnameLabel;
    IBOutlet UIButton *addFundsButton;
    IBOutlet UIButton *cardManagementButton;
    NSArray *walletarray;
    int walletStatusId;
    UIAlertView *singleAlertView;
}
 @end
