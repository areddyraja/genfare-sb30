//
//  EncryptionSet.h
//  CooCooBase
//
//  Created by John Scuteri on 9/22/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface EncryptionSet : NSManagedObject

FOUNDATION_EXPORT NSString *const ENCRYPTION_SET_MODEL;
FOUNDATION_EXPORT NSString *const ENCRYPTION_TYPE_AES;
FOUNDATION_EXPORT NSString *const ENCRYPTION_TYPE_RSA;

//@property (nonatomic, retain) NSNumber * createdTimestamp;
@property (nonatomic, retain) NSNumber * currentKey;
@property (nonatomic, retain) NSNumber * disableTimestamp;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSNumber * enabledTimestamp;
@property (nonatomic, retain) NSNumber * idNum;
@property (nonatomic, retain) NSString * keyType;
@property (nonatomic, retain) NSString * primaryData;
@property (nonatomic, retain) NSString * secondaryData;
//@property (nonatomic, retain) NSNumber * updatedTimestamp;

@end
