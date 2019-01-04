//
//  TicketSyncService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TicketSyncServiceListener <NSObject>

- (void)syncThreadSuccessWithClass:(id)service;
- (void)syncThreadErrorWithClass:(id)service;

@end

@interface TicketSyncService : NSObject

@property (weak, nonatomic) id <TicketSyncServiceListener> listener;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext;
- (void)execute;

@end
