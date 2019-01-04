//
//  Wallet.h
//  CooCooBase
//
//  Created by CooCooTech on 4/15/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Wallet : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
FOUNDATION_EXPORT NSString *const WALLET_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "Wallet+CoreDataProperties.h"

