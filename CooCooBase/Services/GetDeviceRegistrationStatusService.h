//
//  GetDeviceRegistrationStatusService.h
//  CooCooBase
//
//  Created by John Scuteri on 9/10/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseService.h"

@interface GetDeviceRegistrationStatusService : BaseService

- (id)initWithListener:(id)listener
             accountId:(NSString *)account;

@end
