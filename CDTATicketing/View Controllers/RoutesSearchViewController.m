//
//  RoutesSearchViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RoutesSearchViewController.h"
#import "Alert.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
#import "FavoriteStop.h"
#import "GeocodingService.h"
//#import "LogoBarButtonItem.h"
#import "Route.h"
#import "RouteBadge.h"
#import "SearchedAddress.h"
#import "SearchedRoute.h"
#import "SearchedStop.h"
#import "Stop.h"

@interface RoutesSearchViewController ()

@end

@implementation RoutesSearchViewController
{
    //LogoBarButtonItem *logoBarButton;
    BOOL searchingAddress;
    NSArray *searchedAddresses;
    NSArray *favoriteStops;
    NSArray *routes;
    NSMutableArray *filteredRoutes;
    NSArray *alerts;
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
        [self setTitle:@"Search Stops"];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        
        searchingAddress = YES;
        
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
    
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
    
    // Change title of back button on next screen
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:nil
                                                                              action:nil]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:FAVORITE_STOP_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    favoriteStops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    entity = [NSEntityDescription entityForName:ROUTE_MODEL
                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    routes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    filteredRoutes = [NSMutableArray arrayWithCapacity:[routes count]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    alerts = [[CDTARuntimeData instance] alerts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GeocodingService class]]) {
        searchedAddresses = [[CDTARuntimeData instance] searchedAddresses];
        
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        isServiceRunning = NO;
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
    if ([service isMemberOfClass:[GeocodingService class]]) {
        isServiceRunning = NO;
    } else if ([service isMemberOfClass:[SearchStopsService class]]) {
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        isServiceRunning = NO;
    }
    [self dismissProgressDialog];

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
    NSString *title = @"Search By Route";
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (searchingAddress) {
            title = @"Search By Address";
        } else {
            title = @"Search By Stop Name";
        }
    } else {
        switch (section) {
            case 0:
                title = @"Favorite Stops";
                break;
                
            default:
                title = @"Search By Route";
                break;
        }
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (searchedAddresses) {
            if ([searchedAddresses count] > 0) {
                count = [searchedAddresses count];
            } else {
                count = 1;
            }
        } else {
            if ([filteredStops count] > 0) {
                count = [filteredStops count];
            } else {
                count = 1;
            }
        }
    } else {
        switch (section) {
            case 0:
                count = ([favoriteStops count] > 0) ? [favoriteStops count] : 1;
                break;
                
            case 1:
                count = [routes count];
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
        }
        
        if (searchingAddress) {
            if ([searchedAddresses count] > 0) {
                SearchedAddress *searchedAddress = [searchedAddresses objectAtIndex:indexPath.row];
                
                [cell.textLabel setText:searchedAddress.address];
                [cell.detailTextLabel setText:@""];
            } else {
                [cell.textLabel setText:@"Address not found"];
                [cell.detailTextLabel setText:@""];
            }
        } else {
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
                
                if (count > 0) {
                    [cell.textLabel setText:[NSString stringWithFormat:@"%@ Serviced by %@", stopResult.name, routesString]];
                } else if (stopResult.isLandmark) {
                    [cell.textLabel setText:[NSString stringWithFormat:@"Landmark: %@", stopResult.name]];
                } else {
                    [cell.textLabel setText:stopResult.name];
                }
            } else {
                if (searchLength >= 4) {
                    [cell.textLabel setText:@"No stops found"];
                    [cell.detailTextLabel setText:@""];
                } else {
                    [cell.textLabel setText:@"Please type at least 4 characters"];
                    [cell.detailTextLabel setText:@""];
                }
            }
        }
        
        return cell;
    } else {
        static NSString *cellIdentifier = @"RoutesSearchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        if (indexPath.section >= 1) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        if (indexPath.section == 0) {
            if ([favoriteStops count] > 0) {
                FavoriteStop *favoriteStop = [favoriteStops objectAtIndex:indexPath.row];
                
                [cell.textLabel setNumberOfLines:3];
                [cell.textLabel setText:[NSString stringWithFormat:@"%@ Serviced by %@",
                                         [CDTAUtilities formatLocationName:favoriteStop.name],
                                         favoriteStop.servicedBy]];
            } else {
                [cell.textLabel setText:@"No favorite stops saved"];
            }
        } else {
            Route *route = route = [routes objectAtIndex:indexPath.row];
            
            RouteBadge *routeBadge = [[RouteBadge alloc] initWithFrame:CGRectMake(0,
                                                                                  0,
                                                                                  ROUTE_BADGE_RADIUS,
                                                                                  ROUTE_BADGE_RADIUS)
                                                            badgeColor:[UIColor colorWithHexString:route.color]
                                                             textColor:[UIColor colorWithHexString:route.textColor]
                                                                  text:[NSString stringWithFormat:@"%@", route.routeId]];
            
            [cell.imageView setImage:[routeBadge image]];
            
            [cell.textLabel setText:[CDTAUtilities formatLocationName:route.name]];
            
            for (Alert *alert in alerts) {
                if ([[alert routeType] isEqualToString:ALERT_ALL_ROUTES]
                    || ([[alert routeType] isEqualToString:ALERT_NX_ROUTE] && [route.routeId intValue] == NX_ROUTE_ID)
                    || [alert containsRouteId:[route.routeId intValue]]) {
                    [cell.detailTextLabel setText:@"Alert"];
                    [cell.detailTextLabel setTextColor:[UIColor redColor]];
                    [cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:ALERT_TEXT_SIZE]];
                    
                    break;
                } else {
                    [cell.detailTextLabel setText:@""];
                }
            }
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (searchedAddresses) {
            if ([searchedAddresses count] > 0) {
                SearchedAddress *searchedAddress = [searchedAddresses objectAtIndex:indexPath.row];
                
                [self.listener onSearchedStopSelected:0
                                                 name:searchedAddress.address
                                             arriving:self.arriving
                                             latitude:searchedAddress.latitude
                                            longitude:searchedAddress.longitude];
            }
        } else {
            if ([filteredStops count] > 0) {
                SearchedStop *stopResult = [filteredStops objectAtIndex:indexPath.row];
                
                double latitude = 0;
                double longitude = 0;
                
                if (stopResult.isLandmark) {
                    latitude = stopResult.latitude;
                    longitude = stopResult.longitude;
                }
                
                [self.listener onSearchedStopSelected:stopResult.stopId
                                                 name:stopResult.name
                                             arriving:self.arriving
                                             latitude:stopResult.latitude
                                            longitude:stopResult.longitude];
            }
        }
    } else {
        if ((indexPath.section == 0) && ([favoriteStops count] > 0)) {
            FavoriteStop *stop = [favoriteStops objectAtIndex:indexPath.row];
            
            [self.listener onSearchedStopSelected:[stop.stopId intValue]
                                             name:stop.name
                                         arriving:self.arriving
                                         latitude:[stop.latitude doubleValue]
                                        longitude:[stop.longitude doubleValue]];
        } else if (indexPath.section == 1) {
            Route *route = [routes objectAtIndex:indexPath.row];
            
            StopsSearchViewController *stopsSearchView =
            [[StopsSearchViewController alloc] initWithNibName:@"StopsSearchViewController"
                                                        bundle:[NSBundle mainBundle]];
            [stopsSearchView setListener:self];
            [stopsSearchView setManagedObjectContext:self.managedObjectContext];
            [stopsSearchView setRouteId:[route.routeId intValue]];
            [stopsSearchView setArriving:self.arriving];
            
            [self.navigationController pushViewController:stopsSearchView animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([filteredStops count] > 0) {
            return SEARCHED_CELL_HEIGHT;
        }
    } else if ((indexPath.section == 0) && ([favoriteStops count] > 0)) {
        return SEARCHED_CELL_HEIGHT;
    }
    
    return CELL_HEIGHT_DEFAULT;
}

#pragma mark - Search Bar methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchBar setPlaceholder:@"Street address and City in NY"];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    //save query string on search type change
    //[searchBar setText:@""];
    
    
    if (selectedScope == 0) {
        [searchBar setPlaceholder:@"Street address and City in NY"];
        
        searchingAddress = YES;
        
        //remove stop search results
        [filteredStops removeAllObjects];
    } else {
        [searchBar setPlaceholder:@"Stop Name or Landmark"];
        
        searchingAddress = NO;
        
        [filteredStops removeAllObjects];
        
        if (!isServiceRunning && searchBar.text.length >= 4){
            isServiceRunning = YES;
           
            //take first 4 letters and do search on them. Will ignore spaces, commas, etc
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9]{4}" options:NSRegularExpressionCaseInsensitive error:NULL];
            NSTextCheckingResult *newSearchString = [regex firstMatchInString:searchBar.text options:0 range:NSMakeRange(0, [searchBar.text length])];
            NSString *substr = [searchBar.text substringWithRange:newSearchString.range];
            NSLog(@"%@", substr);
            
           
            [searchStopsService setSearchTerm:substr];
            [searchStopsService execute];
            
            previousSearchLength = searchLength;
        }
    }

    [self.tableView reloadData];

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchingAddress) {
        NSRange range = [searchBar.text rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *trimmedQuery = [searchBar.text stringByReplacingCharactersInRange:range withString:@""];
        
        if (!isServiceRunning) {
            isServiceRunning = YES;
            
            GeocodingService *geocodingService = [[GeocodingService alloc] initWithListener:self address:trimmedQuery];
            [geocodingService execute];
        }
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchBar setPlaceholder:@"Address / Stop Name / Landmark"];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSRange range = [searchString rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    NSString *trimmedQuery = [searchString stringByReplacingCharactersInRange:range withString:@""];
    
    if (!searchingAddress) {
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
    }
    
    return NO;
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    [filteredStops removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains [cd] %@", searchText];
    
    filteredStops = [NSMutableArray arrayWithArray:[allStops filteredArrayUsingPredicate:resultPredicate]];
}

#pragma mark - OnStopSelectedListener callback

- (void)onStopSelected:(Stop *)stop arriving:(BOOL)arriving
{
    [self.listener onSearchedStopSelected:[stop.stopId intValue]
                                     name:stop.name
                                 arriving:arriving
                                 latitude:[stop.latitude doubleValue]
                                longitude:[stop.longitude doubleValue]];
}

@end
