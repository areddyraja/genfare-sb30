//
//  WalletActivity.h
//  CooCooBase
//
//  Created by IBase Software on 29/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
NS_ASSUME_NONNULL_BEGIN

@interface WalletActivity : NSManagedObject
FOUNDATION_EXPORT NSString *const WALLET_ACTIVITY_MODEL;

@end
NS_ASSUME_NONNULL_END
#import "WalletActivity+CoreDataProperties.h"
