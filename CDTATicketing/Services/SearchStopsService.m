//
//  SearchStopsService.m
//  CDTA
//
//  Created by CooCooTech on 12/18/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "SearchStopsService.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
#import "SearchedRoute.h"
#import "SearchedStop.h"

@implementation SearchStopsService

- (id)initWithListener:(id)listener
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
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
    NSString *formattedTerm = [self.searchTerm stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    return [NSString stringWithFormat:@"api/v1/?request=searchstops/%@", formattedTerm];
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
    NSMutableArray *stopsSearchResults = [[NSMutableArray alloc] init];
    
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    NSArray *stops = [json objectForKey:@"stops"];
    for (NSDictionary *stopsJson in stops) {
        SearchedStop *searchedStop = [[SearchedStop alloc] init];
        
        NSString *stopId = [stopsJson objectForKey:@"stop_id"];
        
        if ([stopId rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
            // string being searched consists only of the digits 0-9 and the '.' character
            [searchedStop setStopId:[stopId intValue]];
            [searchedStop setIsLandmark:NO];
        } else {
            [searchedStop setStopId:0];
            [searchedStop setIsLandmark:YES];
        }
        
        // Format stop name here to enable searching with ampersands
        [searchedStop setName:[CDTAUtilities formatLocationName:[stopsJson objectForKey:@"name"]]];
        
        [searchedStop setLatitude:[[stopsJson objectForKey:@"latitude"] doubleValue]];
        [searchedStop setLongitude:[[stopsJson objectForKey:@"longitude"] doubleValue]];
        
        NSMutableArray *servicedBy = [[NSMutableArray alloc] init];
        
        NSDictionary *servicedByDictionary = [stopsJson objectForKey:@"serviced_by"];
        NSEnumerator *enumerator = [servicedByDictionary keyEnumerator];
        
        id key;
        while (key = [enumerator nextObject]) {
            NSDictionary *routeJson = [servicedByDictionary objectForKey:key];
            
            if ([[routeJson objectForKey:@"route_id"] length] > 0) {
                SearchedRoute *searchedRoute = [[SearchedRoute alloc] init];
                [searchedRoute setRouteId:[[routeJson objectForKey:@"route_id"] intValue]];
                [searchedRoute setDirection:[routeJson objectForKey:@"direction"]];
                
                [servicedBy addObject:searchedRoute];
            }
        }
        
        [searchedStop setServicedBy:[servicedBy copy]];
        
        [stopsSearchResults addObject:searchedStop];
    }
    
    [[CDTARuntimeData instance] setSearchedStops:[stopsSearchResults copy]];
}

@end
