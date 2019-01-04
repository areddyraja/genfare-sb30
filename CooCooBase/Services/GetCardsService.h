//
//  GetCardsService.h
//  Pods
//
//  Created by Andrey Kasatkin on 3/20/16.
//
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetCardsService : BaseService

- (id)initWithListener:(id)listener
            walletUuid:(NSString *)walletUuid
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
