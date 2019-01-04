//
//  ChangePasswordService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import "NSManagedObject+Duplicate.h"

@interface ChangePasswordService : BaseService

- (id)initWithListener:(id)lis
                 email:(NSString *)email
              password:(NSString *)password oldpassword:(NSString *)oldpass;

//- (id)initWithListener:(id)lis
//             accountid:(NSString *)newEmail
//              password:(NSString *)pass
//             firstName:(NSString *)fName
//              lastName:(NSString *)lName
//         existingEmail:(NSString *)exEmail
//  managedObjectContext:(NSManagedObjectContext *)context;
@end
