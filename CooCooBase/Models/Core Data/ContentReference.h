//
//  ContentReference.h
//  CooCooBase
//
//  Created by John Scuteri on 7/28/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ContentReference : NSManagedObject

FOUNDATION_EXPORT NSString *const CONTENT_REFERENCE_MODEL;

@property (nonatomic, retain) NSNumber *contentDescriptionIDNum;
@property (nonatomic, retain) NSNumber *contentIDNum;

@end
