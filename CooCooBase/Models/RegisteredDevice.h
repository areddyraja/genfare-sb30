//
//  RegisteredDevice.h
//  CooCooBase
//
//  Created by John Scuteri on 9/12/14.
//  Updated by AK on 11/1/15
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisteredDevice : NSObject

@property (copy, nonatomic) NSNumber *mappingId;
@property (copy, nonatomic) NSString *appVersion;
@property (copy, nonatomic) NSString *category;
@property (copy, nonatomic) NSNumber *deviceId;
@property (copy, nonatomic) NSString *deviceUuid;
@property (copy, nonatomic) NSString *os;
@property (copy, nonatomic) NSString *osVersion;
@property (copy, nonatomic) NSString *model;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSDate *created;
@property (nonatomic) BOOL active;
@property (copy, nonatomic) NSNumber *accountId;
@property (copy, nonatomic) NSString *accountUuid;
@property (nonatomic) BOOL isPrimary;

@end
