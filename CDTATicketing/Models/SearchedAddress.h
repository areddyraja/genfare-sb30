//
//  SearchedAddress.h
//  CDTA
//
//  Created by CooCooTech on 4/14/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchedAddress : NSObject

@property (copy, nonatomic) NSString *address;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
