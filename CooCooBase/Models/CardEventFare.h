//
//  CardEventFare.h
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardEventRevision.h"

@interface CardEventFare : NSObject <NSCoding>

@property (copy, nonatomic) NSString *code;
@property (strong, nonatomic) CardEventRevision *revision;

@end
