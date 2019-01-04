//
//  CreateUser.h
//  Pods
//
//  Created by omniwyse on 11/10/17.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface CreateUser : BaseService

- (id)initWithListener:(id)listener
              username:(NSString *)username
              password:(NSString *)password
             firstName:(NSString *)firstName
              lastName:(NSString *)lastName
  managedObjectContext:(NSManagedObjectContext *)context;

@end
