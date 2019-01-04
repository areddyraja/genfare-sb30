//
//  UpgradeWalletService.h
//  Pods
//
//  Created by ibasemac3 on 6/20/17.
//
//

#import "BaseService.h"
#import <CoreData/CoreData.h>
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"

@interface UpgradeWalletService :BaseService

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
         parameterDict:(NSMutableDictionary *)dict
              walletID:(NSString *)walletID;


@end
