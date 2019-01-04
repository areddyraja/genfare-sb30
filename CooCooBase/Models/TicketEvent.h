//
//  TicketEvent.h
//  CooCooBase
//
//  Created by CooCooTech on 6/20/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketEvent : NSObject

@property (nonatomic) double createdDateTime;
@property (nonatomic) double eventDateTime;
@property (copy, nonatomic) NSString *eventDetail;
@property (nonatomic) double eventLat;
@property (nonatomic) double eventLng;
@property (copy, nonatomic) NSString *eventType;
@property (nonatomic, getter = isSynced) BOOL synced;
@property (copy, nonatomic) NSString *memberId;
@property (copy, nonatomic) NSString *reportDeviceId;
@property (copy, nonatomic) NSString *reportDeviceType;
@property (copy, nonatomic) NSString *reportUserId;
@property (copy, nonatomic) NSString *ticketGroupId;
@property (copy, nonatomic) NSString *transitId;

@end
