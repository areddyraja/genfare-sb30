//
//  Product.h
//  CooCooBase
//
//  Created by IBase Software on 28/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface Product : NSManagedObject

FOUNDATION_EXPORT NSString *const PRODUCT_MODEL;

@end
NS_ASSUME_NONNULL_END
#import "Product+CoreDataProperties.h"
