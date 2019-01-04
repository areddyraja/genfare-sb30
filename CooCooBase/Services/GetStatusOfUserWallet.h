//
//  GetStatusOfUserWallet.h
//  CDTATicketing
//
//  Created by vishnu on 31/12/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetStatusOfUserWallet : BaseService
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withwalletid:(NSString *)walletID;
@end

NS_ASSUME_NONNULL_END
