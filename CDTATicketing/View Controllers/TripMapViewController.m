//
//  TripMapViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/15/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TripMapViewController.h"
#import "CooCooBase.h"
#import <GoogleMaps/GoogleMaps.h>
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "DirectionLeg.h"
#import "DirectionRoute.h"
#import "DirectionStep.h"
//#import "LogoBarButtonItem.h"
#import "RouteBadge.h"
#import "TripRouteCell.h"

NSString *const TRIP_MAP_TITLE = @"Trip Map";
NSString *const WALKING_LINE_COLOR = @"#DA90EF";
float const INSTRUCTIONS_PADDING = 20.0f;
double const ROUTE_BADGE_OFFSET = 0.0001;

@interface TripMapViewController ()

@end

@implementation TripMapViewController
{
    //LogoBarButtonItem *logoBarButton;
    GMSMapView *mapView;
    UIView *instructionsView;
    UILabel *instructionsLabel;
    NSArray *routes;
    GMSMutablePath *overviewPath;
    NSMutableArray *overviewMarkers;
    NSArray *warnings;
    NSMutableArray *steps;
    int stepsIndex;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:TRIP_MAP_TITLE];
        [self setTitle:TRIP_MAP_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        
        instructionsView = [[UIView alloc] init];
        [instructionsView setBackgroundColor:[UIColor darkGrayColor]];
        [instructionsView setAlpha:0.8f];
        
        instructionsLabel = [[UILabel alloc] init];
        [instructionsLabel setBackgroundColor:[UIColor clearColor]];
        [instructionsLabel setTextColor:[UIColor whiteColor]];
        [instructionsLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [instructionsLabel setNumberOfLines:0];
        
        warnings = [[NSArray alloc] init];
        
        overviewMarkers = [[NSMutableArray alloc] init];
        
        steps = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
    
    NSString *routeIdsString;
    
    NSInteger count = [self.routeIds count];
    if (count > 0) {
        routeIdsString = @"Route Ids: ";
        
        for (int i = 0; i < count; i++) {
            if (i == count - 1) {
                routeIdsString = [routeIdsString stringByAppendingString:[self.routeIds objectAtIndex:i]];
            } else {
                routeIdsString = [routeIdsString stringByAppendingString:[NSString stringWithFormat:@"%@, ", [self.routeIds objectAtIndex:i]]];
            }
        }
    } else {
        routeIdsString = @"No transit steps";
    }
    
    [self setViewDetails:[NSString stringWithFormat:@"%@(%05d) to %@(%05d), %@",
                          self.originName, self.originId, self.destinationName, self.destinationId, routeIdsString]];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    [instructionsView addSubview:instructionsLabel];
    [self.view addSubview:instructionsView];
    
    CGRect maxFrame = [self maximumUsableFrame];
    
    mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0, 0, maxFrame.size.width, maxFrame.size.height)];
    [self.mapContainerView addSubview:mapView];
    
    [self setMapInfoWithRoute:self.directionRoute];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Trip Planner origin or destination had just been set from Stop Info screen, so go back to main Trip Planner screen
    if (([[CDTARuntimeData instance] fromStopId] != 0) ||
        (([[CDTARuntimeData instance] fromStopLatitude] != 0) && ([[CDTARuntimeData instance] fromStopLongitude] != 0)) ||
        ([[CDTARuntimeData instance] toStopId] != 0) ||
        (([[CDTARuntimeData instance] toStopLatitude] != 0) && ([[CDTARuntimeData instance] toStopLongitude] != 0))) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMapInfoWithRoute:(DirectionRoute *)route
{
    [steps removeAllObjects];
    [mapView clear];
    stepsIndex = 0;
    
    Bounds *routeBounds = route.bounds;
    Location *northeastBound = routeBounds.northeast;
    Location *southwestBound = routeBounds.southwest;
    
    CLLocationCoordinate2D northeast = CLLocationCoordinate2DMake(northeastBound.latitude, northeastBound.longitude);
    CLLocationCoordinate2D southwest = CLLocationCoordinate2DMake(southwestBound.latitude, southwestBound.longitude);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northeast coordinate:southwest];
    GMSCameraPosition *camera = [mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(VIEW_PADDING, VIEW_PADDING, VIEW_PADDING, VIEW_PADDING)];
    
    [mapView setCamera:camera];
    
    NSArray *polylinePoints = [self decodePolyline:route.overviewPolyline.points];
    
    overviewPath = [GMSMutablePath path];
    for (CLLocation *location in polylinePoints) {
        [overviewPath addCoordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)];
    }
    
    [self addPolylineWithPath:overviewPath color:nil];
    
    // Transit directions don't have waypoints so there is only one leg
    DirectionLeg *leg = [[route legs] objectAtIndex:0];
    
    DirectionStep *overviewStep = [[DirectionStep alloc] init];
    [overviewStep setDistance:leg.distance];
    [overviewStep setDuration:leg.duration];
    [overviewStep setEndLocation:leg.endLocation];
    [overviewStep setStartLocation:leg.startLocation];
    
    if (([leg.departureTime.text length] == 0) || ([leg.arrivalTime.text length] == 0)) {
        [overviewStep setHtmlInstructions:[NSString stringWithFormat:@"Start: %@\nEnd: %@\nDistance: %@ | Duration: %@",
                                           leg.startAddress,
                                           leg.endAddress,
                                           leg.distance.text,
                                           leg.duration.text]];
    } else {
        [overviewStep setHtmlInstructions:[NSString stringWithFormat:@"Start: %@\nEnd: %@\nDepart: %@ | Arrive: %@\nDistance: %@ | Duration: %@",
                                           leg.startAddress,
                                           leg.endAddress,
                                           leg.departureTime.text,
                                           leg.arrivalTime.text,
                                           leg.distance.text,
                                           leg.duration.text]];
    }
    
    [steps addObject:overviewStep];
    
    for (DirectionStep *step in [leg steps]) {
        NSArray *subSteps = [step subSteps];
        
        [steps addObject:step];
        
        if ([subSteps count] > 0) {
            for (DirectionStep *subStep in subSteps) {
                [steps addObject:subStep];
                
                Location *startLocation = subStep.startLocation;
                CLLocation *startMarker = [[CLLocation alloc] initWithLatitude:startLocation.latitude
                                                                     longitude:startLocation.longitude];
                
                [self addLocationIfNew:startMarker array:overviewMarkers];
                
                Location *endLocation = subStep.endLocation;
                CLLocation *endMarker = [[CLLocation alloc] initWithLatitude:endLocation.latitude
                                                                   longitude:endLocation.longitude];
                
                [self addLocationIfNew:endMarker array:overviewMarkers];
            }
        } else {
            Location *startLocation = step.startLocation;
            CLLocation *startMarker = [[CLLocation alloc] initWithLatitude:startLocation.latitude
                                                                 longitude:startLocation.longitude];
            
            [self addLocationIfNew:startMarker array:overviewMarkers];
            
            Location *endLocation = step.endLocation;
            CLLocation *endMarker = [[CLLocation alloc] initWithLatitude:endLocation.latitude
                                                               longitude:endLocation.longitude];
            
            [self addLocationIfNew:endMarker array:overviewMarkers];
        }
    }
    
    [self addOverviewMarkers];
    
    [instructionsLabel setText:[self stringFromHtml:overviewStep.htmlInstructions]];
    [self resizeInstructionsView];
    
    warnings = route.warnings;
    
    [instructionsView setHidden:NO];
    [self.previousStepLabel setHidden:NO];
    [self.nextStepLabel setHidden:NO];
}

#pragma mark - UIResponder methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (touch.view.tag == 1 || touch.view.tag == 2) {
        UIColor *highlightColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        
        if (touch.view.tag == 1) {
            [self.previousStepLabel setTextColor:highlightColor];
            [self addValueToStepIndex:-1];
        } else {
            [self.nextStepLabel setTextColor:highlightColor];
            [self addValueToStepIndex:1];
        }
        
        DirectionStep *step = [steps objectAtIndex:stepsIndex];
        
        if (stepsIndex == 0) {
            [instructionsLabel setText:[self stringFromHtml:step.htmlInstructions]];
            
            [mapView clear];
            
            [self addPolylineWithPath:overviewPath color:nil];
            [self addOverviewMarkers];
        } else {
            [mapView clear];
            [self addPolylineWithPath:overviewPath color:nil];
            
            NSArray *polylinePoints = [self decodePolyline:step.polyline.points];
            
            GMSMutablePath *path = [GMSMutablePath path];
            for (CLLocation *location in polylinePoints) {
                [path addCoordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)];
            }
            
            NSString *instructions = @"";
            
            if ([step.travelMode isEqualToString:MODE_TRANSIT]) {
                TransitDetails *transitDetails = step.transitDetails;
                
                if ([step.htmlInstructions length] > 0) {
                    instructions = step.htmlInstructions;
                }
                
                NSString *boardString = @"";
                if (![transitDetails.line.shortName isEqual:[NSNull null]] && ([transitDetails.line.shortName length] > 0)) {
                    boardString = [NSString stringWithFormat:@" Route #%@", transitDetails.line.shortName];
                }
                
                [instructionsLabel setText:[self stringFromHtml:[NSString stringWithFormat:@"Board%@: %@ %@\nStart: %@\nEnd: %@\nDepart: %@ | Arrive: %@\nDistance: %@ | Duration: %@",
                                                                 boardString,
                                                                 transitDetails.line.name,
                                                                 instructions,
                                                                 transitDetails.departureStop.name,
                                                                 transitDetails.arrivalStop.name,
                                                                 transitDetails.departureTime.text,
                                                                 transitDetails.arrivalTime.text,
                                                                 step.distance.text,
                                                                 step.duration.text]]];
                
                [self addPolylineWithPath:path color:transitDetails.line.color];
                
                RouteBadge *routeBadge = [[RouteBadge alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      ROUTE_BADGE_RADIUS_SMALL,
                                                                                      ROUTE_BADGE_RADIUS_SMALL)
                                                                badgeColor:[UIColor colorWithHexString:transitDetails.line.color]
                                                                      font:[UIFont boldSystemFontOfSize:10.0f]
                                                                 textColor:[UIColor colorWithHexString:transitDetails.line.textColor]
                                                                      text:transitDetails.line.shortName];
                
                GMSMarker *departureMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(transitDetails.departureStop.location.latitude,
                                                                                                      transitDetails.departureStop.location.longitude)];
                [departureMarker setTitle:transitDetails.departureStop.name];
                
                GMSMarker *arrivalMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(transitDetails.arrivalStop.location.latitude,
                                                                                                    transitDetails.arrivalStop.location.longitude)];
                [arrivalMarker setTitle:transitDetails.arrivalStop.name];
                
                GMSMarker *routeIdMarker = nil;
                
                double longitudeDelta = step.endLocation.longitude - step.startLocation.longitude;
                
                if (longitudeDelta >= 0.0f) {
                    routeIdMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(transitDetails.departureStop.location.latitude - ROUTE_BADGE_OFFSET,
                                                                                             transitDetails.departureStop.location.longitude - ROUTE_BADGE_OFFSET)];
                    
                    [departureMarker setIcon:[UIImage imageNamed:@"pin_trans_start_e"]];
                    [arrivalMarker setIcon:[UIImage imageNamed:@"pin_trans_end_e"]];
                } else {
                    routeIdMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(transitDetails.departureStop.location.latitude - ROUTE_BADGE_OFFSET,
                                                                                             transitDetails.departureStop.location.longitude + ROUTE_BADGE_OFFSET)];
                    
                    [departureMarker setIcon:[UIImage imageNamed:@"pin_trans_start_w"]];
                    [arrivalMarker setIcon:[UIImage imageNamed:@"pin_trans_end_w"]];
                }
                
                [departureMarker setMap:mapView];
                [arrivalMarker setMap:mapView];
                
                [routeIdMarker setIcon:routeBadge.image];
                [routeIdMarker setMap:mapView];
            } else {
                if ([step.htmlInstructions length] > 0) {
                    instructions = step.htmlInstructions;
                }
                
                NSString *warningString = @"";
                
                for (NSString *warning in warnings) {
                    warningString = [warningString stringByAppendingString:[NSString stringWithFormat:@"\n%@", warning]];
                }
                
                while ([warningString rangeOfString:@"  "].location != NSNotFound) {
                    warningString = [warningString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
                }
                
                [instructionsLabel setText:[self stringFromHtml:[NSString stringWithFormat:@"%@\nDistance: %@ | Duration: %@%@",
                                                                 instructions,
                                                                 step.distance.text,
                                                                 step.duration.text,
                                                                 warningString]]];
                
                [self addPolylineWithPath:path color:WALKING_LINE_COLOR];
                
                GMSMarker *startMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(step.startLocation.latitude,
                                                                                                  step.startLocation.longitude)];
                
                GMSMarker *endMarker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(step.endLocation.latitude,
                                                                                                step.endLocation.longitude)];
                
                if ([step.travelMode isEqualToString:MODE_WALKING]) {
                    double longitudeDelta = step.endLocation.longitude - step.startLocation.longitude;
                    
                    if (longitudeDelta >= 0.0f) {
                        [startMarker setIcon:[UIImage imageNamed:@"pin_walk_start_e"]];
                        [endMarker setIcon:[UIImage imageNamed:@"pin_walk_end_e"]];
                    } else {
                        [startMarker setIcon:[UIImage imageNamed:@"pin_walk_start_w"]];
                        [endMarker setIcon:[UIImage imageNamed:@"pin_walk_end_w"]];
                    }
                }
                
                [startMarker setMap:mapView];
                [endMarker setMap:mapView];
            }
        }
        
        [self resizeInstructionsView];
        
        CLLocationCoordinate2D startLocation = CLLocationCoordinate2DMake(step.startLocation.latitude, step.startLocation.longitude);
        CLLocationCoordinate2D endLocation = CLLocationCoordinate2DMake(step.endLocation.latitude, step.endLocation.longitude);
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:startLocation coordinate:endLocation];
        
        [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:(VIEW_PADDING * 8)]];
        
        [self.previousStepLabel setFrame:CGRectMake(self.previousStepLabel.frame.origin.x,
                                                    instructionsView.frame.origin.y + instructionsView.frame.size.height + 10,
                                                    self.previousStepLabel.frame.size.width,
                                                    self.previousStepLabel.frame.size.height)];
        
        [self.nextStepLabel setFrame:CGRectMake(self.nextStepLabel.frame.origin.x,
                                                instructionsView.frame.origin.y + instructionsView.frame.size.height + 10,
                                                self.nextStepLabel.frame.size.width,
                                                self.nextStepLabel.frame.size.height)];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.previousStepLabel setTextColor:[UIColor whiteColor]];
    [self.nextStepLabel setTextColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TripRouteCell";
    TripRouteCell *cell = (TripRouteCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell.frame.size.height;
}

- (void)addPolylineWithPath:(GMSPath *)path color:(NSString *)hexColor
{
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    [polyline setStrokeWidth:8.0f];
    
    if (hexColor != nil) {
        [polyline setStrokeColor:[UIColor colorWithHexString:hexColor]];
    }
    
    [polyline setMap:mapView];
}

- (void)addOverviewMarkers
{
    for (CLLocation *location in overviewMarkers) {
        GMSMarker *marker = [GMSMarker markerWithPosition:CLLocationCoordinate2DMake(location.coordinate.latitude,
                                                                                     location.coordinate.longitude)];
        [marker setMap:mapView];
    }
}

- (void)resizeInstructionsView
{
    CGRect applicationRect = [[UIScreen mainScreen] bounds];
    CGFloat viewWidth = applicationRect.size.width - 40;
    
    // "placeHolderView" is set in the XIB for origin and width values, but its frame height seems unable to change
    // Use "instructionsView" instead to allow for dynamic heights while referencing the positioning of placeHolderView
    
    CGRect resizedRect;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        resizedRect = [instructionsLabel.text boundingRectWithSize:CGSizeMake(viewWidth - (VIEW_PADDING * 2), CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:instructionsLabel.font}
                                                           context:nil];
    } else {
        CGSize size = [instructionsLabel.text sizeWithFont:instructionsLabel.font
                                         constrainedToSize:CGSizeMake(viewWidth - (VIEW_PADDING * 2), CGFLOAT_MAX)];
        resizedRect.size = size;
    }
    
    [instructionsLabel setFrame:CGRectMake(VIEW_PADDING, VIEW_PADDING, resizedRect.size.width, resizedRect.size.height)];
    
    [instructionsView setFrame:CGRectMake(self.placeHolderView.frame.origin.x,
                                          self.placeHolderView.frame.origin.y,
                                          viewWidth,
                                          resizedRect.size.height + (VIEW_PADDING * 2))];
}

- (void)addValueToStepIndex:(int)value
{
    if (stepsIndex + value >= (int)[steps count]) {
        stepsIndex = 0;
    } else if (stepsIndex + value < 0) {
        stepsIndex = (int)[steps count] - 1;
    } else {
        stepsIndex += value;
    }
}

- (NSString *)stringFromHtml:(NSString *)html
{
    NSMutableString *updatedString;
    
    if ([html length] > 0) {
        updatedString = [[NSMutableString alloc] initWithString:html];
        
        NSRange range;
        
        while ((range = [updatedString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
            [updatedString deleteCharactersInRange:range];
        }
    }
    
    return updatedString;
}

- (NSArray *)decodePolyline:(NSString *)encodedString
{
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    float lat = 0;
    float lng = 0;
    NSUInteger index = 0;
    
    while (index < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[index++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        lat += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[index++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        lng += deltaLon;
        
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        
        [locations addObject:location];
    }
    
    return [locations copy];
}

- (void)addLocationIfNew:(CLLocation *)newLocation array:(NSMutableArray *)array
{
    BOOL exists = NO;
    
    for (CLLocation *location in array) {
        if ([newLocation distanceFromLocation:location] == 0.0f) {
            exists = YES;
            break;
        }
    }
    
    if (!exists) {
        [array addObject:newLocation];
    }
}

- (CGRect)maximumUsableFrame
{
    static CGFloat const kNavigationBarPortraitHeight = 44;
    static CGFloat const kNavigationBarLandscapeHeight = 34;
    static CGFloat const kToolBarHeight = 49;
    
    // Start with the screen size minus the status bar if present
    CGRect maxFrame = [UIScreen mainScreen].applicationFrame;
    
    // If the orientation is landscape left or landscape right then swap the width and height
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        CGFloat temp = maxFrame.size.height;
        maxFrame.size.height = maxFrame.size.width;
        maxFrame.size.width = temp;
    }
    
    // Take into account if there is a navigation bar present and visible (note that if the NavigationBar may
    // not be visible at this stage in the view controller's lifecycle.  If the NavigationBar is shown/hidden
    // in the loadView then this provides an accurate result.  If the NavigationBar is shown/hidden using the
    // navigationController:willShowViewController: delegate method then this will not be accurate until the
    // viewDidAppear method is called.
    if (self.navigationController) {
        if (!self.navigationController.navigationBarHidden) {
            // Depending upon the orientation reduce the height accordingly
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                maxFrame.size.height -= kNavigationBarLandscapeHeight;
            } else {
                maxFrame.size.height -= kNavigationBarPortraitHeight;
            }
        }
    }
    
    // Take into account if there is a toolbar present and visible
    if (self.tabBarController) {
        if (!self.tabBarController.view.hidden) {
            maxFrame.size.height -= kToolBarHeight;
        }
    }
    
    if (self.helpSlider) {
        maxFrame.size.height -= HELP_SLIDER_HEIGHT;
    }
    
    return maxFrame;
}

@end
