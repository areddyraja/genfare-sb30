//
//  GetNearbyStopsService.m
//  CDTA
//
//  Created by CooCooTech on 10/23/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetNearbyStopsService.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
#import "NearbyStop.h"
#import "ServiceRoute.h"

@implementation GetNearbyStopsService
{
    double latitude;
    double longitude;
    int count;
}

- (id)initWithListener:(id)listener
              latitude:(double)lat
             longitude:(double)lon
                 count:(int)c
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
        latitude = lat;
        longitude = lon;
        count = c;
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
    return [NSString stringWithFormat:@"api/v1/?request=nearstops/%f/%f/%d", latitude, longitude, count];
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
        [self setDataWithJson:json];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSMutableArray *nearbyStops = [[NSMutableArray alloc] init];
    
    NSArray *stops = [json objectForKey:@"stops"];
    for (NSDictionary *stopJson in stops) {
        NearbyStop *nearbyStop = [[NearbyStop alloc] init];
        
        [nearbyStop setDistanceInDegrees:[[stopJson objectForKey:@"distance_degrees"] doubleValue]];
        [nearbyStop setDistanceInFeet:[[stopJson objectForKey:@"distance_feet"] doubleValue]];
        [nearbyStop setLatitude:[[stopJson objectForKey:@"latitude"] doubleValue]];
        [nearbyStop setLongitude:[[stopJson objectForKey:@"longitude"] doubleValue]];
        [nearbyStop setName:[stopJson objectForKey:@"name"]];
        
        NSDictionary *serviceRoutes = [stopJson objectForKey:@"serviced_by"];
        if (serviceRoutes && ![[NSNull null] isEqual:serviceRoutes]) {
            NSArray *keys = [serviceRoutes allKeys];
            NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber *route1 = [NSNumber numberWithInt:[obj1 intValue]];
                NSNumber *route2 = [NSNumber numberWithInt:[obj2 intValue]];
                return (NSComparisonResult)[route1 compare:route2];
            }];
            
            NSMutableArray *routes = [[NSMutableArray alloc] init];
            
            for (NSString *key in sortedKeys) {
                NSDictionary *routeJson = [serviceRoutes objectForKey:key];
                
                ServiceRoute *route = [[ServiceRoute alloc] init];
                [route setRouteId:[[routeJson objectForKey:@"route_id"] intValue]];
                [route setDirection:[routeJson objectForKey:@"direction"]];
                
                [routes addObject:route];
            }
            
            [nearbyStop setServicedBy:[routes copy]];
        }
        
        [nearbyStop setStopId:[[stopJson objectForKey:@"stop_id"] intValue]];
        
        [nearbyStops addObject:nearbyStop];
    }
    
    NSArray *landmarks = [json objectForKey:@"landmarks"];
    for (NSDictionary *landmarkJson in landmarks) {
        NearbyStop *nearbyLandmark = [[NearbyStop alloc] init];
        
        [nearbyLandmark setDistanceInDegrees:[[landmarkJson objectForKey:@"distance_degrees"] doubleValue]];
        [nearbyLandmark setDistanceInFeet:[[landmarkJson objectForKey:@"distance_feet"] doubleValue]];
        [nearbyLandmark setLatitude:[[landmarkJson objectForKey:@"latitude"] doubleValue]];
        [nearbyLandmark setLongitude:[[landmarkJson objectForKey:@"longitude"] doubleValue]];
        [nearbyLandmark setName:[landmarkJson objectForKey:@"name"]];
        [nearbyLandmark setStopId:0];
        
        [nearbyStops addObject:nearbyLandmark];
    }
    
    [[CDTARuntimeData instance] setNearbyStops:[nearbyStops copy]];
}

@end
