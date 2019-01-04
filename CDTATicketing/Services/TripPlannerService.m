//
//  TripPlannerService.m
//  CDTA
//
//  Created by CooCooTech on 10/10/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TripPlannerService.h"
#import "CDTARuntimeData.h"
#import "DirectionLeg.h"
#import "DirectionRoute.h"
#import "Directions.h"
#import "DirectionStep.h"
#import "TransitAgency.h"

@implementation TripPlannerService
{
    NSString *originName;
    double originLatitude;
    double originLongitude;
    NSString *destinationName;
    double destinationLatitude;
    double destinationLongitude;
    NSDate *scheduleTime;
    BOOL isArriving;
}

- (id)initWithListener:(id)listener
            originName:(NSString *)origName
        originLatitude:(double)origLat
       originLongitude:(double)origLng
       destinationName:(NSString *)destName
   destinationLatitude:(double)destLat
  destinationLongitude:(double)destLng
          scheduleTime:(NSDate *)time
            isArriving:(BOOL)arriving
{
    self = [super init];
    if (self) {
        self.method = METHOD_SIMPLE_JSON;
        self.listener = listener;
        originName = origName;
        originLatitude = origLat;
        originLongitude = origLng;
        destinationName = destName;
        destinationLatitude = destLat;
        destinationLongitude = destLng;
        scheduleTime = time;
        isArriving = arriving;
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
    NSString *coordinatesString = [NSString stringWithFormat:@"origin=%f,%f&destination=%f,%f",
                                   originLatitude, originLongitude, destinationLatitude, destinationLongitude];
    
    NSString *timeString = isArriving ? [NSString stringWithFormat:@"&arrival_time=%.0f", [scheduleTime timeIntervalSince1970]]
    : [NSString stringWithFormat:@"&departure_time=%.0f", [scheduleTime timeIntervalSince1970]];
    
    NSLog(@"request: %@", [NSString stringWithFormat:@"maps/api/directions/json?sensor=false&mode=transit&alternatives=true&%@%@",
                           coordinatesString, timeString]);
    
    return [NSString stringWithFormat:@"maps/api/directions/json?sensor=false&mode=transit&alternatives=true&%@%@",
            coordinatesString, timeString];
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
    Directions *directions = [[Directions alloc] init];
    [directions setStatus:[json valueForKey:@"status"]];
    
    NSMutableArray *routesArray = [[NSMutableArray alloc] init];
    
    NSArray *routes = [json valueForKey:@"routes"];
    for (NSDictionary *routeJson in routes) {
        DirectionRoute *route = [[DirectionRoute alloc] init];
        
        NSDictionary *boundsDictionary = [routeJson objectForKey:@"bounds"];
        if (boundsDictionary != nil) {
            Bounds *bounds = [[Bounds alloc] init];
            
            NSDictionary *northeastLocationDictionary = [boundsDictionary objectForKey:@"northeast"];
            if (northeastLocationDictionary != nil) {
                Location *northeastLocation = [[Location alloc] init];
                [northeastLocation setLatitude:[[northeastLocationDictionary objectForKey:@"lat"] doubleValue]];
                [northeastLocation setLongitude:[[northeastLocationDictionary objectForKey:@"lng"] doubleValue]];
                
                [bounds setNortheast:northeastLocation];
            }
            
            NSDictionary *southwestLocationDictionary = [boundsDictionary objectForKey:@"southwest"];
            if (southwestLocationDictionary != nil) {
                Location *southwestLocation = [[Location alloc] init];
                [southwestLocation setLatitude:[[southwestLocationDictionary objectForKey:@"lat"] doubleValue]];
                [southwestLocation setLongitude:[[southwestLocationDictionary objectForKey:@"lng"] doubleValue]];
                
                [bounds setSouthwest:southwestLocation];
            }
            
            [route setBounds:bounds];
        }
        
        [route setCopyrights:[routeJson objectForKey:@"copyrights"]];
        
        NSMutableArray *legsArray = [[NSMutableArray alloc] init];
        
        NSArray *legs = [routeJson objectForKey:@"legs"];
        for (NSDictionary *legJson in legs) {
            DirectionLeg *leg = [[DirectionLeg alloc] init];
            
            NSDictionary *arrivalTimeDictionary = [legJson objectForKey:@"arrival_time"];
            if (arrivalTimeDictionary != nil) {
                DirectionTime *legArrivalTime = [[DirectionTime alloc] init];
                [legArrivalTime setText:[arrivalTimeDictionary objectForKey:@"text"]];
                [legArrivalTime setTimeZone:[arrivalTimeDictionary objectForKey:@"time_zone"]];
                [legArrivalTime setTimeValue:[[arrivalTimeDictionary objectForKey:@"value"] doubleValue]];
                
                [leg setArrivalTime:legArrivalTime];
            }
            
            NSDictionary *departureTimeDictionary = [legJson objectForKey:@"departure_time"];
            if (departureTimeDictionary != nil) {
                DirectionTime *legDepartureTime = [[DirectionTime alloc] init];
                [legDepartureTime setText:[departureTimeDictionary objectForKey:@"text"]];
                [legDepartureTime setTimeZone:[departureTimeDictionary objectForKey:@"time_zone"]];
                [legDepartureTime setTimeValue:[[departureTimeDictionary objectForKey:@"value"] doubleValue]];
                
                [leg setDepartureTime:legDepartureTime];
            }
            
            NSDictionary *legDistanceDictionary = [legJson objectForKey:@"distance"];
            if (legDistanceDictionary != nil) {
                Distance *distance = [[Distance alloc] init];
                [distance setText:[legDistanceDictionary objectForKey:@"text"]];
                [distance setDistanceValue:[[legDistanceDictionary objectForKey:@"value"] intValue]];
                
                [leg setDistance:distance];
            }
            
            NSDictionary *legDurationDictionary = [legJson objectForKey:@"duration"];
            if (legDurationDictionary != nil) {
                DirectionDuration *duration = [[DirectionDuration alloc] init];
                [duration setText:[legDurationDictionary objectForKey:@"text"]];
                [duration setDurationValue:[[legDurationDictionary objectForKey:@"value"] intValue]];
                
                [leg setDuration:duration];
            }
            
            [leg setEndAddress:[legJson objectForKey:@"end_address"]];
            
            NSDictionary *endLocationDictionary = [legJson objectForKey:@"end_location"];
            if (endLocationDictionary != nil) {
                Location *endLocation = [[Location alloc] init];
                [endLocation setLatitude:[[endLocationDictionary objectForKey:@"lat"] doubleValue]];
                [endLocation setLongitude:[[endLocationDictionary objectForKey:@"lng"] doubleValue]];
                
                [leg setEndLocation:endLocation];
            }
            
            [leg setStartAddress:[legJson objectForKey:@"start_address"]];
            
            NSDictionary *startLocationDictionary = [legJson objectForKey:@"start_location"];
            if (startLocationDictionary != nil) {
                Location *startLocation = [[Location alloc] init];
                [startLocation setLatitude:[[startLocationDictionary objectForKey:@"lat"] doubleValue]];
                [startLocation setLongitude:[[startLocationDictionary objectForKey:@"lng"] doubleValue]];
                
                [leg setStartLocation:startLocation];
            }
            
            NSMutableArray *stepsArray = [[NSMutableArray alloc] init];
            
            NSArray *steps = [legJson objectForKey:@"steps"];
            for (NSDictionary *stepJson in steps) {
                DirectionStep *step = [[DirectionStep alloc] init];
                
                NSDictionary *stepDistanceDictionary = [stepJson objectForKey:@"distance"];
                if (stepDistanceDictionary != nil) {
                    Distance *distance = [[Distance alloc] init];
                    [distance setText:[stepDistanceDictionary objectForKey:@"text"]];
                    [distance setDistanceValue:[[stepDistanceDictionary objectForKey:@"value"] intValue]];
                    
                    [step setDistance:distance];
                }
                
                NSDictionary *stepDurationDictionary = [stepJson objectForKey:@"duration"];
                if (stepDurationDictionary != nil) {
                    DirectionDuration *duration = [[DirectionDuration alloc] init];
                    [duration setText:[stepDurationDictionary objectForKey:@"text"]];
                    [duration setDurationValue:[[stepDurationDictionary objectForKey:@"value"] intValue]];
                    
                    [step setDuration:duration];
                }
                
                NSDictionary *stepEndLocationDictionary = [stepJson objectForKey:@"end_location"];
                if (stepEndLocationDictionary != nil) {
                    Location *endLocation = [[Location alloc] init];
                    [endLocation setLatitude:[[stepEndLocationDictionary objectForKey:@"lat"] doubleValue]];
                    [endLocation setLongitude:[[stepEndLocationDictionary objectForKey:@"lng"] doubleValue]];
                    
                    [step setEndLocation:endLocation];
                }
                
                [step setHtmlInstructions:[stepJson objectForKey:@"html_instructions"]];
                
                NSDictionary *stepPolylineDictionary = [stepJson objectForKey:@"polyline"];
                if (stepPolylineDictionary != nil) {
                    Polyline *polyline = [[Polyline alloc] init];
                    [polyline setPoints:[stepPolylineDictionary objectForKey:@"points"]];
                    
                    [step setPolyline:polyline];
                }
                
                NSDictionary *stepStartLocationDictionary = [stepJson objectForKey:@"start_location"];
                if (stepStartLocationDictionary != nil) {
                    Location *startLocation = [[Location alloc] init];
                    [startLocation setLatitude:[[stepStartLocationDictionary objectForKey:@"lat"] doubleValue]];
                    [startLocation setLongitude:[[stepStartLocationDictionary objectForKey:@"lng"] doubleValue]];
                    
                    [step setStartLocation:startLocation];
                }
                
                NSMutableArray *subStepsArray = [[NSMutableArray alloc] init];
                
                NSArray *subSteps = [stepJson objectForKey:@"steps"];
                for (NSDictionary *subStepJson in subSteps) {
                    DirectionStep *subStep = [[DirectionStep alloc] init];
                    
                    NSDictionary *subStepDistanceDictionary = [subStepJson objectForKey:@"distance"];
                    if (subStepDistanceDictionary != nil) {
                        Distance *distance = [[Distance alloc] init];
                        [distance setText:[subStepDistanceDictionary objectForKey:@"text"]];
                        [distance setDistanceValue:[[subStepDistanceDictionary objectForKey:@"value"] intValue]];
                        
                        [subStep setDistance:distance];
                    }
                    
                    NSDictionary *subStepDurationDictionary = [subStepJson objectForKey:@"duration"];
                    if (subStepDurationDictionary != nil) {
                        DirectionDuration *duration = [[DirectionDuration alloc] init];
                        [duration setText:[subStepDurationDictionary objectForKey:@"text"]];
                        [duration setDurationValue:[[subStepDurationDictionary objectForKey:@"value"] intValue]];
                        
                        [subStep setDuration:duration];
                    }
                    
                    NSDictionary *subStepEndLocationDictionary = [subStepJson objectForKey:@"end_location"];
                    if (subStepEndLocationDictionary != nil) {
                        Location *endLocation = [[Location alloc] init];
                        [endLocation setLatitude:[[subStepEndLocationDictionary objectForKey:@"lat"] doubleValue]];
                        [endLocation setLongitude:[[subStepEndLocationDictionary objectForKey:@"lng"] doubleValue]];
                        
                        [subStep setEndLocation:endLocation];
                    }
                    
                    [subStep setHtmlInstructions:[subStepJson objectForKey:@"html_instructions"]];
                    
                    NSDictionary *subStepPolylineDictionary = [subStepJson objectForKey:@"polyline"];
                    if (subStepPolylineDictionary != nil) {
                        Polyline *polyline = [[Polyline alloc] init];
                        [polyline setPoints:[subStepPolylineDictionary objectForKey:@"points"]];
                        
                        [subStep setPolyline:polyline];
                    }
                    
                    NSDictionary *subStepStartLocationDictionary = [subStepJson objectForKey:@"start_location"];
                    if (subStepStartLocationDictionary != nil) {
                        Location *startLocation = [[Location alloc] init];
                        [startLocation setLatitude:[[subStepStartLocationDictionary objectForKey:@"lat"] doubleValue]];
                        [startLocation setLongitude:[[subStepStartLocationDictionary objectForKey:@"lng"] doubleValue]];
                        
                        [subStep setStartLocation:startLocation];
                    }
                    
                    [subStep setTravelMode:[subStepJson objectForKey:@"travel_mode"]];
                    [subStepsArray addObject:subStep];
                }
                
                [step setSubSteps:[subStepsArray copy]];
                
                NSDictionary *transitDetailsDictionary = [stepJson objectForKey:@"transit_details"];
                if (transitDetailsDictionary != nil) {
                    TransitDetails *transitDetails = [[TransitDetails alloc] init];
                    
                    NSDictionary *arrivalStopDictionary = [transitDetailsDictionary objectForKey:@"arrival_stop"];
                    if (arrivalStopDictionary != nil) {
                        TransitStop *arrivalStop = [[TransitStop alloc] init];
                        
                        NSDictionary *locationDictionary = [arrivalStopDictionary objectForKey:@"location"];
                        if (locationDictionary != nil) {
                            Location *location = [[Location alloc] init];
                            [location setLatitude:[[locationDictionary objectForKey:@"lat"] doubleValue]];
                            [location setLongitude:[[locationDictionary objectForKey:@"lng"] doubleValue]];
                            
                            [arrivalStop setLocation:location];
                        }
                        
                        [arrivalStop setName:[arrivalStopDictionary objectForKey:@"name"]];
                        
                        [transitDetails setArrivalStop:arrivalStop];
                    }
                    
                    NSDictionary *arrivalTimeDictionary = [transitDetailsDictionary objectForKey:@"arrival_time"];
                    if (arrivalTimeDictionary != nil) {
                        DirectionTime *arrivalTime = [[DirectionTime alloc] init];
                        [arrivalTime setText:[arrivalTimeDictionary objectForKey:@"text"]];
                        [arrivalTime setTimeZone:[arrivalTimeDictionary objectForKey:@"time_zone"]];
                        [arrivalTime setTimeValue:[[arrivalTimeDictionary objectForKey:@"value"] doubleValue]];
                        
                        [transitDetails setArrivalTime:arrivalTime];
                    }
                    
                    NSDictionary *departureStopDictionary = [transitDetailsDictionary objectForKey:@"departure_stop"];
                    if (departureStopDictionary != nil) {
                        TransitStop *departureStop = [[TransitStop alloc] init];
                        
                        NSDictionary *locationDictionary = [departureStopDictionary objectForKey:@"location"];
                        if (locationDictionary != nil) {
                            Location *location = [[Location alloc] init];
                            [location setLatitude:[[locationDictionary objectForKey:@"lat"] doubleValue]];
                            [location setLongitude:[[locationDictionary objectForKey:@"lng"] doubleValue]];
                            
                            [departureStop setLocation:location];
                        }
                        
                        [departureStop setName:[departureStopDictionary objectForKey:@"name"]];
                        
                        [transitDetails setDepartureStop:departureStop];
                    }
                    
                    NSDictionary *departureTimeDictionary = [transitDetailsDictionary objectForKey:@"departure_time"];
                    if (departureTimeDictionary != nil) {
                        DirectionTime *departureTime = [[DirectionTime alloc] init];
                        [departureTime setText:[departureTimeDictionary objectForKey:@"text"]];
                        [departureTime setTimeZone:[departureTimeDictionary objectForKey:@"time_zone"]];
                        [departureTime setTimeValue:[[departureTimeDictionary objectForKey:@"value"] doubleValue]];
                        
                        [transitDetails setDepartureTime:departureTime];
                    }
                    
                    [transitDetails setHeadsign:[transitDetailsDictionary objectForKey:@"headsign"]];
                    
                    NSDictionary *lineDictionary = [transitDetailsDictionary objectForKey:@"line"];
                    if (lineDictionary != nil) {
                        TransitLine *line = [[TransitLine alloc] init];
                        
                        NSMutableArray *agenciesArray = [[NSMutableArray alloc] init];
                        
                        NSArray *agencies = [lineDictionary objectForKey:@"agencies"];
                        for (NSDictionary *agencyJson in agencies) {
                            TransitAgency *agency = [[TransitAgency alloc] init];
                            [agency setName:[agencyJson objectForKey:@"name"]];
                            [agency setPhone:[agencyJson objectForKey:@"phone"]];
                            [agency setUrl:[agencyJson objectForKey:@"url"]];
                            
                            [agenciesArray addObject:agency];
                        }
                        
                        [line setAgencies:[agenciesArray copy]];
                        [line setColor:[lineDictionary objectForKey:@"color"]];
                        [line setName:[lineDictionary objectForKey:@"name"]];
                        [line setShortName:[lineDictionary objectForKey:@"short_name"]];
                        [line setTextColor:[lineDictionary objectForKey:@"text_color"]];
                        [line setUrl:[lineDictionary objectForKey:@"url"]];
                        
                        NSDictionary *vehicleDictionary = [lineDictionary objectForKey:@"vehicle"];
                        if (vehicleDictionary != nil) {
                            Vehicle *vehicle = [[Vehicle alloc] init];
                            [vehicle setIcon:[vehicleDictionary objectForKey:@"icon"]];
                            [vehicle setName:[vehicleDictionary objectForKey:@"name"]];
                            [vehicle setType:[vehicleDictionary objectForKey:@"type"]];
                            
                            [line setVehicle:vehicle];
                        }
                        
                        [transitDetails setLine:line];
                    }
                    
                    [transitDetails setNumberOfStops:[[transitDetailsDictionary objectForKey:@"num_stops"] intValue]];
                    
                    [step setTransitDetails:transitDetails];
                }
                
                [step setTravelMode:[stepJson objectForKey:@"travel_mode"]];
                
                [stepsArray addObject:step];
            }
            
            [leg setSteps:[stepsArray copy]];
            
            [legsArray addObject:leg];
        }
        
        [route setLegs:[legsArray copy]];
        
        NSDictionary *overviewPolylineDictionary = [routeJson objectForKey:@"overview_polyline"];
        if (overviewPolylineDictionary != nil) {
            Polyline *overviewPolyline = [[Polyline alloc] init];
            [overviewPolyline setPoints:[overviewPolylineDictionary objectForKey:@"points"]];
            
            [route setOverviewPolyline:overviewPolyline];
        }
        
        [route setSummary:[routeJson objectForKey:@"summary"]];
        [route setWarnings:[routeJson objectForKey:@"warnings"]];
        
        [routesArray addObject:route];
        
        [directions setRoutes:[routesArray copy]];
        
        [[CDTARuntimeData instance] setTripDirections:directions];
    }
}

@end
