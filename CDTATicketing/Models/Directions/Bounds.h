//
//  Bounds.h
//  CDTA
//
//  Created by CooCooTech on 10/15/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Bounds : NSObject

@property (strong, nonatomic) Location *northeast;
@property (strong, nonatomic) Location *southwest;

@end
