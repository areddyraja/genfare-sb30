//
//  StoredValueLoyalty.h
//  CDTATicketing
//
//  Created by CooCooTech on 5/11/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueLoyalty : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

FOUNDATION_EXPORT NSString *const STORED_VALUE_LOYALTY_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "StoredValueLoyalty+CoreDataProperties.h"
