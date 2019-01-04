//
//  Alert.h
//  CDTA
//
//  Created by CooCooTech on 10/29/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alert : NSObject

FOUNDATION_EXPORT NSString *const NO_ALERTS;

@property (copy, nonatomic) NSArray *routeIds;
@property (copy, nonatomic) NSString *header;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *routeType;

- (BOOL)containsRouteId:(int)routeId;

@end
