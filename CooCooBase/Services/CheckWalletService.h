//
//  LoginService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface CheckWalletService : BaseService

-(id)initWithListener:(id)lis
              emailid:(NSString *)email  managedContext:(NSManagedObjectContext*)context;
@end

