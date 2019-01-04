//
//  SearchedStop.h
//  CDTA
//
//  Created by CooCooTech on 12/18/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchedStop : NSObject

@property (nonatomic) int stopId;
@property (copy, nonatomic) NSString *name;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (copy, nonatomic) NSArray *servicedBy;
@property (nonatomic) BOOL isLandmark;

@end
