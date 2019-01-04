//
//  CardEventContent.h
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardEventFare.h"

@interface CardEventContent : NSObject <NSCoding>

@property (copy, nonatomic) NSString *ticketGroupId;
@property (copy, nonatomic) NSString *memberId;
@property (copy, nonatomic) NSDate *bornOnDateTime;
@property (strong, nonatomic) CardEventFare *fare;

@end
