//
//  Card.h
//  CooCooBase
//
//  Created by CooCooTech on 4/1/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Card : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
FOUNDATION_EXPORT NSString *const CARD_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "Card+CoreDataProperties.h"
