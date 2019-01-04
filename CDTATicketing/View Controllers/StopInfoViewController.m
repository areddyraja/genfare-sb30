//
//  StopInfoViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "StopInfoViewController.h"
#import "Alert.h"
#import "Arrival.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
#import "FavoriteStop.h"
#import "GetDirectionsForRouteService.h"
#import "NearbyStop.h"
#import "Route.h"
#import "RouteBadge.h"
#import "RouteDetailsViewController.h"
#import "StopInfoRouteHeader.h"
#import "TripPlannerViewController.h"

@interface StopInfoViewController ()

@end

NSString *const STOP_INFO_TITLE = @"Stop Info";

@implementation StopInfoViewController
{
    //UIActivityIndicatorView *spinner;
    int stopId;
    NSString *stopName;
    NSString *servicedBy;
    double latitude;
    double longitude;
    NSMutableDictionary *routes;
    NSArray *sortedKeys;
    BOOL isFavorite;
    NSArray *allRoutes;
    NSNumberFormatter *numberFormatter;
    NSArray *alerts;
    Route *selectedRoute;
    UIRefreshControl *refreshControl;
    BOOL refreshing;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
               stopId:(int)stop
             stopName:(NSString *)name
           servicedBy:(NSString *)serviced
             latitude:(double)lat
            longitude:(double)lng
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        stopId = stop;
        stopName = name;
        servicedBy = serviced;
        latitude = lat;
        longitude = lng;
        
        [self setViewName:STOP_INFO_TITLE];
        [self setViewDetails:[NSString stringWithFormat:@"%@(%05d)", stopName, stopId]];
        
        [self setTitle:STOP_INFO_TITLE];
        
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        routes = [[NSMutableDictionary alloc] init];
        
        allRoutes = [[NSArray alloc] init];
        
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        alerts = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//    [spinner startAnimating];
    [self showProgressDialog];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Stop Info" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    [self.stopNameLabel setText:[CDTAUtilities formatLocationName:stopName]];
    
    GetArrivalsService *arrivalsService = [[GetArrivalsService alloc] initWithListener:self
                                                                                stopId:stopId
                                                                  managedObjectContext:self.managedObjectContext];
    [arrivalsService execute];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:FAVORITE_STOP_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *favoriteStops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    isFavorite = NO;
    
    for (FavoriteStop *favoriteStop in favoriteStops) {
        if ([favoriteStop.stopId intValue] == stopId) {
            isFavorite = YES;
            break;
        }
    }
    
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:ROUTE_MODEL
                         inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    allRoutes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    alerts = [[CDTARuntimeData instance] alerts];
    
    // Add pull to refresh
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
    
    refreshing = NO;
}


-(void)refreshTableView
{
    refreshing = YES;
    
    GetArrivalsService *arrivalsService = [[GetArrivalsService alloc] initWithListener:self
                                                                                stopId:stopId
                                                                  managedObjectContext:self.managedObjectContext];
    [arrivalsService execute];
}

-(void)endRefresh
{
    [refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //iOS6 Support
    [self.originButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    [self.destinationButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    //iOS6 Support
}

- (IBAction)planOrigin:(id)sender
{
    [[CDTARuntimeData instance] setFromStopId:stopId];
    [[CDTARuntimeData instance] setFromStopName:stopName];
    [[CDTARuntimeData instance] setFromStopLatitude:latitude];
    [[CDTARuntimeData instance] setFromStopLongitude:longitude];
    
    [self goToTrip];
}

- (IBAction)planDestination:(id)sender
{
    [[CDTARuntimeData instance] setToStopId:stopId];
    [[CDTARuntimeData instance] setToStopName:stopName];
    [[CDTARuntimeData instance] setToStopLatitude:latitude];
    [[CDTARuntimeData instance] setToStopLongitude:longitude];
    
    [self goToTrip];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetArrivalsService class]]) {
        [self setTableData];
        
        // Pull to refresh
        if (refreshing) {
            refreshing = NO;
            
            [self endRefresh];
        }
        
        [self setFavoriteButton];
    } else if ([service isMemberOfClass:[GetDirectionsForRouteService class]]) {
        RouteDetailsViewController *routeDetailsView = [[RouteDetailsViewController alloc]
                                                        initWithNibName:@"RouteDetailsViewController"
                                                        bundle:[NSBundle mainBundle]];
        [routeDetailsView setManagedObjectContext:self.managedObjectContext];
        [routeDetailsView setRoute:selectedRoute];
        
        [self.navigationController pushViewController:routeDetailsView animated:YES];
    }
    
//    [spinner stopAnimating];
    [self dismissProgressDialog];

}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    if ([service isMemberOfClass:[GetArrivalsService class]]) {
        [self setTableData];
        
        //Pull to refresh stuff
        if (refreshing) {
            refreshing = NO;
            [self endRefresh];
        }
        
        [self setFavoriteButton];
    } else if ([service isMemberOfClass:[GetDirectionsForRouteService class]]) {
        
    }
    
//    [spinner stopAnimating];
    [self dismissProgressDialog];

}

- (void)setTableData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ARRIVAL_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopId == %d", stopId];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"routeId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error;
    NSArray *allArrivals = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *headers = [[NSMutableArray alloc] init];
    
    // Get all headers (comprised of route ID and route name)
    for (Arrival *arrival in allArrivals) {
        NSString *header = [NSString stringWithFormat:@"%03d^^%@::%@",
                            [arrival.routeId intValue],
                            arrival.routeName,
                            arrival.direction];
        [headers addObject:header];
    }
    
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:headers];
    NSSet *uniqueHeaders = [orderedSet set];
    
    // Create arrays of arrivals for each unique header
    for (NSString *uniqueHeader in uniqueHeaders) {
        NSMutableArray *arrivalsInRoute = [[NSMutableArray alloc] init];
        
        for (Arrival *arrival in allArrivals) {
            // Pad routeId with zeros for correct sorting results
            NSString *header = [NSString stringWithFormat:@"%03d^^%@::%@",
                                [arrival.routeId intValue],
                                arrival.routeName,
                                arrival.direction];
            if ([header isEqualToString:uniqueHeader]) {
                [arrivalsInRoute addObject:arrival];
            }
        }
        
        [routes setObject:[arrivalsInRoute copy] forKey:uniqueHeader];
    }
    
    NSArray *keys = [routes allKeys];
    sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *header1 = (NSString *)obj1;
        NSString *header2 = (NSString *)obj2;
        
        return [header1 compare:header2];
    }];
    
    [self.tableView reloadData];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sortedKeys count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    StopInfoRouteHeader *routeHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"StopInfoRouteHeader" owner:self options:nil] objectAtIndex:0];
    [routeHeaderView setTag:section];
    
    NSString *header = [sortedKeys objectAtIndex:section];
    NSArray *components = [header componentsSeparatedByString:@"^^"];
    int routeId = [[numberFormatter numberFromString:[components objectAtIndex:0]] intValue];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.routeId == %d", routeId];
    
    NSArray *filteredRoutes = [allRoutes filteredArrayUsingPredicate:resultPredicate];
    
    NSInteger filteredCount = [filteredRoutes count];
    if (filteredCount > 0) {
        Route *route = [filteredRoutes objectAtIndex:0];
        
        RouteBadge *routeBadge = [[RouteBadge alloc] initWithFrame:CGRectMake(routeHeaderView.routeBadge.frame.origin.x,routeHeaderView.routeBadge.frame.origin.y,ROUTE_BADGE_RADIUS,ROUTE_BADGE_RADIUS)badgeColor:[UIColor colorWithHexString:route.color]textColor:[UIColor colorWithHexString:route.textColor]text:[NSString stringWithFormat:@"%@", route.routeId]];
        
        [routeHeaderView.routeBadge setImage:routeBadge.image];
    }
    
    NSArray *titleComponents = [[components objectAtIndex:1] componentsSeparatedByString:@"::"];
    NSString *title = [NSString stringWithFormat:@"%@ Arrivals (%@)", [titleComponents objectAtIndex:0],
                       [titleComponents objectAtIndex:1]];
    
    while ([title rangeOfString:@"  "].location != NSNotFound) {
        title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    [routeHeaderView.titleLabel setText:title];
    
    for (Alert *alert in alerts) {
        if ([alert containsRouteId:routeId]) {
            [routeHeaderView.titleLabel setTextColor:[UIColor redColor]];
            
            break;
        } else {
            [routeHeaderView.titleLabel setTextColor:[UIColor darkTextColor]];
        }
    }
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(handleHeaderTap:)];
    [tapRecognizer setDelegate:self];
    
    [routeHeaderView addGestureRecognizer:tapRecognizer];
    
    return routeHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    StopInfoRouteHeader *routeHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"StopInfoRouteHeader" owner:self options:nil] objectAtIndex:0];
    
    NSString *header = [sortedKeys objectAtIndex:section];
    NSArray *components = [header componentsSeparatedByString:@"^^"];
    
    NSArray *titleComponents = [[components objectAtIndex:1] componentsSeparatedByString:@"::"];
    NSString *title = [NSString stringWithFormat:@"%@ Arrivals (%@)", [titleComponents objectAtIndex:0],
                       [titleComponents objectAtIndex:1]];
    
    while ([title rangeOfString:@"  "].location != NSNotFound) {
        title = [title stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    
    CGRect rect;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        rect = [title boundingRectWithSize:CGSizeMake(routeHeaderView.titleLabel.frame.size.width, CGFLOAT_MAX)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:routeHeaderView.titleLabel.font}
                                   context:nil];
    } else {
        CGSize size = [title sizeWithFont:routeHeaderView.titleLabel.font
                        constrainedToSize:CGSizeMake(routeHeaderView.titleLabel.frame.size.width,
                                                     routeHeaderView.titleLabel.frame.size.height)];
        rect.size = size;
    }
    
    return (routeHeaderView.titleLabel.frame.origin.y * 2) + rect.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arrivals = [routes objectForKey:[sortedKeys objectAtIndex:section]];
    
    return [arrivals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StopInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSArray *arrivals = [routes objectForKey:[sortedKeys objectAtIndex:indexPath.section]];
    
    Arrival *arrival = [arrivals objectAtIndex:indexPath.row];
    
    [cell.imageView setImage:[UIImage imageNamed:@"ic_real_time"]];
    if ([arrival.type isEqualToString:REAL_TIME_ARRIVAL]) {
        [cell.imageView setHidden:NO];
    } else {
        [cell.imageView setHidden:YES];
    }
    
    // Arrival time
    
    NSRange lastColon = [arrival.time rangeOfString:@":" options:NSBackwardsSearch];
    NSString *time = [arrival.time substringWithRange:NSMakeRange(0, lastColon.location)];
    
    NSArray *timeComponents = [time componentsSeparatedByString:@":"];
    
    int hour = [[timeComponents objectAtIndex:0] intValue];
    int displayedHour = (hour >= 12) ? hour - 12 : hour;
    
    if (displayedHour == 0) {
        displayedHour = 12;
    }
    
    NSString *amPmString = (hour >= 12) ? @"PM" : @"AM";
    
    // ETA
    
    lastColon = [arrival.minutes rangeOfString:@":" options:NSBackwardsSearch];
    NSString *eta = [arrival.minutes substringWithRange:NSMakeRange(0, lastColon.location)];
    
    NSArray *etaComponents = [eta componentsSeparatedByString:@":"];
    int etaHours = [[etaComponents objectAtIndex:0] intValue];
    int etaMinutes = [[etaComponents objectAtIndex:1] intValue];;
    
    NSString *etaString = @"";
    if (etaHours == 0) {
        if (etaMinutes > 0) {
            etaString = [NSString stringWithFormat:@"%d min", etaMinutes];
        } else {
            etaString = @"now";
        }
    } else if (etaHours == 1) {
        if (etaMinutes > 0) {
            etaString = [NSString stringWithFormat:@"%d hr %d min", etaHours, etaMinutes];
        } else {
            etaString = [NSString stringWithFormat:@"%d hr", etaHours];
        }
    } else {
        if (etaMinutes > 0) {
            etaString = [NSString stringWithFormat:@"%d hrs %d min", etaHours, etaMinutes];
        } else {
            etaString = [NSString stringWithFormat:@"%d hrs", etaHours];
        }
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%d:%@ %@ (%@)", displayedHour, [timeComponents objectAtIndex:1], amPmString, etaString]];
    
    return cell;
}

#pragma mark - Other methods

- (void)onFavoritePressed
{
    if (isFavorite) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:FAVORITE_STOP_MODEL
                                            inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setIncludesPropertyValues:NO];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stopId == %d", stopId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *stops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (FavoriteStop *favoriteStop in stops) {
            [self.managedObjectContext deleteObject:favoriteStop];
        }
        
        NSError *saveError = nil;
        [self.managedObjectContext save:&saveError];
        
        isFavorite = NO;
    } else {
        FavoriteStop *favoriteStop = (FavoriteStop *)[NSEntityDescription insertNewObjectForEntityForName:FAVORITE_STOP_MODEL
                                                                                   inManagedObjectContext:self.managedObjectContext];
        [favoriteStop setName:stopName];
        [favoriteStop setStopId:[NSNumber numberWithInt:stopId]];
        [favoriteStop setServicedBy:servicedBy];
        [favoriteStop setLatitude:[NSNumber numberWithDouble:latitude]];
        [favoriteStop setLongitude:[NSNumber numberWithDouble:longitude]];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        }
        
        isFavorite = YES;
    }
    
    [self setFavoriteButton];
}

- (void)setFavoriteButton
{
    NSString *barButtonTitle = (isFavorite) ? @"-Favorite" : @"+Favorite";
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:barButtonTitle
                                                                                style:UIBarButtonItemStyleBordered
                                                                               target:self
                                                                               action:@selector(onFavoritePressed)]];
}

- (void)handleHeaderTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSString *header = [sortedKeys objectAtIndex:gestureRecognizer.view.tag];
    NSArray *components = [header componentsSeparatedByString:@"^^"];
    int routeId = [[numberFormatter numberFromString:[components objectAtIndex:0]] intValue];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ROUTE_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"routeId == %d", routeId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *savedRoutes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([savedRoutes count] > 0) {
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//        [spinner startAnimating];
        [self showProgressDialog];
        
        GetDirectionsForRouteService *directionsService = [[GetDirectionsForRouteService alloc] initWithListener:self
                                                                                                         routeId:routeId
                                                                                            managedObjectContext:self.managedObjectContext];
        [directionsService execute];
        
        selectedRoute = [savedRoutes objectAtIndex:0];
    }
}

- (void)goToTrip
{
    TripPlannerViewController *tripPlannerView = [[TripPlannerViewController alloc] initWithNibName:@"TripPlannerViewController" bundle:[NSBundle mainBundle]];
    [tripPlannerView setManagedObjectContext:self.managedObjectContext];
    
    [self.navigationController pushViewController:tripPlannerView animated:YES];
}

@end
