//
//  WalletContents+CoreDataClass.h
//  
//
//  Created by Omniwyse on 3/6/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Duplicate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletContents : NSManagedObject
FOUNDATION_EXPORT NSString *const WALLET_CONTENT_MODEL;

@end

NS_ASSUME_NONNULL_END

#import "WalletContents+CoreDataProperties.h"
