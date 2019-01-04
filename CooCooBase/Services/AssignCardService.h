//
//  AssignCardService.h
//  CooCooBase
//
//  Created by Andrey Kasatkin on 3/25/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>
#import "Card.h"

@interface AssignCardService : BaseService

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  card:(Card *)cardObject
           accoundUuid:(NSString *)accountUuid;

@end
