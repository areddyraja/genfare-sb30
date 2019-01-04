//
//  GetWalletContents.h
//  CooCooBase
//
//  Created by IBase Software on 28/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import <CoreData/CoreData.h>

@interface GetWalletContents : BaseService
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withwalletid:(NSString *)walletID;

@end
