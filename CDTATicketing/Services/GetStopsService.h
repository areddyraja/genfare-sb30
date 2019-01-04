//
//  GetStopsService.h
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface GetStopsService : BaseService

- (id)initWithListener:(id)listener
               routeId:(int)routeId
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
