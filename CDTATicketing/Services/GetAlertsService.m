//
//  GetAlertsService.m
//  CDTA
//
//  Created by CooCooTech on 10/29/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//
#import "GetAlertsService.h"
#import "Alert.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
@implementation GetAlertsService
- (id)initWithListener:(id)listener{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
    }
    return self;
}
#pragma mark - Class overrides
- (NSString *)host{
    return [CDTAUtilities schedulesHost];
}
- (NSString *)uri{
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        return @"api/GetAlertDetails";
    }else if ([tenantId isEqualToString:@"CDTA"]){
        return @"api/v1/?request=alerts";
    }else{}
    return @"api/GetAlertDetails";
}
- (NSDictionary *)headers{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        [headers setValue:@"application/json" forKey:@"Accept"];
        NSString * currentAppVersion = [Utilities appCurrentVersion];
        [headers setValue:@"iOS" forKey:@"app_os"];
        [headers setValue:currentAppVersion forKey:@"app_version"];
        return headers;
    }else if ([tenantId isEqualToString:@"CDTA"]){
        [headers setObject:[CDTAUtilities fetchScheduleKey] forKey:@"key"];
        NSString * currentAppVersion = [Utilities appCurrentVersion];
        [headers setValue:@"iOS" forKey:@"app_os"];
        [headers setValue:currentAppVersion forKey:@"app_version"];
        return headers;
    }else{}
    return headers;
}
- (NSDictionary *)createRequest{
    return nil;
}
- (BOOL)processResponse:(id)serverResult{
    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    if ((json != nil) && [json count] > 0) {
        NSString *tenantId = [Utilities tenantId];
        if ([tenantId isEqualToString:@"COTA"]) {
            [self setDataWithJsonCota:json];
        }else if ([tenantId isEqualToString:@"CDTA"]){
            [self setDataWithJsonCdta:json];
        }else{}
//        [self setDataWithJson:json];
        return YES;
    }
    return NO;
}
#pragma mark - Other methods
- (void)setDataWithJsonCota:(NSDictionary *)json{
    NSMutableArray *alerts = [[NSMutableArray alloc] init];
    NSDictionary *dict = json;
    NSArray *alertsJsonArray = [dict objectForKey:@"_entity"];
    if (alertsJsonArray.count >0) {
        for (NSDictionary *alertJsonDict in alertsJsonArray) {
            NSArray * headersArray = [alertJsonDict valueForKeyPath:@"_alert._header_text._translation"];
            NSDictionary * textDictionary = [headersArray objectAtIndex:0];
            NSString * headerString = [textDictionary valueForKey:@"_text"];
            NSDictionary * descriptionString = [[alertJsonDict valueForKeyPath:@"_alert._description_text._translation"] objectAtIndex:0];
            Alert *alert = [[Alert alloc] init];
            [alert setHeader:[textDictionary valueForKey:@"_text"]];
            [alert setMessage:[descriptionString valueForKey:@"_text"]];
            //                [alert setRouteType:[alertJson objectForKey:@"route_type"]];
            [alerts addObject:alert];
        }
        //        [[[CDTARuntimeData instance] alerts] removeAllObjects];
        [[CDTARuntimeData instance] setAlerts:[alerts copy]];
    }
}
- (void)setDataWithJsonCdta:(NSDictionary *)json
{
    NSMutableArray *alerts = [[NSMutableArray alloc] init];
    
    NSArray *alertsJson = [json objectForKey:@"alerts"];
    for (NSDictionary *alertJson in alertsJson) {
        if (![[alertJson objectForKey:@"header"] isEqualToString:NO_ALERTS]) {
            Alert *alert = [[Alert alloc] init];
            
            NSMutableArray *routesArray =  [[NSMutableArray alloc] initWithArray:[alertJson objectForKey:@"routes"]];
            
            // "routes" object in json may just be an array of a single empty string
            NSInteger emptyIndex = [routesArray indexOfObject:@""];
            if (emptyIndex != NSNotFound) {
                [routesArray removeObjectAtIndex:emptyIndex];
            }
            
            NSArray *routeIds = [NSArray arrayWithArray:[routesArray copy]];
            
            [alert setRouteIds:routeIds];
            [alert setHeader:[alertJson objectForKey:@"header"]];
            [alert setMessage:[alertJson objectForKey:@"message"]];
            [alert setRouteType:[alertJson objectForKey:@"route_type"]];
            
            [alerts addObject:alert];
        }
    }
    
    [[CDTARuntimeData instance] setAlerts:[alerts copy]];
}
@end
