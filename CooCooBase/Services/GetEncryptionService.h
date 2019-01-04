//
//  GetEncryptionService.h
//  CooCooBase
//
//  Created by John Scuteri on 9/22/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetEncryptionService : BaseService

- (id)initWithListener:(id)listener managedObjectContext:(NSManagedObjectContext *)context;

@end
