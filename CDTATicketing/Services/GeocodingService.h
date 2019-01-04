//
//  GeocodingService.h
//  CDTA
//
//  Created by CooCooTech on 4/14/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface GeocodingService : BaseService

- (id)initWithListener:(id)listener
               address:(NSString *)address;

@end
