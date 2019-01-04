//
//  SMSVerficationViewController.h
//  CDTATicketing
//
//  Created by Gaian Solutions on 5/8/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SMSVerficationViewController : BaseViewController{
    IBOutlet UILabel *smsVerificationLbl;
    IBOutlet UILabel *accountStatusLbl;
    IBOutlet UIButton *sendSMSBtn;
}
@property (nonatomic,retain)NSManagedObjectContext * managedObjectContext;

-(IBAction)sendSMS:(id)sender;
@end
