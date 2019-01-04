//
//  GetContentService.h
//  CooCooBase
//
//  Created by John Scuteri on 7/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetContentService : BaseService

- (id)initWithListener:(id)listener managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
