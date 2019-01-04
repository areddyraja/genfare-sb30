//
//  BasePageViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 4/13/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ticket.h"
#import "WalletContents.h"
#import "BaseViewController.h"
#import "Product.h"
@interface BasePageViewController : BaseViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) int pageIndex;
@property(strong,nonatomic) WalletContents *walletContent;
@property(strong,nonatomic) Product *product;

@end
