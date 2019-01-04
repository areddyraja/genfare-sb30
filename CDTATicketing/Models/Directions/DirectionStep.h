//
//  DirectionStep.h
//  CDTA
//
//  Created by CooCooTech on 10/10/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectionDuration.h"
#import "Distance.h"
#import "Location.h"
#import "Polyline.h"
#import "TransitDetails.h"

@interface DirectionStep : NSObject

@property (strong, nonatomic) Distance *distance;
@property (strong, nonatomic) DirectionDuration *duration;
@property (strong, nonatomic) Location *endLocation;
@property (copy, nonatomic) NSString *htmlInstructions;
@property (strong, nonatomic) Polyline *polyline;
@property (strong, nonatomic) Location *startLocation;
@property (copy, nonatomic) NSArray *subSteps;
@property (strong, nonatomic) TransitDetails *transitDetails;
@property (copy, nonatomic) NSString *travelMode;

@end
