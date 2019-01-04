//
//  CardEventContent.m
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CardEventContent.h"

@implementation CardEventContent

NSString *const KEY_CARD_EVENT_TICKET_GROUP_ID = @"ticketGroupId";
NSString *const KEY_CARD_EVENT_MEMBER_ID = @"memberId";
NSString *const KEY_CARD_EVENT_BORN_ON_DATE_TIME = @"bornOnDateTime";
NSString *const KEY_CARD_EVENT_FARE = @"fare";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.ticketGroupId = [decoder decodeObjectForKey:KEY_CARD_EVENT_TICKET_GROUP_ID];
        self.memberId = [decoder decodeObjectForKey:KEY_CARD_EVENT_MEMBER_ID];
        self.bornOnDateTime = [decoder decodeObjectForKey:KEY_CARD_EVENT_BORN_ON_DATE_TIME];
        self.fare = [decoder decodeObjectForKey:KEY_CARD_EVENT_FARE];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.ticketGroupId forKey:KEY_CARD_EVENT_TICKET_GROUP_ID];
    [encoder encodeObject:self.memberId forKey:KEY_CARD_EVENT_MEMBER_ID];
    [encoder encodeObject:self.bornOnDateTime forKey:KEY_CARD_EVENT_BORN_ON_DATE_TIME];
    [encoder encodeObject:self.fare forKey:KEY_CARD_EVENT_FARE];
}

@end
