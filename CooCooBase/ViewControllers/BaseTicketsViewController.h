//
//  BaseTicketsViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 10/6/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "BasePageViewController.h"

@interface BaseTicketsViewController : BaseViewController

@property (nonatomic, copy) BasePageViewController *(^createCustomBarcodeViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomSecurityViewController)();
-(UIColor *)colorFromHexString:(NSString *)hexString;
-(void)refreshView;

@end
