//
//  GetRoutesService.m
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetRoutesService.h"
#import "CDTAUtilities.h"
#import "Route.h"

@implementation GetRoutesService
{
}

- (id)initWithListener:(id)listener managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
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
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        return @"api/v1/?request=routes";
    }else if ([tenantId isEqualToString:@"CDTA"]){
        return @"api/v1/?request=routes";
    }else{}
    return @"api/v1/?request=routes";
}

- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    [headers setObject:[CDTAUtilities fetchScheduleKey] forKey:@"key"];
    NSString * currentAppVersion = [Utilities appCurrentVersion];
    [headers setValue:@"iOS" forKey:@"app_os"];
    [headers setValue:currentAppVersion forKey:@"app_version"];
    
    
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
        [self deleteRoutes];
        [self setDataWithJson:json];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSArray *routes = [json objectForKey:@"routes"];
    for (NSDictionary *routeJson in routes) {
        Route *route = (Route *)[NSEntityDescription insertNewObjectForEntityForName:ROUTE_MODEL
                                                              inManagedObjectContext:self.managedObjectContext];
        
        [route setMapImageUrl:[routeJson objectForKey:@"map_image_url"]];
        [route setMapKmlUrl:[routeJson objectForKey:@"map_kml_url"]];
        [route setColor:[routeJson objectForKey:@"route_color"]];
        [route setDirectionUri:[routeJson objectForKey:@"route_direction_uri"]];
        [route setRouteId:[NSNumber numberWithInt:[[routeJson objectForKey:@"route_id"] intValue]]];
        [route setName:[routeJson objectForKey:@"route_name"]];
        [route setTextColor:[routeJson objectForKey:@"route_text_color"]];
        [route setUri:[routeJson objectForKey:@"route_uri"]];
        [route setScheduleUrl:[routeJson objectForKey:@"schedule_url"]];
        [route setRouteDescription:[routeJson objectForKey:@"route_description"]];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        }
    }
}

- (void)deleteRoutes
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:ROUTE_MODEL inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *routes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Route *route in routes) {
        [self.managedObjectContext deleteObject:route];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
