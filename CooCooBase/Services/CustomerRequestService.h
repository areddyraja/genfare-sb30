//
//  CustomerRequestService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"

@interface CustomerRequestService : BaseService

- (id)initWithListener:(id)listener
         ticketGroupId:(NSString *)ticketGroupId
               comment:(NSString *)comment;

@end
