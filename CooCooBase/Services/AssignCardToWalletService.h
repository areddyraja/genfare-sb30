//
//  AssignCardToWalletService.h
//  CooCooBase
//
//  Created by CooCooTech on 3/28/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface AssignCardToWalletService : BaseService

- (id)initWithListener:(id)listener
            walletUuid:(NSString *)walletUuid
              cardUuid:(NSString *)cardUuid
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
