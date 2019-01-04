//
//  StoredValueEvent+CoreDataProperties.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/7/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StoredValueEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueEvent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *accountId;
@property (nullable, nonatomic, retain) NSNumber *amount;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSNumber *tenantId;
@property (nullable, nonatomic, retain) StoredValueAccount *account;

@end

NS_ASSUME_NONNULL_END
