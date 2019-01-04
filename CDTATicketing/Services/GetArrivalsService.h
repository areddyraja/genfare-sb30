//
//  GetArrivalsService.h
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface GetArrivalsService : BaseService

@property (nonatomic) int resultsCount;

- (id)initWithListener:(id)listener
                stopId:(int)stopId
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
