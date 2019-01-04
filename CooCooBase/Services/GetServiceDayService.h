//
//  GetServiceDayService.h
//  CooCooBase
//
//  Created by John Scuteri on 10/28/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetServiceDayService : BaseService

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
