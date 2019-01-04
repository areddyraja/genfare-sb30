//
//  Content.h
//  CooCooBase
//
//  Created by John Scuteri on 7/28/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Content : NSManagedObject

FOUNDATION_EXPORT NSString *const CONTENT_MODEL;

@property (nonatomic, retain) NSNumber *isLocal;
@property (nonatomic, retain) NSNumber *idNum;
@property (nonatomic, retain) NSString *storageType;
@property (nonatomic, retain) NSNumber *created;
@property (nonatomic, retain) NSNumber *lastUpdated;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *type;

@end
