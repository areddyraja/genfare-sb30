//
//  CardEvent+CoreDataProperties.h
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CardEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardEvent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *occurredOnDateTime;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *detail;
@property (nullable, nonatomic, retain) NSNumber *code;
@property (nullable, nonatomic, retain) NSData *position;
@property (nullable, nonatomic, retain) NSData *content;

@end

NS_ASSUME_NONNULL_END
