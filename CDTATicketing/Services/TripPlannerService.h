//
//  TripPlannerService.h
//  CDTA
//
//  Created by CooCooTech on 10/10/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CooCooBase.h"
#import "Stop.h"

@interface TripPlannerService : BaseService

- (id)initWithListener:(id)listener
            originName:(NSString *)originName
        originLatitude:(double)originLatitude
       originLongitude:(double)originLongitude
       destinationName:(NSString *)destinationName
   destinationLatitude:(double)destinationLatitude
  destinationLongitude:(double)destinationLongitude
          scheduleTime:(NSDate *)scheduleTime
            isArriving:(BOOL)isArriving;

@end
