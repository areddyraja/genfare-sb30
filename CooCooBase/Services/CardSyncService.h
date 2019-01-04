//
//  CardSyncService.h
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CardSyncServiceListener <NSObject>

- (void)cardSyncThreadSuccessWithClass:(id)service;
- (void)cardSyncThreadErrorWithClass:(id)service;

@end

@interface CardSyncService : NSObject

@property (weak, nonatomic) id <CardSyncServiceListener> listener;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext;
- (void)execute;

@end
