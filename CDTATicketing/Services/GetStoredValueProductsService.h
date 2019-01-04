//
//  GetStoredValueProductsService.h
//  CDTATicketing
//
//  Created by CooCooTech on 9/30/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface GetStoredValueProductsService : BaseService

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
  cardId:(NSString *)card;

@end
