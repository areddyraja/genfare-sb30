//
//  TransitStop.h
//  CDTA
//
//  Created by CooCooTech on 10/10/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface TransitStop : NSObject

@property (strong, nonatomic) Location *location;
@property (copy, nonatomic) NSString *name;

@end
