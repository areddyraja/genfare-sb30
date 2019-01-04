//
//  CDTARuntimeData.m
//  CDTA
//
//  Created by CooCooTech on 10/15/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTARuntimeData.h"

@implementation CDTARuntimeData

+ (id)instance
{
    static CDTARuntimeData *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[super alloc] init];
        
        instance.tripDirections = [[Directions alloc] init];
        instance.nearbyStops = [[NSArray alloc] init];
        instance.alerts = [[NSArray alloc] init];
        instance.searchedStops = [[NSArray alloc] init];
        instance.searchedAddresses = [[NSArray alloc] init];
        instance.payAsYouGoHistory = [[NSArray alloc] init];
    });
    
    return instance;
}

@end
