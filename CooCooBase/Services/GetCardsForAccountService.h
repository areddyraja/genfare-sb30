//
//  GetCardsForAccountService.h
//  CooCooBase
//
//  Created by CooCooTech on 3/29/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetCardsForAccountService : BaseService

- (id)initWithListener:(id)listener
             accountId:(NSString *)accoundId
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
