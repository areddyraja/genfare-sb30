//
//  GetWalletsService.h
//  CooCooBase
//
//  Created by CooCooTech on 3/7/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetWalletsService : BaseService

- (id)initWithListener:(id)lis
              nickname:(NSString *)name
  managedObjectContext:(NSManagedObjectContext *)context
                  uuid:(NSString *)deviceUUID
              personId:(NSNumber *)accountId;
@end
