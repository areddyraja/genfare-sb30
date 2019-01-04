//
//  UsageLoggingService.h
//  CDTA
//
//  Created by CooCooTech on 12/4/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface UsageLoggingService : BaseService

- (id)initWithEndpoint:(NSString *)endpoint
              viewName:(NSString *)viewName
           viewDetails:(NSString *)viewDetails
              latitude:(double)latitude
             longitude:(double)longitude;

@end
