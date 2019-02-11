//
//  BarcodeUtilities.h
//  CooCooBase
//
//  Created by CooCooTech on 4/16/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iRide-Swift.h"

@interface BarcodeUtilities : NSObject

+ (NSString *)generateBarcodeWithTicket:(WalletContents *)ticket
                                product:(Product *)product
                          encriptionKey:(EncryptionKey *)encriptionKey
                             isFreeRide:(BOOL)isFreeRide
                               deviceID:(NSString *)deviceID
                              transitID:(NSNumber *)transitID
                              accountId:(NSString *)accountId;
@end

