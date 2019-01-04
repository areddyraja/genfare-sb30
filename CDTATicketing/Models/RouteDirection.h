//
//  RouteDirection.h
//  CDTA
//
//  Created by CooCooTech on 11/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteDirection : NSObject

@property (nonatomic) int directionId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *scheduleUri;

@end
