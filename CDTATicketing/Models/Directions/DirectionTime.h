//
//  DirectionTime.h
//  CDTA
//
//  Created by CooCooTech on 10/15/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DirectionTime : NSObject

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *timeZone;
@property (nonatomic) double timeValue;

@end
