//
//  LandmarkInfoViewController.m
//  CDTA
//
//  Created by CooCooTech on 12/23/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "LandmarkInfoViewController.h"
#import "CooCooBase.h"
#import "Alert.h"
#import "Arrival.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
#import "GetArrivalsService.h"
//#import "LogoBarButtonItem.h"
#import "NearbyStop.h"
#import "NearbyStopCell.h"
#import "Route.h"
#import "RouteBadge.h"
#import "ServiceRoute.h"
#import "StopInfoViewController.h"
#import "TripPlannerViewController.h"

@interface LandmarkInfoViewController ()

@end

NSString *const LANDMARK_INFO_TITLE = @"Landmark Info";

@implementation LandmarkInfoViewController
{
    NSString *landmarkName;
    //LogoBarButtonItem *logoBarButton;
   // UIActivityIndicatorView *spinner;
    NSArray *nearbyStops;
    NSArray *routes;
    NSMutableArray *expandedNearbyCells;
    NSArray *alerts;
    NSMutableDictionary *arrivalsDictionary;
    int currentArrivalsStopId;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil landmarkName:(NSString *)name;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        landmarkName = name;
        
        [self setViewName:LANDMARK_INFO_TITLE];
        [self setViewDetails:name];
        
        [self setTitle:LANDMARK_INFO_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
      //  spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        nearbyStops = [[NSArray alloc] init];
        routes = [[NSArray alloc] init];
        expandedNearbyCells = [[NSMutableArray alloc] init];
        
        alerts = [[NSArray alloc] init];
        
        arrivalsDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Landmark Info" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//    [spinner startAnimating];
    [self showProgressDialog];
    
    [self.landmarkNameLabel setText:landmarkName];
    
    GetNearbyStopsService *nearbyStopsService = [[GetNearbyStopsService alloc] initWithListener:self
                                                                                       latitude:self.latitude
                                                                                      longitude:self.longitude
                                                                                          count:10];
    [nearbyStopsService execute];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ROUTE_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    routes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    alerts = [[CDTARuntimeData instance] alerts];
    
    [self.tableView reloadData];
}

- (IBAction)planOrigin:(id)sender
{
    [[CDTARuntimeData instance] setFromStopId:0];
    [[CDTARuntimeData instance] setFromStopName:landmarkName];
    [[CDTARuntimeData instance] setFromStopLatitude:self.latitude];
    [[CDTARuntimeData instance] setFromStopLongitude:self.longitude];
    
    [self goToTrip];
}

- (IBAction)planDestination:(id)sender
{
    [[CDTARuntimeData instance] setToStopId:0];
    [[CDTARuntimeData instance] setToStopName:landmarkName];
    [[CDTARuntimeData instance] setToStopLatitude:self.latitude];
    [[CDTARuntimeData instance] setToStopLongitude:self.longitude];
    
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
    if ([service isMemberOfClass:[GetNearbyStopsService class]]) {

        NSArray *stopsResult = [[CDTARuntimeData instance] nearbyStops];
        NSMutableArray *notLandmarks = [[NSMutableArray alloc] init];
        
        for (NearbyStop *nearbyStop in stopsResult) {
            if (nearbyStop.stopId != 0) {
                [notLandmarks addObject:nearbyStop];
            }
        }
        
        nearbyStops = [notLandmarks copy];
        
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
        
       // [spinner stopAnimating];
        //[self.navigationItem setRightBarButtonItem:logoBarButton];
    }
    [self dismissProgressDialog];

}

- (void)threadErrorWithClass:(id)service response:(id)response
{
//    [spinner stopAnimating];

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
    }
    [self dismissProgressDialog];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Nearby Stops";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([nearbyStops count] > 0) {
        return [nearbyStops count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NearbyStopCell";
    NearbyStopCell *cell = (NearbyStopCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if ([nearbyStops count] == 0) {
        [cell.stopName setText:@"No nearby stops found"];
        
        [cell.showArrivalsLabel setHidden:YES];
        
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        NearbyStop *nearbyStop = [nearbyStops objectAtIndex:indexPath.row];
        
        NSMutableString *routesString = [[NSMutableString alloc] init];
        
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
        
        NSString *labelString = [NSString stringWithFormat:@"%@ Serviced by %@", nearbyStop.name, routesString];
        
        [cell.stopName setText:[CDTAUtilities formatLocationName:labelString]];
        
        // Resize stationName label to allow for multiple lines
        [cell.stopName removeFromSuperview];
        
        CGRect currentFrame = cell.stopName.frame;
        
        CGRect rect;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            rect = [cell.stopName.text boundingRectWithSize:CGSizeMake(cell.stopName.frame.size.width, CGFLOAT_MAX)
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
        
        [cell.contentView addSubview:cell.stopName];
        
        [cell.showArrivalsLabel setHidden:NO];
        [cell.showArrivalsLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]]];
        
        if (([expandedNearbyCells count] > 0) && [[expandedNearbyCells objectAtIndex:indexPath.row] boolValue]) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            [cell.showArrivalsLabel setText:@"Hide Arrivals"];
            
            cell.arrivalsView = [self createArrivalsViewForStopId:nearbyStop.stopId
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
            BOOL isExpanded = [[expandedNearbyCells objectAtIndex:indexPath.row] boolValue];
            [expandedNearbyCells replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!isExpanded]];
            
            if (!isExpanded) {
//                [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//                [spinner startAnimating];
                [self showProgressDialog];
                
                GetArrivalsService *arrivalsService = [[GetArrivalsService alloc] initWithListener:self
                                                                                            stopId:nearbyStop.stopId
                                                                              managedObjectContext:self.managedObjectContext];
                [arrivalsService setResultsCount:2];
                [arrivalsService execute];
                
                currentArrivalsStopId = nearbyStop.stopId;
            } else {
                [self.tableView reloadData];
            }
        };
        
        // NearbyStopCell overrides touchesBegan so we must replicate didSelectRowAtIndexPath functionality here
        cell.selectCellCallback = ^() {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            NearbyStop *nearbyStop = [nearbyStops objectAtIndex:indexPath.row];
            
            StopInfoViewController *stopInfoView = [[StopInfoViewController alloc] initWithNibName:@"StopInfoViewController"
                                                                                            bundle:[NSBundle mainBundle]
                                                                                            stopId:nearbyStop.stopId
                                                                                          stopName:nearbyStop.name
                                                                                        servicedBy:routesString
                                                                                          latitude:nearbyStop.latitude
                                                                                         longitude:nearbyStop.longitude];
            
            [stopInfoView setManagedObjectContext:self.managedObjectContext];
            
            [self.navigationController pushViewController:stopInfoView animated:YES];
        };
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 80.0f;
    
    if ([nearbyStops count] == 0) {
        rowHeight = CELL_HEIGHT_DEFAULT;
    } else {
        static NSString *cellIdentifier = @"NearbyStopCell";
        NearbyStopCell *cell = (NearbyStopCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        NearbyStop *nearbyStop = [nearbyStops objectAtIndex:indexPath.row];
        
        if ([[expandedNearbyCells objectAtIndex:indexPath.row] boolValue]) {
            UIView *arrivalsView = [self createArrivalsViewForStopId:nearbyStop.stopId
                                                             offsetX:0.0f
                                                             offsetY:0.0f];
            
            rowHeight = cell.frame.size.height + arrivalsView.frame.size.height + 16;
        } else {
            rowHeight = cell.frame.size.height;
        }
    }
    
    return rowHeight;
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

- (void)goToTrip
{
    TripPlannerViewController *tripPlannerView = [[TripPlannerViewController alloc] initWithNibName:@"TripPlannerViewController" bundle:[NSBundle mainBundle]];
    [tripPlannerView setManagedObjectContext:self.managedObjectContext];
    
    [self.navigationController pushViewController:tripPlannerView animated:YES];
}

@end
