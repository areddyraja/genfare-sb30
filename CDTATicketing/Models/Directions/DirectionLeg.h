//
//  DirectionLeg.h
//  CDTA
//
//  Created by CooCooTech on 10/15/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectionDuration.h"
#import "DirectionTime.h"
#import "Distance.h"
#import "Location.h"

@interface DirectionLeg : NSObject

@property (strong, nonatomic) DirectionTime *arrivalTime;
@property (strong, nonatomic) DirectionTime *departureTime;
@property (strong, nonatomic) Distance *distance;
@property (strong, nonatomic) DirectionDuration *duration;
@property (copy, nonatomic) NSString *endAddress;
@property (strong, nonatomic) Location *endLocation;
@property (copy, nonatomic) NSString *startAddress;
@property (strong, nonatomic) Location *startLocation;
@property (copy, nonatomic) NSArray *steps;

@end
