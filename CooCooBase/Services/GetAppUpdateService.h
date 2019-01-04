//
//  GetAppUpdateService.h
//  CDTATicketing
//
//  Created by omniwyse on 11/07/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetAppUpdateService : BaseService
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext;
@end
