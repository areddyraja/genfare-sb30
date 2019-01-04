//
//  TripPlannerViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/10/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TripPlannerViewController.h"
#import "CooCooBase.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "CDTATimePicker.h"
#import "CDTAUtilities.h"
#import "DatePicker.h"
#import "NearbyStop.h"
#import "RoutesSearchViewController.h"
#import "Stop.h"
#import "TripHistory.h"
#import "TripHistoryCell.h"
#import "TripPlannerService.h"
#import "TripRoutesViewController.h"
#import "LocationHelper.h"


@interface TripPlannerViewController ()

@end

NSString *const TRIP_PLANNER_TITLE = @"Trip Planner";
NSString *const TRIP_HISTORY_TITLE = @"Trip History";
NSString *const NEARBY_STOPS_TITLE = @"Nearby Stops";

@implementation TripPlannerViewController
{
    UIBarButtonItem *historyBarButton;
//    UIActivityIndicatorView *spinner;
    NSUserDefaults *defaults;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
    DatePicker *datePicker;
    CDTATimePicker *timePicker;
    NSString *originName;
    NSInteger originId;
    double originLatitude;
    double originLongitude;
    NSString *destinationName;
    NSInteger destinationId;
    double destinationLatitude;
    double destinationLongitude;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    SlideUpTableView *slideUpTableView;
    NSArray *tripHistory;
    NSArray *nearbyStops;
    BOOL viewingHistory;
    CGRect applicationFrame;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:TRIP_PLANNER_TITLE];
        [self setTitle:TRIP_PLANNER_TITLE];
        
        historyBarButton = [[UIBarButtonItem alloc] initWithTitle:@"History"
                                                            style:UIBarButtonItemStyleBordered
                                                           target:self
                                                           action:@selector(onHistoryPressed)];
        
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        defaults = [NSUserDefaults standardUserDefaults];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/YY"];
        
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"hh:mm aa"];
        
        locationManager = [[CLLocationManager alloc] init];
        currentLocation = [[CLLocation alloc] init];
        
        tripHistory = [[NSArray alloc] init];
        nearbyStops = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Trip Planner" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    // Change title of back button on next screen
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Planner"
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:nil
                                                                              action:nil]];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    applicationFrame = [[UIScreen mainScreen] bounds];
    applicationFrame.size.height = applicationFrame.size.height - NAVIGATION_BAR_HEIGHT - HELP_SLIDER_HEIGHT;
    
    // Load previous search
    originName = [defaults stringForKey:KEY_ORIGIN_NAME];
    originId = [defaults integerForKey:KEY_ORIGIN_ID];
    originLatitude = [defaults doubleForKey:KEY_ORIGIN_LATITUDE];
    originLongitude = [defaults doubleForKey:KEY_ORIGIN_LONGITUDE];
    destinationName = [defaults stringForKey:KEY_DESTINATION_NAME];
    destinationId = [defaults integerForKey:KEY_DESTINATION_ID];
    destinationLatitude = [defaults doubleForKey:KEY_DESTINATION_LATITUDE];
    destinationLongitude = [defaults doubleForKey:KEY_DESTINATION_LONGITUDE];
    
    [self.fromText setText:originName];
    [self.toText setText:destinationName];
    
    // Date & Time pickers
    datePicker = [DatePicker viewWithNibName:@"DatePicker" owner:self];
    timePicker = [CDTATimePicker viewWithNibName:@"CDTATimePicker" owner:self];
    
    // These setup methods MUST be called before the other picker methods,
    // otherwise, the UIView frame height is set incorrectly
    [datePicker setupWithBottomOffset:self.tabBarController.tabBar.frame.size.height + STATUS_BAR_HEIGHT + HELP_SLIDER_HEIGHT];
    [timePicker setupWithBottomOffset:self.tabBarController.tabBar.frame.size.height + STATUS_BAR_HEIGHT + HELP_SLIDER_HEIGHT];
    
    [datePicker addTargetForTodayButton:self action:@selector(dateTodayPressed)];
    [datePicker addTargetForDoneButton:self action:@selector(dateDonePressed)];
    [datePicker setHidden:YES parentFrame:applicationFrame animated:NO];
    
    [timePicker addTargetForNowButton:self action:@selector(timeNowPressed)];
    [timePicker addTargetForDoneButton:self action:@selector(timeDonePressed)];
    [timePicker setHidden:YES parentFrame:applicationFrame animated:NO];
    
    [self.view addSubview:datePicker];
    [self.view addSubview:timePicker];
    
    [self.dateText setText:[dateFormatter stringFromDate:[self dateToday]]];
    [self.timeText setText:[timeFormatter stringFromDate:[self timeNow]]];
    
    // Nearby locations
    UIGestureRecognizer *nearbyGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(loadNearbyStations)];
    [self.nearbyImage addGestureRecognizer:nearbyGesture];
    
    // Switch locations
    UIGestureRecognizer *switchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(switchStations)];
    [self.switchImage addGestureRecognizer:switchGesture];
    
    slideUpTableView = [SlideUpTableView viewWithNibName:@"SlideUpTableView" owner:self];
    [slideUpTableView.tableView setDataSource:self];
    [slideUpTableView.tableView setDelegate:self];
    [slideUpTableView initialize];
    [slideUpTableView addTargetForCloseButton:self action:@selector(closePressed)];
    [slideUpTableView setHidden:YES parentFrame:applicationFrame animated:NO];
    
    [self.view addSubview:slideUpTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem setRightBarButtonItem:historyBarButton];
    
    if (([[CDTARuntimeData instance] fromStopLatitude] != 0) && ([[CDTARuntimeData instance] fromStopLongitude] != 0)) {
        [self onSearchedStopSelected:[[CDTARuntimeData instance] fromStopId]
                                name:[[CDTARuntimeData instance] fromStopName]
                            arriving:NO
                            latitude:[[CDTARuntimeData instance] fromStopLatitude]
                           longitude:[[CDTARuntimeData instance] fromStopLongitude]];
    } else if (([[CDTARuntimeData instance] toStopLatitude] != 0) && ([[CDTARuntimeData instance] toStopLongitude] != 0)) {
        [self onSearchedStopSelected:[[CDTARuntimeData instance] toStopId]
                                name:[[CDTARuntimeData instance] toStopName]
                            arriving:YES
                            latitude:[[CDTARuntimeData instance] toStopLatitude]
                           longitude:[[CDTARuntimeData instance] toStopLongitude]];
    }
    
    [[CDTARuntimeData instance] setFromStopId:0];
    [[CDTARuntimeData instance] setFromStopName:@""];
    [[CDTARuntimeData instance] setFromStopLatitude:0];
    [[CDTARuntimeData instance] setFromStopLongitude:0];
    [[CDTARuntimeData instance] setToStopId:0];
    [[CDTARuntimeData instance] setToStopName:@""];
    [[CDTARuntimeData instance] setToStopLatitude:0];
    [[CDTARuntimeData instance] setToStopLongitude:0];
    
    //iOS6 Support
    [self.planTripButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    //iOS6 Support

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.fromText) {
        RoutesSearchViewController *routesSearchView =
        [[RoutesSearchViewController alloc] initWithNibName:@"RoutesSearchViewController"
                                                     bundle:[NSBundle mainBundle]];
        [routesSearchView setListener:self];
        [routesSearchView setManagedObjectContext:self.managedObjectContext];
        [routesSearchView setArriving:NO];
        
        [self.navigationController pushViewController:routesSearchView animated:YES];
    } else if (textField == self.toText) {
        RoutesSearchViewController *routesSearchView =
        [[RoutesSearchViewController alloc] initWithNibName:@"RoutesSearchViewController"
                                                     bundle:[NSBundle mainBundle]];
        [routesSearchView setListener:self];
        [routesSearchView setManagedObjectContext:self.managedObjectContext];
        [routesSearchView setArriving:YES];
        
        [self.navigationController pushViewController:routesSearchView animated:YES];
    } else if (textField == self.dateText) {
        [datePicker setHidden:NO parentFrame:applicationFrame animated:YES];
    } else if (textField == self.timeText) {
        [timePicker setHidden:NO parentFrame:applicationFrame animated:YES];
    }
    
    return NO;
}

#pragma mark - OnSearchedStopSelectedListener callback

- (void)onSearchedStopSelected:(int)stopId
                          name:(NSString *)stopName
                      arriving:(BOOL)arriving
                      latitude:(double)latitude
                     longitude:(double)longitude
{
    if (arriving) {
        destinationName = [CDTAUtilities formatLocationName:stopName];
        destinationId = stopId;
        
        // As of November 2014, it appears that Google's Directions API no longer needs the stop ID in parentheses
        // along with the stop name. In fact, adding in the parenthesized stop ID actually produces bad search results.
        // Let all searches use latitude and longitude.
        /*if (stopId != 0) {
         destinationLatitude = 0;
         destinationLongitude = 0;
         } else {
         destinationLatitude = latitude;
         destinationLongitude = longitude;
         }*/
        destinationLatitude = latitude;
        destinationLongitude = longitude;
        
        [self.toText setText:destinationName];
    } else {
        originName = [CDTAUtilities formatLocationName:stopName];
        originId = stopId;
        
        /*if (stopId != 0) {
         originLatitude = 0;
         originLongitude = 0;
         } else {
         originLatitude = latitude;
         originLongitude = longitude;
         }*/
        originLatitude = latitude;
        originLongitude = longitude;
        
        [self.fromText setText:originName];
    }
    
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Date/TimePicker methods

- (void)dateTodayPressed
{
    [self.dateText setText:[dateFormatter stringFromDate:[self dateToday]]];
    
    [datePicker setHidden:YES parentFrame:applicationFrame animated:YES];
}

- (void)dateDonePressed
{
    [self.dateText setText:[dateFormatter stringFromDate:[datePicker.picker date]]];
    
    [datePicker setHidden:YES parentFrame:applicationFrame animated:YES];
}

- (void)timeNowPressed
{
    [self.timeText setText:[timeFormatter stringFromDate:[self timeNow]]];
    
    [timePicker setHidden:YES parentFrame:applicationFrame animated:YES];
}

- (void)timeDonePressed
{
    [self.timeText setText:[timeFormatter stringFromDate:[timePicker.picker date]]];
    
    [timePicker setHidden:YES parentFrame:applicationFrame animated:YES];
}

- (NSDate *)dateToday
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit
                                                                       fromDate:[NSDate date]];
    [dateComponents setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    
    return [dateComponents date];
}

- (NSDate *)timeNow
{
    NSDateComponents *timeComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit
                                                                       fromDate:[NSDate date]];
    [timeComponents setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    
    NSInteger minutes = [timeComponents minute];
    
    float minuteFactor = ceilf((float) minutes / (float) 15);
    
    minutes = minuteFactor * 15;
    [timeComponents setMinute:minutes];
    
    return [timeComponents date];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
    
    [locationManager stopUpdatingLocation];
    
    GetNearbyStopsService *nearbyStopsService = [[GetNearbyStopsService alloc] initWithListener:self
                                                                                       latitude:currentLocation.coordinate.latitude
                                                                                      longitude:currentLocation.coordinate.longitude
                                                                                          count:10];
    [nearbyStopsService execute];
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetNearbyStopsService class]]) {
        nearbyStops = [[CDTARuntimeData instance] nearbyStops];
        
        [slideUpTableView.tableView reloadData];
        
        [slideUpTableView setHidden:NO parentFrame:applicationFrame animated:YES];
        
        [self setTitle:NEARBY_STOPS_TITLE];
        
//        [spinner stopAnimating];
        [self showProgressDialog];
        [self.navigationItem setRightBarButtonItem:historyBarButton];
    } else if ([service isMemberOfClass:[TripPlannerService class]]) {
//        [spinner stopAnimating];
        
        TripRoutesViewController *tripRoutesView = [[TripRoutesViewController alloc] initWithNibName:@"TripRoutesViewController"
                                                                                              bundle:[NSBundle mainBundle]];
        [tripRoutesView setOriginName:originName];
        [tripRoutesView setOriginId:originId];
        [tripRoutesView setDestinationName:destinationName];
        [tripRoutesView setDestinationId:destinationId];
        tripRoutesView.managedObjectContext=self.managedObjectContext;
        [self.navigationController pushViewController:tripRoutesView animated:YES];
    }
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    if ([service isMemberOfClass:[GetNearbyStopsService class]]) {
        [self setTitle:TRIP_PLANNER_TITLE];
        
//        [spinner stopAnimating];
        [self.navigationItem setRightBarButtonItem:historyBarButton];
    } else if ([service isMemberOfClass:[TripPlannerService class]]) {
//        [spinner stopAnimating];
        
        [[CDTARuntimeData instance] setTripDirections:[[Directions alloc] init]];
        
        TripRoutesViewController *tripRoutesView = [[TripRoutesViewController alloc] initWithNibName:@"TripRoutesViewController"
                                                                                              bundle:[NSBundle mainBundle]];
        [tripRoutesView setOriginName:originName];
        [tripRoutesView setOriginId:originId];
        [tripRoutesView setDestinationName:destinationName];
        [tripRoutesView setDestinationId:destinationId];
        [tripRoutesView setManagedObjectContext:self.managedObjectContext];
        [self.navigationController pushViewController:tripRoutesView animated:YES];
    }
    [self dismissProgressDialog];
}

#pragma mark - SlideUpTableView callbacks

- (void)closePressed
{
    [self setTitle:TRIP_PLANNER_TITLE];
    
    [slideUpTableView setHidden:YES parentFrame:applicationFrame animated:YES];
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (viewingHistory) {
        if ([tripHistory count] > 0) {
            return [tripHistory count];
        } else {
            return 1;
        }
    } else {
        return [nearbyStops count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (viewingHistory) {
        static NSString *cellIdentifier = @"TripHistoryCell";
        TripHistoryCell *cell = (TripHistoryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
            [cell.fromLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [cell.fromLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"primary"]]];
            
            [cell.toLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [cell.toLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]]];
        }
        
        if ([tripHistory count] == 0) {
            [cell.fromLabel setText:@"No recent searches."];
            
            [cell.deleteImage setHidden:YES];
            [cell.toLabel setHidden:YES];
        } else {
            TripHistory *history = [tripHistory objectAtIndex:indexPath.row];
            
            [cell.fromLabel setText:history.originName];
            [cell.toLabel setText:history.destinationName];
            
            [cell.deleteImage setHidden:NO];
            [cell.toLabel setHidden:NO];
            
            UITapGestureRecognizer *deleteGesture = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(deleteHistoryRow:)];
            [cell.deleteImage addGestureRecognizer:deleteGesture];
        }
        
        return cell;
    } else {
        static NSString *cellIdentifier = @"TripPlannerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [cell.textLabel setNumberOfLines:0];
        }
        
        NearbyStop *nearbyStop = [nearbyStops objectAtIndex:indexPath.row];
        
        [cell.textLabel setText:[CDTAUtilities formatLocationName:nearbyStop.name]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (viewingHistory) {
        if ([tripHistory count] > 0) {
            TripHistory *history = [tripHistory objectAtIndex:indexPath.row];
            
            originName = [CDTAUtilities formatLocationName:history.originName];
            originId = [history.originStopId intValue];
            originLatitude = [history.originLatitude doubleValue];
            originLongitude = [history.originLongitude doubleValue];
            
            [self.fromText setText:originName];
            
            destinationName = [CDTAUtilities formatLocationName:history.destinationName];
            destinationId = [history.destinationStopId intValue];
            destinationLatitude = [history.destinationLatitude doubleValue];
            destinationLongitude = [history.destinationLongitude doubleValue];
            
            [self.toText setText:destinationName];
        }
    } else {
        NearbyStop *nearbyStop = [nearbyStops objectAtIndex:indexPath.row];
        
        originName = [CDTAUtilities formatLocationName:nearbyStop.name];
        originId = nearbyStop.stopId;
        
        /*if (originId != 0) {
         originLatitude = 0;
         originLongitude = 0;
         } else {
         originLatitude = nearbyStop.latitude;
         originLongitude = nearbyStop.longitude;
         }*/
        originLatitude = nearbyStop.latitude;
        originLongitude = nearbyStop.longitude;
        
        [self.fromText setText:originName];
    }
    
    [self closePressed];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = CELL_HEIGHT_DEFAULT;
    
    if (viewingHistory && ([tripHistory count] > 0)) {
        static NSString *cellIdentifier = @"TripHistoryCell";
        TripHistoryCell *cell = (TripHistoryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        TripHistory *history = [tripHistory objectAtIndex:indexPath.row];
        
        CGRect rectFrom;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            rectFrom = [history.originName boundingRectWithSize:CGSizeMake(cell.fromLabel.frame.size.width, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:cell.fromLabel.font}
                                                        context:nil];
        } else {
            CGSize size = [history.originName sizeWithFont:cell.fromLabel.font
                                         constrainedToSize:CGSizeMake(cell.fromLabel.frame.size.width,
                                                                      cell.fromLabel.frame.size.height)];
            rectFrom.size = size;
        }
        
        CGRect rectTo;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            rectTo = [history.destinationName boundingRectWithSize:CGSizeMake(cell.toLabel.frame.size.width, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:cell.toLabel.font}
                                                           context:nil];
        } else {
            CGSize size = [history.destinationName sizeWithFont:cell.toLabel.font
                                              constrainedToSize:CGSizeMake(cell.toLabel.frame.size.width,
                                                                           cell.toLabel.frame.size.height)];
            rectTo.size = size;
        }
        
        rowHeight = (cell.fromLabel.frame.origin.y * 2) + rectFrom.size.height + rectTo.size.height;
    }
    
    return rowHeight;
}

#pragma mark - View controls

- (void)deleteHistoryRow:(id)sender
{
    UIView *contentView = [[sender view].superview superview];
    TripHistoryCell *cell = (TripHistoryCell *)[contentView superview];
    NSIndexPath *indexPath = [slideUpTableView.tableView indexPathForCell:cell];
    
    TripHistory *trip = [tripHistory objectAtIndex:indexPath.row];
    
    [self.managedObjectContext deleteObject:trip];
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    
    NSMutableArray *newHistory = [[NSMutableArray alloc] initWithArray:tripHistory];
    [newHistory removeObjectAtIndex:indexPath.row];
    
    tripHistory = [newHistory copy];
    
    [slideUpTableView.tableView reloadData];
}

- (void)onHistoryPressed
{
    viewingHistory = YES;
    
    [self setTitle:TRIP_HISTORY_TITLE];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:TRIP_HISTORY_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    tripHistory = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [slideUpTableView.tableView reloadData];
    
    [slideUpTableView setHidden:NO parentFrame:applicationFrame animated:YES];
}

- (void)loadNearbyStations
{
    viewingHistory = NO;
    
    if ([LocationHelper requestWhenInUseAuthorisation:locationManager]){
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//        [spinner startAnimating];
        [self showProgressDialog];
        [locationManager setDelegate:self];
        [locationManager startUpdatingLocation];
    } else {
        //let the user turn location service back on:
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Location service disabled"
                                                           message:@"Your location settings are currently disabled. Would you like to review them again?"
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK",nil];
        [theAlert show];
    }
    
    
}



- (void)switchStations
{
    [self.fromText setText:destinationName];
    [self.toText setText:originName];
    
    NSString *tempName = originName;
    NSInteger tempId = originId;
    double tempLatitude = originLatitude;
    double tempLongitude = originLongitude;
    
    originName = destinationName;
    originId = destinationId;
    originLatitude = destinationLatitude;
    originLongitude = destinationLongitude;
    
    destinationName = tempName;
    destinationId = tempId;
    destinationLatitude = tempLatitude;
    destinationLongitude = tempLongitude;
}

- (IBAction)planTrip:(id)sender {
    if (([originName length] > 0) && ([destinationName length] > 0)) {
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//        [spinner startAnimating];
        [self showProgressDialog];
        
        NSDateFormatter *serviceDateFormatter = [[NSDateFormatter alloc] init];
        [serviceDateFormatter setDateFormat:@"MM/dd/yy hh:mm a"];
        
        NSDate *scheduleTime = [serviceDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",
                                                                     self.dateText.text,
                                                                     self.timeText.text]];
        
        BOOL isArriving = (self.leaveSegment.selectedSegmentIndex == 1) ? YES : NO;
        
        TripPlannerService *tripPlannerService = [[TripPlannerService alloc] initWithListener:self
                                                                                   originName:originName
                                                                               originLatitude:originLatitude
                                                                              originLongitude:originLongitude
                                                                              destinationName:destinationName
                                                                          destinationLatitude:destinationLatitude
                                                                         destinationLongitude:destinationLongitude
                                                                                 scheduleTime:scheduleTime
                                                                                   isArriving:isArriving];
        [tripPlannerService execute];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:TRIP_HISTORY_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        BOOL saveTrip = NO;
        
        if ((originId == 0) && (destinationId == 0)) { // Both are landmarks
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(originLatitude == %lf) AND (originLongitude == %lf) AND (destinationLatitude == %lf) AND (destinationLongitude == %lf)",
                                      originLatitude, originLongitude, destinationLatitude, destinationLongitude];
            [fetchRequest setPredicate:predicate];
        } else if ((originId != 0) && (destinationId == 0)) { // Destination is landmark
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(originStopId == %d) AND (destinationLatitude == %lf) AND (destinationLongitude == %lf)",
                                      originId, destinationLatitude, destinationLongitude];
            [fetchRequest setPredicate:predicate];
        } else if ((originId == 0) && (destinationId != 0)) { // Origin is landmark
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(originLatitude == %lf) AND (originLongitude == %lf) AND (destinationStopId == %d)",
                                      originLatitude, originLongitude, destinationId];
            [fetchRequest setPredicate:predicate];
        } else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(originStopId == %d) AND (destinationStopId == %d)",
                                      originId, destinationId];
            [fetchRequest setPredicate:predicate];
        }
        
        NSError *error;
        if ([[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] count] == 0) {
            saveTrip = YES;
        }
        
        if (saveTrip) {
            TripHistory *history = (TripHistory *)[NSEntityDescription insertNewObjectForEntityForName:TRIP_HISTORY_MODEL
                                                                                inManagedObjectContext:self.managedObjectContext];
            
            history.originName = originName;
            history.originStopId = [NSNumber numberWithInteger:originId];
            history.originLatitude = [NSNumber numberWithDouble:originLatitude];
            history.originLongitude = [NSNumber numberWithDouble:originLongitude];
            history.destinationName = destinationName;
            history.destinationStopId = [NSNumber numberWithInteger:destinationId];
            history.destinationLatitude = [NSNumber numberWithDouble:destinationLatitude];
            history.destinationLongitude = [NSNumber numberWithDouble:destinationLongitude];
            
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
            }
        }
        
        [defaults setObject:originName forKey:KEY_ORIGIN_NAME];
        [defaults setInteger:originId forKey:KEY_ORIGIN_ID];
        [defaults setDouble:originLatitude forKey:KEY_ORIGIN_LATITUDE];
        [defaults setDouble:originLongitude forKey:KEY_ORIGIN_LONGITUDE];
        [defaults setObject:destinationName forKey:KEY_DESTINATION_NAME];
        [defaults setInteger:destinationId forKey:KEY_DESTINATION_ID];
        [defaults setDouble:destinationLatitude forKey:KEY_DESTINATION_LATITUDE];
        [defaults setDouble:destinationLongitude forKey:KEY_DESTINATION_LONGITUDE];
        
        [defaults synchronize];
    }
}

#pragma mark Location Alert View
- (void)alertView:(UIAlertView *)theAlert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
