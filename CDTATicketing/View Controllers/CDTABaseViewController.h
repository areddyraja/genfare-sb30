//
//  CDTABaseViewController.h
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CooCooBase.h"

@interface CDTABaseViewController : BaseViewController <UIAlertViewDelegate>

@property (copy, nonatomic) NSString *viewName;
@property (copy, nonatomic) NSString *viewDetails;

@end
