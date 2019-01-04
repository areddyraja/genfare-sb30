//
//  Alert.m
//  CDTA
//
//  Created by CooCooTech on 10/29/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "Alert.h"

NSString *const NO_ALERTS = @"No service alerts";

@implementation Alert

- (BOOL)containsRouteId:(int)route
{
    for (NSNumber *routeId in self.routeIds) {
        if ([routeId intValue] == route) {
            return YES;
        }
    }
    
    return NO;
}

@end
