//
//  CreateOrderService.h
//  CooCooBase
//
//  Created by IBase Software on 21/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface CreateOrderService : BaseService
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withArray:(NSArray *)selectedTickets;

@end
