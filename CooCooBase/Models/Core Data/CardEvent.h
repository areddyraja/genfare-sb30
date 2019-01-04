//
//  CardEvent.h
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface CardEvent : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
FOUNDATION_EXPORT NSString *const CARD_EVENT_MODEL;
FOUNDATION_EXPORT NSString *const CARD_EVENT_TYPE_REDEEM;
FOUNDATION_EXPORT NSString *const CARD_EVENT_TYPE_ACTIVATE;

@end

NS_ASSUME_NONNULL_END

#import "CardEvent+CoreDataProperties.h"
