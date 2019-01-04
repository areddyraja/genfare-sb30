//
//  ResendVerificationService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/30/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "BaseService.h"

@interface ResendVerificationService : BaseService

- (id)initWithListener:(id)listener
              username:(NSString *)username;

@end
