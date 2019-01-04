//
//  TicketPurchaseViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseTicketPurchaseController.h"
#import "BaseTicketsViewController.h"
#import "BasePageViewController.h"

@interface TicketPurchaseViewController : BaseTicketPurchaseController <UIWebViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *webMessageLabel;
@property (weak, nonatomic) NSString *departStation;
@property (weak, nonatomic) NSString *arriveStation;

@end
