//
//  DirectionRoute.h
//  CDTA
//
//  Created by CooCooTech on 10/15/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bounds.h"
#import "Polyline.h"

@interface DirectionRoute : NSObject

@property (strong, nonatomic) Bounds *bounds;
@property (copy, nonatomic) NSString *copyrights;
@property (copy, nonatomic) NSArray *legs;
@property (strong, nonatomic) Polyline *overviewPolyline;
@property (copy, nonatomic) NSString *summary;
@property (copy, nonatomic) NSArray *warnings;
@property (copy, nonatomic) NSArray *waypointOrder;

@end
