//
//  Token.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Token : NSManagedObject

FOUNDATION_EXPORT NSString *const TOKEN_MODEL;

@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) id image;

+ (NSString *)tokenDateStringFromDate:(NSDate *)date;

@end
