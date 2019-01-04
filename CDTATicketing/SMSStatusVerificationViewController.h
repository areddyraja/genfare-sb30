//
//  SMSStatusVerificationViewController.h
//  CDTATicketing
//
//  Created by Gaian Solutions on 5/8/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface SMSStatusVerificationViewController : BaseViewController
{
    IBOutlet UILabel *smsVerificationLbl;

}
@property (nonatomic,retain)NSManagedObjectContext * managedObjectContext;

@end
