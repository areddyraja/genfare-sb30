//
//  TransitDetails.h
//  CDTA
//
//  Created by CooCooTech on 10/10/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectionTime.h"
#import "TransitLine.h"
#import "TransitStop.h"

@interface TransitDetails : NSObject

@property (strong, nonatomic) TransitStop *arrivalStop;
@property (strong, nonatomic) DirectionTime *arrivalTime;
@property (strong, nonatomic) TransitStop *departureStop;
@property (strong, nonatomic) DirectionTime *departureTime;
@property (copy, nonatomic) NSString *headsign;
@property (strong, nonatomic) TransitLine *line;
@property (nonatomic) int numberOfStops;

@end
