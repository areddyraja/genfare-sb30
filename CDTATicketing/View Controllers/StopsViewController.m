//
//  StopsViewController.m
//  CDTA
//
//  Created by CooCooTech on 11/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "StopsViewController.h"
#import "Alert.h"
#import "Arrival.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
#import "FavoriteStop.h"
#import "GetArrivalsService.h"
#import "GetNearbyStopsService.h"
#import "NearbyStop.h"
#import "NearbyStopCell.h"
#import "LandmarkInfoViewController.h"
//#import "LogoBarButtonItem.h"
#import "Route.h"
#import "RouteBadge.h"
#import "SearchedRoute.h"
#import "SearchedStop.h"
#import "SearchStopsService.h"
#import "ServiceRoute.h"
#import "Stop.h"
#import "StopInfoViewController.h"
#import "RouteDetailsViewController.h"
#import "LocationHelper.h"

@interface StopsViewController ()

@end

//NSString *const STOPS_TITLE = @"Stops";
NSString *const STOPS_TITLE = @"Real Time Arrivals";

@implementation StopsViewController
{
    //LogoBarButtonItem *logoBarButton;
//    UIActivityIndicatorView *spinner;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSArray *favoriteStops;
    NSArray *nearbyStops;
    NSArray *routes;
    NSMutableArray *expandedFavoriteCells;
    NSMutableArray *expandedNearbyCells;
    NSArray *alerts;
    NSMutableDictionary *arrivalsDictionary;
    int currentArrivalsStopId;
    Route *selectedRoute;
    SearchStopsService *searchStopsService;
    BOOL isServiceRunning;
    NSArray *allStops;
    NSMutableArray *filteredStops;
    NSInteger searchLength;
    NSInteger previousSearchLength;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:STOPS_TITLE];
        [self setTitle:STOPS_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        locationManager = [[CLLocationManager alloc] init];
        currentLocation = [[CLLocation alloc] init];
        
        nearbyStops = [[NSArray alloc] init];
        routes = [[NSArray alloc] init];
        expandedFavoriteCells = [[NSMutableArray alloc] init];
        expandedNearbyCells = [[NSMutableArray alloc] init];
        
        alerts = [[NSArray alloc] init];
        
        arrivalsDictionary = [[NSMutableDictionary alloc] init];
        
        searchStopsService = [[SearchStopsService alloc] initWithListener:self];
        
        allStops = [[NSArray alloc] init];
        filteredStops = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Stops" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ROUTE_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    routes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([LocationHelper requestWhenInUseAuthorisation:locationManager]){
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//        [spinner startAnimating];
        [self showProgressDialog];
        [locationManager setDelegate:self];
        [locationManager startUpdatingLocation];
    } else {
        //let the user turn location service back on:
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"locationServiceDisabledTitle"]
                                                           message:[Utilities stringResourceForId:@"locationServiceDisabledMessage"]
                                                          delegate:self
                                                 cancelButtonTitle:[Utilities stringResourceForId:@"cancel"]
                                                 otherButtonTitles:[Utilities stringResourceForId:@"ok"],nil];
        [theAlert show];
    }
    
    favoriteStops = [[NSArray alloc] init];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:FAVORITE_STOP_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    favoriteStops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [expandedFavoriteCells removeAllObjects];
    for (int i = 0; i < favoriteStops.count; i++) {
        [expandedFavoriteCells addObject:[NSNumber numberWithBool:NO]];
    }
    
    alerts = [[CDTARuntimeData instance] alerts];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetNearbyStopsService class]]) {
        nearbyStops = [[CDTARuntimeData instance] nearbyStops];
        
        [expandedNearbyCells removeAllObjects];
        for (int i = 0; i < nearbyStops.count; i++) {
            [expandedNearbyCells addObject:[NSNumber numberWithBool:NO]];
        }
        
        [self.tableView reloadData];
        
//        [spinner stopAnimating];
        //[self.navigationItem setRightBarButtonItem:logoBarButton];
    } else if ([service isMemberOfClass:[GetArrivalsService class]]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:ARRIVAL_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopId == %d", currentArrivalsStopId];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"routeId" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error;
        NSArray *arrivals = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        [arrivalsDictionary setObject:arrivals forKey:[NSNumber numberWithInt:currentArrivalsStopId]];
        
        [self.tableView reloadData];
        
        currentArrivalsStopId = 0;
        
//        [spinner stopAnimating];
        //[self.navigationItem setRightBarButtonItem:logoBarButton];
    } else if ([service isMemberOfClass:[SearchStopsService class]]) {
        allStops = [[CDTARuntimeData instance] searchedStops];
        filteredStops = [NSMutableArray arrayWithArray:[allStops copy]];
        
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        isServiceRunning = NO;
    }
    
    [self dismissProgressDialog];

}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    if ([service isMemberOfClass:[GetNearbyStopsService class]]) {
//        [spinner stopAnimating];
        //[self.navigationItem setRightBarButtonItem:logoBarButton];
    } else if ([service isMemberOfClass:[GetArrivalsService class]]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:ARRIVAL_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopId == %d", currentArrivalsStopId];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"routeId" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        NSError *error;
        NSArray *arrivals = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        [arrivalsDictionary setObject:arrivals forKey:[NSNumber numberWithInt:currentArrivalsStopId]];
        
        [self.tableView reloadData];
        
        currentArrivalsStopId = 0;
        
//        [spinner stopAnimating];
        //[self.navigationItem setRightBarButtonItem:logoBarButton];
    } else if ([service isMemberOfClass:[SearchStopsService class]]) {
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        isServiceRunning = NO;
    }
    [self dismissProgressDialog];

}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
    
    [locationManager stopUpdatingLocation];
    
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//    [spinner startAnimating];
    [self showProgressDialog];
    
    GetNearbyStopsService *nearbyStopsService = [[GetNearbyStopsService alloc] initWithListener:self
                                                                                       latitude:currentLocation.coordinate.latitude
                                                                                      longitude:currentLocation.coordinate.longitude
                                                                                          count:10];
    [nearbyStopsService execute];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Stops";
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        title = @"Search By Stop Name";
    } else {
        switch (section) {
            case 0:
                title = @"Favorite Stops";
                break;
                
            case 1:
                title = @"Nearby Stops";
                break;
                
            default:
                break;
        }
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([filteredStops count] > 0) {
            count = [filteredStops count];
        } else {
            count = 1;
        }
    } else {
        switch (section) {
            case 0:
                count = ([favoriteStops count] > 0) ? [favoriteStops count] : 1;
                break;
                
            case 1:
                count = ([nearbyStops count] > 0) ? [nearbyStops count] : 1;
                break;
                
            default:
                count = 0;
                break;
        }
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        static NSString *cellIdentifier = @"StopsSearchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            
            [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_TEXT_SIZE_SMALL]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        if ([filteredStops count] > 0) {
            SearchedStop *stopResult = [filteredStops objectAtIndex:indexPath.row];
            NSArray *serviceRoutes = stopResult.servicedBy;
            
            NSMutableString *routesString = [[NSMutableString alloc] init];
            
            NSInteger count = [serviceRoutes count];
            if (count > 0) {
                SearchedRoute *searchedRoute = [serviceRoutes objectAtIndex:0];
                
                NSString *direction = searchedRoute.direction;
                if ([direction isEqual:[NSNull null]]) {
                    [routesString appendString:[NSString stringWithFormat:@"%d", searchedRoute.routeId]];
                } else {
                    [routesString appendString:[NSString stringWithFormat:@"%d (%@)",
                                                searchedRoute.routeId,
                                                searchedRoute.direction]];
                }
                
                BOOL hasAlert = NO;
                for (Alert *alert in alerts) {
                    if ([alert containsRouteId:searchedRoute.routeId]) {
                        [cell.detailTextLabel setText:@"Alert"];
                        [cell.detailTextLabel setTextColor:[UIColor redColor]];
                        [cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:ALERT_TEXT_SIZE]];
                        
                        hasAlert = YES;
                        
                        break;
                    } else {
                        [cell.detailTextLabel setText:@""];
                    }
                }
                
                for (int i = 1; i < count; i++) {
                    SearchedRoute *searchedRoute = [serviceRoutes objectAtIndex:i];
                    
                    NSString *direction = searchedRoute.direction;
                    if ([direction isEqual:[NSNull null]]) {
                        [routesString appendString:[NSString stringWithFormat:@", %d", searchedRoute.routeId]];
                    } else {
                        [routesString appendString:[NSString stringWithFormat:@", %d (%@)",
                                                    searchedRoute.routeId,
                                                    searchedRoute.direction]];
                    }
                    
                    if (!hasAlert) {
                        for (Alert *alert in alerts) {
                            if ([alert containsRouteId:searchedRoute.routeId]) {
                                [cell.detailTextLabel setText:@"Alert"];
                                [cell.detailTextLabel setTextColor:[UIColor redColor]];
                                [cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:ALERT_TEXT_SIZE]];
                                
                                break;
                            } else {
                                [cell.detailTextLabel setText:@""];
                            }
                        }
                    }
                }
            }
            
            [cell.textLabel setNumberOfLines:4];
            
            NSString *servicedByString = @"";
            
            if (count > 0 && [routesString length] > 0) {
                servicedByString = [NSString stringWithFormat:@" Serviced by %@", routesString];
            }
            
            if (stopResult.isLandmark) {
                [cell.textLabel setText:[NSString stringWithFormat:@"Landmark: %@%@", stopResult.name, servicedByString]];
            } else {
                [cell.textLabel setText:[NSString stringWithFormat:@"%@%@", stopResult.name, servicedByString]];
            }
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            if (searchLength >= 4) {
                [cell.textLabel setText:@"No stops found"];
                [cell.detailTextLabel setText:@""];
            } else {
                [cell.textLabel setText:@"Please type at least 4 characters"];
                [cell.detailTextLabel setText:@""];
            }
        }
        
        return cell;
    } else {
        static NSString *cellIdentifier = @"NearbyStopCell";
        NearbyStopCell *cell = (NearbyStopCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        NSArray *currentArray = (indexPath.section == 0) ? favoriteStops : nearbyStops;
        
        if ([currentArray count] == 0) {
            if (indexPath.section == 0) {
                [cell.stopName setText:@"No favorite stops saved"];
            } else {
                [cell.stopName setText:@"No nearby stops found"];
            }
            
            [cell.showArrivalsLabel setHidden:YES];
        } else {
            int stopId = 0;
            
            NSMutableString *routesString = [[NSMutableString alloc] init];
            
            if (indexPath.section == 0) {
                Stop *favoriteStop = [currentArray objectAtIndex:indexPath.row];
                stopId = [favoriteStop.stopId intValue];
                
                if ([favoriteStop.servicedBy length] > 0) {
                    [cell.stopName setText:[NSString stringWithFormat:@"%@ Serviced by %@",
                                            [CDTAUtilities formatLocationName:favoriteStop.name],
                                            favoriteStop.servicedBy]];
                } else {
                    [cell.stopName setText:[CDTAUtilities formatLocationName:favoriteStop.name]];
                }
            } else {
                NearbyStop *nearbyStop = [currentArray objectAtIndex:indexPath.row];
                stopId = nearbyStop.stopId;
                
                NSArray *serviceRoutes = nearbyStop.servicedBy;
                int count = (int) [serviceRoutes count];
                for (int i = 0; i < count; i++) {
                    if (i > 0) {
                        [routesString appendString:@", "];
                    }
                    
                    ServiceRoute *serviceRoute = [serviceRoutes objectAtIndex:i];
                    
                    NSString *direction = serviceRoute.direction;
                    
                    if (![direction isEqual:[NSNull null]] && ([direction length] > 0)
                        && ![direction isEqualToString:@"null"]) {
                        [routesString appendString:[NSString stringWithFormat:@"%d (%@)", serviceRoute.routeId, direction]];
                    } else {
                        [routesString appendString:[NSString stringWithFormat:@"%d", serviceRoute.routeId]];
                    }
                }
                
                NSString *serviceByString = @"";
                
                if ([routesString length] > 0) {
                    serviceByString = [NSString stringWithFormat:@" Serviced by %@", routesString];
                }
                
                NSString *labelString = @"";
                
                if (nearbyStop.stopId == 0) {
                    labelString = [NSString stringWithFormat:@"Landmark: %@%@", nearbyStop.name, serviceByString];
                } else {
                    labelString = [NSString stringWithFormat:@"%@%@", nearbyStop.name, serviceByString];
                }
                
                [cell.stopName setText:[CDTAUtilities formatLocationName:labelString]];
            }
            
            // Resize stationName label to allow for multiple lines
           /* [cell.stopName removeFromSuperview];
            
            CGRect currentFrame = cell.stopName.frame;
            
            CGRect rect;
            
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
                rect = [cell.stopName.text boundingRectWithSize:CGSizeMake(cell.stopName.frame.size.width - 10, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:cell.stopName.font}
                                                        context:nil];
            } else {
                CGSize size = [cell.stopName.text sizeWithFont:cell.stopName.font
                                             constrainedToSize:CGSizeMake(cell.stopName.frame.size.width, cell.stopName.frame.size.height)];
                rect.size = size;
            }
            
            currentFrame.size = rect.size;
            
            cell.stopName.frame = currentFrame;
            [cell.stopName sizeToFit];
            
            [cell.contentView addSubview:cell.stopName];*/
            
            if (stopId != 0) {
                [cell.showArrivalsLabel setHidden:NO];
                [cell.showArrivalsLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]]];
                
                NSMutableArray *expandedCells = (indexPath.section == 0) ? expandedFavoriteCells : expandedNearbyCells;
                
                if (([expandedCells count] > 0) && [[expandedCells objectAtIndex:indexPath.row] boolValue]) {
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    
                    [cell.showArrivalsLabel setText:@"Hide Arrivals"];
                    
                    cell.arrivalsView = [self createArrivalsViewForStopId:stopId
                                                                  offsetX:cell.stopName.frame.origin.x
                                                                  offsetY:cell.showArrivalsLabel.frame.origin.y + cell.showArrivalsLabel.frame.size.height + (VIEW_PADDING * 2)];
                    [cell.arrivalsView setFrame:CGRectMake(0, 0, 0, 0)];
                    
                    [cell.arrivalsView setHidden:NO];
                    
                    [cell.contentView addSubview:cell.arrivalsView];
                } else {
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    
                    [cell.showArrivalsLabel setText:@"Show Next Arrivals"];
                    
                    if ([cell.subviews containsObject:cell.arrivalsView]) {
                        [cell.arrivalsView removeFromSuperview];
                    }
                }
                
                cell.showArrivalsCallback = ^() {
                    BOOL isExpanded = [[expandedCells objectAtIndex:indexPath.row] boolValue];
                    [expandedCells replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!isExpanded]];
                    
                    if (!isExpanded) {
//                        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//                        [spinner startAnimating];
                        [self showProgressDialog];
                        
                        
                        GetArrivalsService *arrivalsService = [[GetArrivalsService alloc] initWithListener:self
                                                                                                    stopId:stopId
                                                                                      managedObjectContext:self.managedObjectContext];
                        [arrivalsService setResultsCount:2];
                        [arrivalsService execute];
                        
                        currentArrivalsStopId = stopId;
                    } else {
                        [self.tableView reloadData];
                    }
                };
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                
                [cell.showArrivalsLabel setHidden:YES];
            }
            
            // NearbyStopCell overrides touchesBegan so we must replicate didSelectRowAtIndexPath functionality here
            cell.selectCellCallback = ^() {
                [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                
                if ((indexPath.section == 0) && ([favoriteStops count] > 0)) {
                    FavoriteStop *favoriteStop = [favoriteStops objectAtIndex:indexPath.row];
                    
                    StopInfoViewController *stopInfoView = [[StopInfoViewController alloc] initWithNibName:@"StopInfoViewController"
                                                                                                    bundle:[NSBundle mainBundle]
                                                                                                    stopId:[favoriteStop.stopId intValue]
                                                                                                  stopName:favoriteStop.name
                                                                                                servicedBy:favoriteStop.servicedBy
                                                                                                  latitude:[favoriteStop.latitude doubleValue]
                                                                                                 longitude:[favoriteStop.longitude doubleValue]];
                    
                    [stopInfoView setManagedObjectContext:self.managedObjectContext];
                    
                    [self.navigationController pushViewController:stopInfoView animated:YES];
                } else if ((indexPath.section == 1) && ([nearbyStops count] > 0)) {
                    NearbyStop *nearbyStop = [nearbyStops objectAtIndex:indexPath.row];
                    
                    if (nearbyStop.stopId != 0) {
                        StopInfoViewController *stopInfoView = [[StopInfoViewController alloc] initWithNibName:@"StopInfoViewController"
                                                                                                        bundle:[NSBundle mainBundle]
                                                                                                        stopId:nearbyStop.stopId
                                                                                                      stopName:nearbyStop.name
                                                                                                    servicedBy:routesString
                                                                                                      latitude:nearbyStop.latitude
                                                                                                     longitude:nearbyStop.longitude];
                        
                        [stopInfoView setManagedObjectContext:self.managedObjectContext];
                        
                        [self.navigationController pushViewController:stopInfoView animated:YES];
                    } else {
                        LandmarkInfoViewController *landmarkInfoView = [[LandmarkInfoViewController alloc] initWithNibName:@"LandmarkInfoViewController"
                                                                                                                    bundle:[NSBundle mainBundle]
                                                                                                              landmarkName:[CDTAUtilities formatLocationName:nearbyStop.name]];
                        [landmarkInfoView setLatitude:nearbyStop.latitude];
                        [landmarkInfoView setLongitude:nearbyStop.longitude];
                        [landmarkInfoView setManagedObjectContext:self.managedObjectContext];
                        
                        [self.navigationController pushViewController:landmarkInfoView animated:YES];
                    }
                }
            };
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([filteredStops count] > 0) {
            SearchedStop *stopResult = [filteredStops objectAtIndex:indexPath.row];
            
            if (stopResult.isLandmark) {
                LandmarkInfoViewController *landmarkInfoView = [[LandmarkInfoViewController alloc] initWithNibName:@"LandmarkInfoViewController"
                                                                                                            bundle:[NSBundle mainBundle]
                                                                                                      landmarkName:stopResult.name];
                [landmarkInfoView setLatitude:stopResult.latitude];
                [landmarkInfoView setLongitude:stopResult.longitude];
                [landmarkInfoView setManagedObjectContext:self.managedObjectContext];
                
                [self.navigationController pushViewController:landmarkInfoView animated:YES];
            } else {
                NSMutableString *routesString = [[NSMutableString alloc] init];
                
                NSArray *serviceRoutes = stopResult.servicedBy;
                int count = (int) [serviceRoutes count];
                for (int i = 0; i < count; i++) {
                    if (i > 0) {
                        [routesString appendString:@", "];
                    }
                    
                    ServiceRoute *serviceRoute = [serviceRoutes objectAtIndex:i];
                    
                    NSString *direction = serviceRoute.direction;
                    
                    if (![direction isEqual:[NSNull null]] && ([direction length] > 0)
                        && ![direction isEqualToString:@"null"]) {
                        [routesString appendString:[NSString stringWithFormat:@"%d (%@)", serviceRoute.routeId, direction]];
                    } else {
                        [routesString appendString:[NSString stringWithFormat:@"%d", serviceRoute.routeId]];
                    }
                }
                
                StopInfoViewController *stopInfoView = [[StopInfoViewController alloc] initWithNibName:@"StopInfoViewController"
                                                                                                bundle:[NSBundle mainBundle]
                                                                                                stopId:stopResult.stopId
                                                                                              stopName:stopResult.name
                                                                                            servicedBy:routesString
                                                                                              latitude:stopResult.latitude
                                                                                             longitude:stopResult.longitude];
                [stopInfoView setManagedObjectContext:self.managedObjectContext];
                
                [self.navigationController pushViewController:stopInfoView animated:YES];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 80.0f;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([filteredStops count] > 0) {
            rowHeight = SEARCHED_CELL_HEIGHT;
        } else {
            rowHeight = CELL_HEIGHT_DEFAULT;
        }
    } else if ((indexPath.section == 0) && ([favoriteStops count] == 0)) {
        rowHeight = CELL_HEIGHT_DEFAULT;
    } else if ((indexPath.section == 1) && ([nearbyStops count] == 0)) {
        rowHeight = CELL_HEIGHT_DEFAULT;
    } else {
        static NSString *cellIdentifier = @"NearbyStopCell";
        NearbyStopCell *cell = (NearbyStopCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        NSArray *currentArray = (indexPath.section == 0) ? favoriteStops : nearbyStops;
        
        int stopId = 0;
        
        if (indexPath.section == 0) {
            Stop *favoriteStop = [currentArray objectAtIndex:indexPath.row];
            stopId = [favoriteStop.stopId intValue];
        } else {
            NearbyStop *nearbyStop = [currentArray objectAtIndex:indexPath.row];
            stopId = nearbyStop.stopId;
        }
        
        NSMutableArray *expandedCells = (indexPath.section == 0) ? expandedFavoriteCells : expandedNearbyCells;
        
        if ([[expandedCells objectAtIndex:indexPath.row] boolValue]) {
            UIView *arrivalsView = [self createArrivalsViewForStopId:stopId
                                                             offsetX:0.0f
                                                             offsetY:0.0f];
            
            rowHeight = cell.frame.size.height + arrivalsView.frame.size.height + 16;
        } else {
            rowHeight = cell.frame.size.height;
        }
    }
    
    return rowHeight;
}

#pragma mark - Search Bar methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSRange range = [searchString rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    NSString *trimmedQuery = [searchString stringByReplacingCharactersInRange:range withString:@""];
    searchLength = [trimmedQuery length];
    
    if (searchLength != previousSearchLength) {
        if ((previousSearchLength == 3) && (searchLength == 4) && !isServiceRunning) {
            isServiceRunning = YES;
            
            [searchStopsService setSearchTerm:trimmedQuery];
            [searchStopsService execute];
            
            previousSearchLength = searchLength;
            
            return NO;
        } else if (searchLength >= 4) {
            [self filterContentForSearchText:trimmedQuery
                                       scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                              objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
            
            previousSearchLength = searchLength;
            
            return YES;
        } else if ((previousSearchLength >= 4) && (searchLength < 4)) {
            [filteredStops removeAllObjects];
            
            previousSearchLength = searchLength;
            
            return YES;
        }
        
        previousSearchLength = searchLength;
        
        return NO;
    }
    
    return NO;
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    [filteredStops removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains [cd] %@", searchText];
    
    filteredStops = [NSMutableArray arrayWithArray:[allStops filteredArrayUsingPredicate:resultPredicate]];
}

#pragma mark - Other methods

- (UIView *)createArrivalsViewForStopId:(int)stopId offsetX:(float)offsetX offsetY:(float)offsetY
{
    UIView *arrivalsView = [[UIView alloc] init];
    
    CGRect previousDateFrame = CGRectZero;
    
    NSArray *arrivalsForStop = [arrivalsDictionary objectForKey:[NSNumber numberWithInt:stopId]];
    
    NSInteger arrivalsCount = [arrivalsForStop count];
    for (int i = 0; i < arrivalsCount; i++) {
        Arrival *arrival = [arrivalsForStop objectAtIndex:i];
        Route *route = nil;
        
        if (i >= 1) {
            Arrival *previousArrival = [arrivalsForStop objectAtIndex:i - 1];
            
            if (([arrival.routeId intValue] == ([previousArrival.routeId intValue]))
                && ([arrival.direction isEqualToString:previousArrival.direction])) {
                continue;
            }
        }
        
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.routeId == %d", [arrival.routeId intValue]];
        
        NSArray *matchingRoutes = [routes filteredArrayUsingPredicate:resultPredicate];
        
        NSInteger matchCount = [matchingRoutes count];
        if (matchCount > 0) {
            route = [matchingRoutes objectAtIndex:0];
        }
        
        if (route != nil) {
            RouteBadge *routeBadge = [[RouteBadge alloc] initWithFrame:CGRectMake(0,
                                                                                  0,
                                                                                  ROUTE_BADGE_RADIUS_SMALL,
                                                                                  ROUTE_BADGE_RADIUS_SMALL)
                                                            badgeColor:[UIColor colorWithHexString:route.color]
                                                                  font:[UIFont boldSystemFontOfSize:10.0f]
                                                             textColor:[UIColor colorWithHexString:route.textColor]
                                                                  text:[NSString stringWithFormat:@"%@", route.routeId]];
            
            UIImageView *routeImageView = [[UIImageView alloc] initWithImage:routeBadge.image];
            [routeImageView setFrame:CGRectMake(offsetX,
                                                (previousDateFrame.size.width != 0.0f) ?
                                                previousDateFrame.origin.y + previousDateFrame.size.height
                                                + (VIEW_PADDING * 3) : offsetY,
                                                routeBadge.frame.size.width,
                                                routeBadge.frame.size.height)];
            
            [arrivalsView addSubview:routeImageView];
            
            NSRange lastColon = [arrival.time rangeOfString:@":" options:NSBackwardsSearch];
            NSString *time = [arrival.time substringWithRange:NSMakeRange(0, lastColon.location)];
            
            NSArray *timeComponents = [time componentsSeparatedByString:@":"];
            
            int hour = [[timeComponents objectAtIndex:0] intValue];
            int displayedHour = (hour >= 12) ? hour - 12 : hour;
            
            if (displayedHour == 0) {
                displayedHour = 12;
            }
            
            NSString *amPmString = (hour >= 12) ? @"PM" : @"AM";
            
            NSString *dateString = [NSString stringWithFormat:@"%d:%@%@", displayedHour, [timeComponents objectAtIndex:1], amPmString];
            
            NSString *nextDateString = nil;
            if (i + 1 < arrivalsCount) {
                Arrival *nextArrival = [arrivalsForStop objectAtIndex:i + 1];
                
                if (([nextArrival.routeId intValue] == [arrival.routeId intValue])
                    && ([nextArrival.direction isEqualToString:arrival.direction])) {
                    NSRange lastColon = [nextArrival.time rangeOfString:@":" options:NSBackwardsSearch];
                    NSString *time = [nextArrival.time substringWithRange:NSMakeRange(0, lastColon.location)];
                    
                    NSArray *timeComponents = [time componentsSeparatedByString:@":"];
                    
                    int hour = [[timeComponents objectAtIndex:0] intValue];
                    int displayedHour = (hour >= 12) ? hour - 12 : hour;
                    
                    if (displayedHour == 0) {
                        displayedHour = 12;
                    }
                    
                    NSString *amPmString = (hour >= 12) ? @"PM" : @"AM";
                    
                    nextDateString = [NSString stringWithFormat:@"%d:%@%@", displayedHour, [timeComponents objectAtIndex:1], amPmString];
                }
            }
            
            UILabel *dateLabel = [self createDetailLabelWithText:dateString];
            [dateLabel setTextAlignment:NSTextAlignmentRight];
            
            if (nextDateString) {
                [dateLabel setFrame:CGRectMake(self.tableView.frame.size.width - dateLabel.frame.size.width
                                               - (VIEW_PADDING * 2),
                                               routeImageView.frame.origin.y + (routeImageView.frame.size.height / 2)
                                               - (dateLabel.frame.size.height / 2) - 7,
                                               dateLabel.frame.size.width,
                                               dateLabel.frame.size.height)];
                
                UILabel *nextDateLabel = [self createDetailLabelWithText:nextDateString];
                [nextDateLabel setTextAlignment:NSTextAlignmentRight];
                [nextDateLabel setFrame:CGRectMake(self.tableView.frame.size.width - nextDateLabel.frame.size.width
                                                   - (VIEW_PADDING * 2),
                                                   dateLabel.frame.origin.y + dateLabel.frame.size.height - 1,
                                                   nextDateLabel.frame.size.width,
                                                   nextDateLabel.frame.size.height)];
                
                [arrivalsView addSubview:nextDateLabel];
                
                Arrival *nextArrival = [arrivalsForStop objectAtIndex:i + 1];
                if ([nextArrival.type isEqualToString:REAL_TIME_ARRIVAL]) {
                    UIImage *realTime = [UIImage imageNamed:@"ic_real_time"];
                    
                    UIImageView *realTimeImage = [[UIImageView alloc] initWithImage:realTime];
                    [realTimeImage setFrame:CGRectMake(nextDateLabel.frame.origin.x - (realTime.size.width / 2),
                                                       nextDateLabel.frame.origin.y - 1,
                                                       realTime.size.width / 2,
                                                       realTime.size.height / 2)];
                    
                    [arrivalsView addSubview:realTimeImage];
                }
                
                previousDateFrame = CGRectMake(dateLabel.frame.origin.x,
                                               dateLabel.frame.origin.y,
                                               dateLabel.frame.size.width,
                                               dateLabel.frame.size.height + nextDateLabel.frame.size.height);
            } else {
                [dateLabel setFrame:CGRectMake(self.tableView.frame.size.width - dateLabel.frame.size.width
                                               - (VIEW_PADDING * 2),
                                               routeImageView.frame.origin.y + (routeImageView.frame.size.height / 2)
                                               - (dateLabel.frame.size.height / 2),
                                               dateLabel.frame.size.width,
                                               dateLabel.frame.size.height)];
                
                previousDateFrame = dateLabel.frame;
            }
            
            if ([arrival.type isEqualToString:REAL_TIME_ARRIVAL]) {
                UIImage *realTime = [UIImage imageNamed:@"ic_real_time"];
                
                UIImageView *realTimeImage = [[UIImageView alloc] initWithImage:realTime];
                [realTimeImage setFrame:CGRectMake(dateLabel.frame.origin.x - (realTime.size.width / 2),
                                                   dateLabel.frame.origin.y - 1,
                                                   realTime.size.width / 2,
                                                   realTime.size.height / 2)];
                
                [arrivalsView addSubview:realTimeImage];
            }
            
            [arrivalsView addSubview:dateLabel];
            
            UILabel *arrivalLabel = [self createDetailLabelWithText:[NSString stringWithFormat:@"%@\n(%@)",
                                                                     route.name,
                                                                     arrival.direction]];
            [arrivalLabel setFrame:CGRectMake(routeImageView.frame.origin.x + routeImageView.frame.size.width
                                              + VIEW_PADDING,
                                              routeImageView.frame.origin.y + (routeImageView.frame.size.height / 2)
                                              - (arrivalLabel.frame.size.height / 2),
                                              self.tableView.frame.size.width - offsetX - routeImageView.frame.size.width
                                              - dateLabel.frame.size.width - (VIEW_PADDING * 7),
                                              arrivalLabel.frame.size.height)];
            
            for (Alert *alert in alerts) {
                if ([alert containsRouteId:[route.routeId intValue]]) {
                    [arrivalLabel setTextColor:[UIColor redColor]];
                    
                    break;
                } else {
                    [arrivalLabel setTextColor:[UIColor darkTextColor]];
                }
            }
            
            [arrivalsView addSubview:arrivalLabel];
        }
    }
    
    [arrivalsView setFrame:CGRectMake(0,
                                      0,
                                      self.tableView.frame.size.width,
                                      previousDateFrame.origin.y + previousDateFrame.size.height)];
    
    return arrivalsView;
}

- (UILabel *)createDetailLabelWithText:(NSString *)text
{
    UILabel *detailLabel = [[UILabel alloc] init];
    [detailLabel setText:text];
    [detailLabel setFont:[UIFont systemFontOfSize:12]];
    [detailLabel setNumberOfLines:0];
    [detailLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [detailLabel sizeToFit];
    
    return detailLabel;
}

#pragma mark Location Alert View
- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
