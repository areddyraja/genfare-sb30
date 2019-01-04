//
//  LoginService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetEncryptionKeysService : BaseService

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

