//
//  TripRoutesViewController.m
//  CDTA
//
//  Created by CooCooTech on 12/18/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TripRoutesViewController.h"
#import "CooCooBase.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "DirectionLeg.h"
#import "DirectionRoute.h"
#import "Directions.h"
#import "DirectionStep.h"
#import "RouteBadge.h"
#import "TripMapViewController.h"
#import "TripRouteCell.h"

NSString *const TRIP_ROUTES_TITLE = @"Trip Routes";

@interface TripRoutesViewController ()

@end

@implementation TripRoutesViewController
{
    NSArray *tripRoutes;
    NSMutableDictionary *routeIdsForRow;
    UILabel *emptyLabel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:TRIP_ROUTES_TITLE];
        [self setTitle:TRIP_ROUTES_TITLE];
        
        routeIdsForRow = [[NSMutableDictionary alloc] init];
        
        emptyLabel = [[UILabel alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setViewDetails:[NSString stringWithFormat:@"%@(%05ld) to %@(%05ld)",
                          self.originName, (long)self.originId, self.destinationName, (long)self.destinationId]];
    
    // Change title of back button on next screen
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Routes"
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:nil
                                                                              action:nil]];
    
    Directions *directions = [[CDTARuntimeData instance] tripDirections];
    
    tripRoutes = [[NSArray alloc] initWithArray:[directions routes]];
    
    if ([tripRoutes count] > 0) {
        [emptyLabel setHidden:YES];
        
        [self.tableView reloadData];
    } else {
        CGRect applicationFrame = [[UIScreen mainScreen] bounds];
        
        [emptyLabel setText:@"No directions found for this trip."];
        [emptyLabel setTextAlignment:NSTextAlignmentCenter];
        [emptyLabel setFont:[UIFont systemFontOfSize:16.0f]];
        [emptyLabel setNumberOfLines:0];
        [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [emptyLabel sizeToFit];
        [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                          (applicationFrame.size.height / 2) - (emptyLabel.frame.size.height/2 + HELP_SLIDER_HEIGHT))];
        [emptyLabel setHidden:NO];
        [self.view addSubview:emptyLabel];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([tripRoutes count] > 0) {
        [self.tableView setHidden:NO];
        [emptyLabel setHidden:YES];
    }else{
        [self.tableView setHidden:YES];
        [emptyLabel setHidden:NO];
    }
    // Trip Planner origin or destination had just been set from Stop Info screen, so go back to main Trip Planner screen
    if ((([[CDTARuntimeData instance] fromStopLatitude] != 0) && ([[CDTARuntimeData instance] fromStopLongitude] != 0)) ||
        (([[CDTARuntimeData instance] toStopLatitude] != 0) && ([[CDTARuntimeData instance] toStopLongitude] != 0))) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tripRoutes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TripRouteCell";
    TripRouteCell *cell = (TripRouteCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    DirectionRoute *route = [tripRoutes objectAtIndex:indexPath.row];
    
    // Transit directions don't have waypoints so there is only one leg
    DirectionLeg *leg = [[route legs] objectAtIndex:0];
    
    DirectionStep *overviewStep = [[DirectionStep alloc] init];
    [overviewStep setDistance:leg.distance];
    [overviewStep setDuration:leg.duration];
    [overviewStep setEndLocation:leg.endLocation];
    [overviewStep setStartLocation:leg.startLocation];
    
    NSMutableArray *routeIds = [[NSMutableArray alloc] init];
    NSMutableArray *routeColors = [[NSMutableArray alloc] init];
    NSMutableArray *routeTextColors = [[NSMutableArray alloc] init];
    
    for (DirectionStep *step in [leg steps]) {
        if ([step.travelMode isEqualToString:MODE_TRANSIT]) {
            if ([step.transitDetails.line.shortName length] > 0) {
                [routeIds addObject:step.transitDetails.line.shortName];
            } else {
                [routeIds addObject:@""];
            }
            
            if ([step.transitDetails.line.color length] > 0) {
                [routeColors addObject:step.transitDetails.line.color];
            } else {
                [routeColors addObject:@"#ffffff"];
            }
            
            if ([step.transitDetails.line.textColor length] > 0) {
                [routeTextColors addObject:step.transitDetails.line.textColor];
            } else {
                [routeTextColors addObject:@"#000000"];
            }
        }
    }
    
    [routeIdsForRow setObject:[routeIds copy] forKey:[NSString stringWithFormat:@"%lu", (long)indexPath.row]];
    
    NSUInteger count = [routeIds count];
    if (count > 0) {
        RouteBadge *routeBadge1 = [[RouteBadge alloc] initWithFrame:CGRectMake(0,
                                                                               (ROUTE_BADGE_RADIUS / 2) - VIEW_PADDING,
                                                                               ROUTE_BADGE_RADIUS,
                                                                               ROUTE_BADGE_RADIUS)
                                                         badgeColor:[UIColor colorWithHexString:[routeColors objectAtIndex:0]]
                                                          textColor:[UIColor colorWithHexString:[routeTextColors objectAtIndex:0]]
                                                               text:[routeIds objectAtIndex:0]];
        [cell.badgesView addSubview:routeBadge1];
        
        if (count > 1) {
            for (int i = 1; i < count; i++) {
                RouteBadge *routeBadge = [[RouteBadge alloc] initWithFrame:CGRectMake((routeBadge1.frame.size.width + VIEW_PADDING) * i,
                                                                                      routeBadge1.frame.origin.y,
                                                                                      ROUTE_BADGE_RADIUS,
                                                                                      ROUTE_BADGE_RADIUS)
                                                                badgeColor:[UIColor colorWithHexString:[routeColors objectAtIndex:i]]
                                                                 textColor:[UIColor colorWithHexString:[routeTextColors objectAtIndex:i]]
                                                                      text:[routeIds objectAtIndex:i]];
                [cell.badgesView addSubview:routeBadge];
            }
        }
    } else {
        UILabel *noTransitLabel = [[UILabel alloc] init];
        [noTransitLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [noTransitLabel setText:@"No transit steps"];
        [noTransitLabel sizeToFit];
        [noTransitLabel setFrame:CGRectMake(0,
                                            noTransitLabel.frame.size.height / 2,
                                            noTransitLabel.frame.size.width,
                                            noTransitLabel.frame.size.height)];
        
        [cell.badgesView addSubview:noTransitLabel];
    }
    
    if (([leg.departureTime.text length] == 0) || ([leg.arrivalTime.text length] == 0)) {
        [overviewStep setHtmlInstructions:[NSString stringWithFormat:@"Distance: %@ | Duration: %@",
                                           leg.distance.text,
                                           leg.duration.text]];
    } else {
        [overviewStep setHtmlInstructions:[NSString stringWithFormat:@"Depart: %@ | Arrive: %@\nDistance: %@ | Duration: %@",
                                           leg.departureTime.text,
                                           leg.arrivalTime.text,
                                           leg.distance.text,
                                           leg.duration.text]];
    }
    
    [cell.detailsLabel setText:overviewStep.htmlInstructions];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripMapViewController *mapView = [[TripMapViewController alloc] initWithNibName:@"TripMapViewController"
                                                                             bundle:[NSBundle mainBundle]];
    [mapView setDirectionRoute:[tripRoutes objectAtIndex:indexPath.row]];
    [mapView setRouteIds:[routeIdsForRow objectForKey:[NSString stringWithFormat:@"%lu", (long)indexPath.row]]];
    [mapView setOriginName:self.originName];
    [mapView setOriginId:(int)self.originId];
    [mapView setDestinationName:self.destinationName];
    [mapView setDestinationId:(int)self.destinationId];
    [mapView setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:mapView animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

@end
