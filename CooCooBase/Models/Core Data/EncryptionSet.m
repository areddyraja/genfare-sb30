//
//  EncryptionSet.m
//  CooCooBase
//
//  Created by John Scuteri on 9/22/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "EncryptionSet.h"

NSString *const ENCRYPTION_SET_MODEL = @"EncryptionSet";
NSString *const ENCRYPTION_TYPE_AES = @"aes";
NSString *const ENCRYPTION_TYPE_RSA = @"rsa";

@implementation EncryptionSet

//@dynamic createdTimestamp;
@dynamic currentKey;
@dynamic disableTimestamp;
@dynamic enabled;
@dynamic enabledTimestamp;
@dynamic idNum;
@dynamic keyType;
@dynamic primaryData;
@dynamic secondaryData;
//@dynamic updatedTimestamp;

@end
