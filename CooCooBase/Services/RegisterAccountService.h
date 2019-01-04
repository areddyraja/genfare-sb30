//
//  RegisterAccountService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface RegisterAccountService : BaseService

- (id)initWithListener:(id)listener
              username:(NSString *)username
              password:(NSString *)password
             firstName:(NSString *)firstName
              lastName:(NSString *)lastName
managedObjectContext:(NSManagedObjectContext *)context;
@end
