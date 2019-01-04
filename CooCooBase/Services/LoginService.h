//
//  LoginService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface LoginService : BaseService

{
    NSString *username;
    NSString *password;
     NSString *uuid;
}


- (id)initWithListener:(id)lis
              username:(NSString *)user
              password:(NSString *)pass
  managedObjectContext:(NSManagedObjectContext *)context
                  uuid:(NSString *)deviceUUID;

@end

