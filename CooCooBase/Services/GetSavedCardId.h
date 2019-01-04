//
//  LoginService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetSavedCardId : BaseService

-(id)initWithListener:(id)lis managedObjectContext:(NSManagedObjectContext *)managedObjectContext
              orderId:(NSString *)orderId walletId:(NSString *)WalletId savedCardId:(NSString *)savedCardId;

@end


