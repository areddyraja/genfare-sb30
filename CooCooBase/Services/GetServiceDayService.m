//
//  GetServiceDayService.m
//  CooCooBase
//
//  Created by John Scuteri on 10/28/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "GetServiceDayService.h"
#import "ServiceDay.h"
#import "Utilities.h"

@implementation GetServiceDayService
{
}

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = lis;
        self.managedObjectContext = context;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities apiHost];
}

- (NSString *)uri
{
    return @"service_schedules";
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        [self setDataWithJson:[json valueForKey:@"result"]];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    [self deleteOldServiceDays];
    
    for (NSDictionary *serviceDayJson in json) {
        ServiceDay *serviceDay = (ServiceDay *)[NSEntityDescription insertNewObjectForEntityForName:SERVICE_DAY_MODEL inManagedObjectContext:self.managedObjectContext];
        
        [serviceDay setIdNum:[NSNumber numberWithInt:[[serviceDayJson objectForKey:@"id"] intValue]]];
        [serviceDay setActive:[NSNumber numberWithInt:[[serviceDayJson objectForKey:@"active"] intValue]]];
        [serviceDay setCreatedDateTime:[NSNumber numberWithDouble:[[serviceDayJson objectForKey:@"created"] doubleValue]]];
        [serviceDay setTypeSpecific:[NSNumber numberWithInt:[[serviceDayJson objectForKey:@"is_type_specific"] intValue]]];
        [serviceDay setServiceSeconds:[NSNumber numberWithInt:[[serviceDayJson objectForKey:@"service_seconds"] intValue]]];
        [serviceDay setServiceSpan:[NSNumber numberWithInt:[[serviceDayJson objectForKey:@"service_span"] intValue]]];
        [serviceDay setStartSeconds:[NSNumber numberWithInt:[[serviceDayJson objectForKey:@"start_seconds"] intValue]]];
        
        // TODO
        /*if ([[serviceDay typeSpecific] boolValue]) {
            NSArray *ticketTypes = [serviceDayJson objectForKey:@"ticket_types"];
        }*/
        
        [serviceDay setUpdatedDateTime:[NSNumber numberWithDouble:[[serviceDayJson objectForKey:@"updated"] doubleValue]]];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        }
    }
}

- (void)deleteOldServiceDays
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SERVICE_DAY_MODEL];
    
    NSError *error = nil;
    NSArray *serviceDays = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (ServiceDay *serviceDay in serviceDays) {
        [self.managedObjectContext deleteObject:serviceDay];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
