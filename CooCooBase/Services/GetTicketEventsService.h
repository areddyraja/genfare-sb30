//
//  GetTicketEventsService.h
//  CooCooBase
//
//  Created by CooCooTech on 6/20/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseService.h"

@interface GetTicketEventsService : BaseService

- (id)initWithListener:(id)listener
         ticketGroupId:(NSString *)ticketGroupId
              memberId:(NSString *)memberId;

@end
