//
//  ContentDescription.h
//  CooCooBase
//
//  Created by John Scuteri on 7/28/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ContentDescription : NSManagedObject

FOUNDATION_EXPORT NSString *const CONTENT_DESCRIPTION_MODEL;

@property (nonatomic, retain) NSString *cDescription;
@property (nonatomic, retain) NSNumber *idNum;
@property (nonatomic, retain) NSNumber *lastUpdated;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *transitName;
@property (nonatomic, retain) NSString *language;

@end
