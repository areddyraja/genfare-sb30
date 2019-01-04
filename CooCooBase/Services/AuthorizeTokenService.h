//
//  AuthorizeTokenService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"

@interface AuthorizeTokenService : BaseService

- (id)initWithListener:(id)listener
              username:(NSString *)user
              password:(NSString *)pass;

@end

