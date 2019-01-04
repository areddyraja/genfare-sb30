//
//  WalletContent.h
//  CooCooBase
//
//  Created by Gaian Solutions on 4/12/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WalletContent : NSObject



@property (copy, nonatomic) NSNumber *walletId;
@property (copy, nonatomic) NSString *walletUUID;
@property (copy, nonatomic) NSString *printedId;
@property (copy, nonatomic) NSNumber *personId;
@property (copy, nonatomic) NSNumber *statusId;
@property (copy, nonatomic) NSNumber *farecode;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSString *deviceUUID;
@property (copy, nonatomic) NSString *deviceId;
@property (copy, nonatomic) NSString *accountType;
@property (copy, nonatomic) NSString *accTicketGroupId;
@property (copy, nonatomic) NSString *accMemberId;
@property (copy, nonatomic) NSString *cardType;
@property (copy, nonatomic) NSNumber *farecodeExpiryDateTime;

- (id)initWithDictionary:(NSDictionary*)dict1;
@end
