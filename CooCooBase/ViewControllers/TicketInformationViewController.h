//
//  TicketInformationViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePageViewController.h"
#import "Ticket.h"
#import "Product.h"

@interface TicketInformationViewController : BasePageViewController <UIAlertViewDelegate>

@property(strong,nonatomic) WalletContents *walletContent;
@property(strong,nonatomic) Product *product;
- (id)init;
- (void)setInformationDisplay;

@end
