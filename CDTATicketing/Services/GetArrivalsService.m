//
//  GetArrivalsService.m
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetArrivalsService.h"
#import "Arrival.h"
#import "CDTAUtilities.h"

@implementation GetArrivalsService
{
    int stopId;
}

- (id)initWithListener:(id)listener
                stopId:(int)stop
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
        stopId = stop;
        self.managedObjectContext = context;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [CDTAUtilities schedulesHost];
}

- (NSString *)uri
{
    NSString *uri = [NSString stringWithFormat:@"api/v1/?request=arrivals/%05d", stopId];
    
    if (self.resultsCount > 0) {
        return [uri stringByAppendingString:[NSString stringWithFormat:@"/%d", self.resultsCount]];
    } else {
        return uri;
    }
}

- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    [headers setObject:[CDTAUtilities fetchScheduleKey] forKey:@"key"];
    
    return headers;
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ((json != nil) && [json count] > 0) {
        [self deleteArrivalsForStopId:stopId];
        [self setDataWithJson:json];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSArray *arrivals = [json objectForKey:@"arrivals"];
    for (NSDictionary *arrivalJson in arrivals) {
        Arrival *arrival = (Arrival *)[NSEntityDescription insertNewObjectForEntityForName:ARRIVAL_MODEL
                                                                    inManagedObjectContext:self.managedObjectContext];
        
        arrival.stopId = [NSNumber numberWithInt:[[json objectForKey:@"stop_id"] intValue]];
        arrival.stopName = [json objectForKey:@"stop_name"];
        arrival.uri = [json objectForKey:@"uri"];
        
        arrival.minutes = [arrivalJson objectForKey:@"arrival_minutes"];
        arrival.time = [arrivalJson objectForKey:@"arrival_time"];
        arrival.routeId = [NSNumber numberWithInt:[[arrivalJson objectForKey:@"route_id"] intValue]];
        arrival.routeName = [arrivalJson objectForKey:@"route_name"];
        arrival.type = [arrivalJson objectForKey:@"type"];
        arrival.direction = [arrivalJson objectForKey:@"direction"];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        }
    }
}

- (void)deleteArrivalsForStopId:(int)stop
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:ARRIVAL_MODEL inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopId == %d", stop];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *arrivals = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Arrival *arrival in arrivals) {
        [self.managedObjectContext deleteObject:arrival];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
