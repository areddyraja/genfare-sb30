//
//  RuntimeData.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface RuntimeData : NSObject

@property (retain, nonatomic) NSArray *busRoutes;
@property (retain, nonatomic) NSArray *busLocations;
@property (retain, nonatomic) NSArray *busPredictions;
@property (retain, nonatomic) NSArray *appExceptions;
@property (retain, nonatomic) NSArray *appMessages;
@property (retain, nonatomic) NSArray *ticketEvents;
@property (retain, nonatomic) NSArray *paymentTokens;
@property (retain, nonatomic) NSArray *registeredDevices;
@property (copy, nonatomic) NSString *ticketSourceId;

// TODO: TEMPORARY WORKAROUND for passing managedObjectContext between screens from within AppSettingsViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (id)instance;
+ (NSString *)ticketSourceId:(NSManagedObjectContext *)managedObjectContext;
+ (void)commitTicketSourceId:(NSString *)ticketSourceId;

@end
