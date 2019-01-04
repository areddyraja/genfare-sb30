//
//  StoredValueProduct.h
//  CDTATicketing
//
//  Created by CooCooTech on 3/28/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StoredValueLoyalty;

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueProduct : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

FOUNDATION_EXPORT NSString *const STORED_VALUE_PRODUCT_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "StoredValueProduct+CoreDataProperties.h"
