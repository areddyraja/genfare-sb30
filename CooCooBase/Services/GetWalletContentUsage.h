//
//  LoginService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetWalletContentUsage : BaseService

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withArray:(NSArray *)epochSeconds walletContentUsageIdentifier:(id)walletContentUsageIdentifierid;

@end

