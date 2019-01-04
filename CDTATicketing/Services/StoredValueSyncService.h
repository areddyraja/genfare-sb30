//
//  StoredValueSyncService.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/6/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "CooCooBase.h"
#import "StoredValueEvent.h"

@interface StoredValueSyncService : BaseService

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
      storedValueEvent:(StoredValueEvent *)storedValueEvent
              cardUuid:(NSString *)cardUuid;

@end
