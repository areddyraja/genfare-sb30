//
//  BarcodeUtilities.h
//  CooCooBase
//
//  Created by CooCooTech on 4/16/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
 #import "UserData.h"
#import "WalletContents.h"

@interface BarcodeUtilities : NSObject

+ (UIImageView *)regenerateBarcodeWithTicket:(WalletContents *)ticket
                                   accountId:(NSString *)accountId
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               viewContainer:(UIView *)viewContainer;

+ (UIImage *)generateBarcodeWithTicket:(WalletContents *)ticket
                             accountId:(NSString *)accountId
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end

