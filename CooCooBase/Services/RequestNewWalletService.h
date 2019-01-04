//
//  RequestNewWalletService.h
//  Pods
//
//  Created by Andrey Kasatkin on 3/20/16.
//
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface RequestNewWalletService : BaseService

- (id)initWithListener:(id)lis managedObjectContext:(NSManagedObjectContext *)context;

@end
