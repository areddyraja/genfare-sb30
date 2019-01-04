//
//  WalletListAccountBaseViewController.h
//  CDTATicketing Beta
//
//  Created by Gaian Solutions on 4/12/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AccountBaseViewController.h"
@interface WalletListAccountBaseViewController : AccountBaseViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
