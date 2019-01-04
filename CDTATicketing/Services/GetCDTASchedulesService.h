//
//  GetCDTASchedulesService.h
//  CDTA
//
//  Created by CooCooTech on 11/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface GetCDTASchedulesService : BaseService

- (id)initWithListener:(id)listener
               routeId:(int)routeId
           serviceType:(NSString *)serviceType
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
