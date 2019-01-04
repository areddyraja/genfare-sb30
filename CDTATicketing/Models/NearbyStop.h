//
//  NearbyStop.h
//  CDTA
//
//  Created by CooCooTech on 10/23/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NearbyStop : NSObject

@property (nonatomic) int stopId;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) double distanceInDegrees;
@property (nonatomic) double distanceInFeet;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (copy, nonatomic) NSArray *servicedBy;

@end
