//
//  TransitLine.h
//  CDTA
//
//  Created by CooCooTech on 10/10/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vehicle.h"

@interface TransitLine : NSObject

@property (copy, nonatomic) NSArray *agencies;
@property (copy, nonatomic) NSString *color;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *shortName;
@property (copy, nonatomic) NSString *textColor;
@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) Vehicle *vehicle;

@end
