//
//  RequestNewCardService.h
//  CooCooBase
//
//  Created by Andrey Kasatkin on 3/22/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface RequestNewCardService : BaseService

- (id)initWithListener:(id)lis
              nickname:(NSString *)name
           description:(NSString *)desc
  managedObjectContext:(NSManagedObjectContext *)context
                  uuid:(NSString *)deviceUUID
              personId:(NSNumber *)accountId;

- (BOOL)setDataWithJson:(NSDictionary *)json;
@end
