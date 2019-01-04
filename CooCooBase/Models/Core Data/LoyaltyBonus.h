//
//  LoyaltyBonus+CoreDataClass.h
//  
//
//  Created by Ravi Jampala on 3/28/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoyaltyBonus : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
FOUNDATION_EXPORT NSString *const LOYALTY_BONUS_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "LoyaltyBonus+CoreDataProperties.h"
