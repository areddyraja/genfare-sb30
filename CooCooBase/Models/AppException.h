//
//  AppException.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppException : NSObject

@property (nonatomic) int errorType;
@property (copy, nonatomic) NSString *errorDetail;
@property (nonatomic) float errorDateTime;

@end
