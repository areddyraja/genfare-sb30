//
//  ForgotPasswordService.h
//  CooCooBase
//
//  Created by John Scuteri on 5/30/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseService.h"

@interface ForgotPasswordService : BaseService

- (id)initWithListener:(id)listener userEmail:(NSString *)userEmailAdd;

@end
