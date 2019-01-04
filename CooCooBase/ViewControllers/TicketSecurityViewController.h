//
//  TicketSecurityViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePageViewController.h"
#import "Ticket.h"

@interface TicketSecurityViewController : BasePageViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSString *ticketSourceId;

- (id)init;

@end
