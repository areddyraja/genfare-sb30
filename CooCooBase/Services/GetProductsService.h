//
//  GetProductsService.h
//  CooCooBase
//
//  Created by ibasemac3 on 12/15/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>
@interface GetProductsService : BaseService
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
