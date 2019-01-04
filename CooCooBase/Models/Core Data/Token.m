//
//  Token.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "Token.h"

NSString *const TOKEN_MODEL = @"Token";

@implementation Token

@dynamic date;
@dynamic image;

+ (NSString *)tokenDateStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
