//
//  GeocodingService.m
//  CDTA
//
//  Created by CooCooTech on 4/14/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "GeocodingService.h"
#import "CDTARuntimeData.h"
#import "SearchedAddress.h"

@implementation GeocodingService
{
    NSString *address;
}

- (id)initWithListener:(id)listener
               address:(NSString *)addr
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
        address = addr;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return @"maps.googleapis.com";
}

- (NSString *)uri
{
    address = [address stringByAppendingString:@" New York"];
    NSString *formattedAddress = [address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    return [NSString stringWithFormat:@"maps/api/geocode/json?address=%@&sensor=false", formattedAddress];
}

- (NSDictionary *)headers
{
    return nil;
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([[json valueForKey:@"status"] isEqualToString:@"OK"]) {
        [self setDataWithJson:json];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSMutableArray *searchedAddresses = [[NSMutableArray alloc] init];
    
    NSArray *results = [json valueForKey:@"results"];
    for (NSDictionary *resultsJson in results) {
        SearchedAddress *searchedAddress = [[SearchedAddress alloc] init];
        
        [searchedAddress setAddress:[resultsJson objectForKey:@"formatted_address"]];
        
        NSDictionary *geometryDictionary = [resultsJson objectForKey:@"geometry"];
        if (geometryDictionary != nil) {
            NSDictionary *locationDictionary = [geometryDictionary objectForKey:@"location"];
            
            if (locationDictionary != nil) {
                [searchedAddress setLatitude:[[locationDictionary objectForKey:@"lat"] doubleValue]];
                [searchedAddress setLongitude:[[locationDictionary objectForKey:@"lng"] doubleValue]];
            }
        }
        
        [searchedAddresses addObject:searchedAddress];
    }
    
    [[CDTARuntimeData instance] setSearchedAddresses:searchedAddresses];
}

@end
