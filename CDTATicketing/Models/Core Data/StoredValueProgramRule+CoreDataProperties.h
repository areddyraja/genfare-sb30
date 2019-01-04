//
//  StoredValueProgramRule+CoreDataProperties.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/22/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "StoredValueProgramRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface StoredValueProgramRule (CoreDataProperties)

@property (nullable, nonatomic, retain) NSData *benefit;
@property (nullable, nonatomic, retain) NSData *requirement;

@end

NS_ASSUME_NONNULL_END
