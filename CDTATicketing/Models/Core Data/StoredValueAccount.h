//
//  StoredValueAccount.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/7/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueAccount : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

FOUNDATION_EXPORT NSString *const STORED_VALUE_ACCOUNT_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "StoredValueAccount+CoreDataProperties.h"
