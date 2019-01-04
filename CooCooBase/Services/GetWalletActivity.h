//
//  LoginService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetWalletActivity : BaseService

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)context;


@end

