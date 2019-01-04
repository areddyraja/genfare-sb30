//
//  DeletePaymentTokenService.h
//  CooCooBase
//
//  Created by John Scuteri on 8/11/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseService.h"

@interface DeletePaymentTokenService : BaseService

- (id)initWithListener:(id)listener
             accountId:(NSString *)account
        paymentTokenId:(NSString *)paymentId;

@end
