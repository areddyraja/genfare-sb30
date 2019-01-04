//
//  TicketBarcodeViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePageViewController.h"
 #import "WalletContents.h"
#import "Product.h"
#import "Reachability.h"

@interface TicketBarcodeViewController : BasePageViewController

@property (strong, nonatomic) NSString *cardAccountId;
@property(strong,nonatomic) WalletContents *walletContent;
@property(strong,nonatomic) Product *product;

- (id)init;

@end
