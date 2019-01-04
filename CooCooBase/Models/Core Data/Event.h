//
//  Event+CoreDataClass.h
//  
//
//  Created by omniwyse on 14/03/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSManagedObject
FOUNDATION_EXPORT NSString *const Event_Model;
@end

NS_ASSUME_NONNULL_END

#import "Event+CoreDataProperties.h"
