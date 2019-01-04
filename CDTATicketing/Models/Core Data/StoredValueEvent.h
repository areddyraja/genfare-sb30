//
//  StoredValueEvent.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/7/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StoredValueAccount;

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueEvent : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

FOUNDATION_EXPORT NSString *const STORED_VALUE_EVENT_MODEL;
FOUNDATION_EXPORT NSString *const TYPE_DEBIT;
FOUNDATION_EXPORT NSString *const TYPE_CREDIT;
FOUNDATION_EXPORT NSString *const TYPE_TRANSFER;

@end

NS_ASSUME_NONNULL_END

#import "StoredValueEvent+CoreDataProperties.h"
