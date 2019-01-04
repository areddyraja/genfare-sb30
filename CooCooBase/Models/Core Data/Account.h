//
//  Account.h
//  CooCooBase
//
//  Created by Alfonso Cejudo on 10/7/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Account : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
FOUNDATION_EXPORT NSString *const ACCOUNT_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "Account+CoreDataProperties.h"
