//
//  GetNearbyStopsService.h
//  CDTA
//
//  Created by CooCooTech on 10/23/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface GetNearbyStopsService : BaseService

- (id)initWithListener:(id)listener
              latitude:(double)latitude
             longitude:(double)longitude
                 count:(int)count;

@end
