//
//  GetStopsService.m
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetStopsService.h"
#import "CDTAUtilities.h"
#import "Stop.h"

@implementation GetStopsService
{
    int routeId;
}

- (id)initWithListener:(id)listener
               routeId:(int)route
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
        routeId = route;
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
    return [NSString stringWithFormat:@"api/v1/?request=stops/%d", routeId];
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
        [self deleteStopsForRouteId:routeId];
        [self setDataWithJson:json];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSEnumerator *enumerator = json.keyEnumerator;
    id key;
    while ((key = enumerator.nextObject)) {
        NSDictionary *directionJson = [json objectForKey:key];
        
        NSString *directionName = [directionJson objectForKey:@"name"];
        
        NSArray *stops = [directionJson objectForKey:@"stops"];
        for (NSDictionary *stopJson in stops) {
            Stop *stop = (Stop *)[NSEntityDescription insertNewObjectForEntityForName:STOP_MODEL
                                                               inManagedObjectContext:self.managedObjectContext];
            
            stop.stopId = [NSNumber numberWithInt:[[stopJson objectForKey:@"stop_id"] intValue]];
            stop.name = [stopJson objectForKey:@"name"];
            stop.latitude = [NSNumber numberWithDouble:[[stopJson objectForKey:@"latitude"] doubleValue]];
            stop.longitude = [NSNumber numberWithDouble:[[stopJson objectForKey:@"longitude"] doubleValue]];
            stop.arrivalUri = [stopJson objectForKey:@"stop_arrival_uri"];
            stop.direction = directionName;
            stop.routeId = [NSNumber numberWithInt:routeId];
            
            NSDictionary *serviceDictionary = [stopJson objectForKey:@"serviced_by"];
            
            NSArray *routeIds = [[serviceDictionary allKeys] sortedArrayUsingComparator:
                                 ^NSComparisonResult(id obj1, id obj2) {
                                     if ([obj1 integerValue] > [obj2 integerValue]) {
                                         return (NSComparisonResult)NSOrderedDescending;
                                     } else if ([obj1 integerValue] < [obj2 integerValue]) {
                                         return (NSComparisonResult)NSOrderedAscending;
                                     } else {
                                         return (NSComparisonResult)NSOrderedSame;
                                     }
                                 }];
            
            NSMutableString *serviceByString = [[NSMutableString alloc] init];
            
            NSUInteger routesCount = routeIds.count;
            for (int i = 0; i < routesCount; i++) {
                if (i > 0) {
                    [serviceByString appendString:@", "];
                }
                
                NSString *key = [routeIds objectAtIndex:i];
                
                NSDictionary *directionJson = [serviceDictionary objectForKey:key];
                NSString *direction = [directionJson objectForKey:@"direction"];
                
                if (![direction isEqual:[NSNull null]] && ([direction length] > 0)
                    && ![direction isEqualToString:@"null"]) {
                    [serviceByString appendString:[NSString stringWithFormat:@"%@ (%@)", key, direction]];
                } else {
                    [serviceByString appendString:key];
                }
            }
            
            stop.servicedBy = serviceByString;
            
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
}

- (void)deleteStopsForRouteId:(int)route
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:STOP_MODEL inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"routeId == %d", route];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *stops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Stop *stop in stops) {
        [self.managedObjectContext deleteObject:stop];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
