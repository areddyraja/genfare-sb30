//
//  RouteDetailsViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RouteDetailsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "CooCooBase.h"
#import "Alert.h"
#import "AlertCell.h"
#import "AlertInfoViewController.h"
#import "CDTAAppConstants.h"
#import "CDTAMapImageViewController.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
#import "Map.h"
#import "RouteBadge.h"
#import "RouteDescriptionViewController.h"
#import "RouteDetailsHeaderView.h"
#import "RouteDirection.h"
#import "Stop.h"
#import "StopInfoViewController.h"

@interface RouteDetailsViewController ()

@end

NSString *const ROUTE_DETAILS_TITLE = @"Route Details";

@implementation RouteDetailsViewController
{
    //LogoBarButtonItem *logoBarButton;
//    UIActivityIndicatorView *spinner;
    NSMutableDictionary *stopsDictionary;
    NSMutableDictionary *headerTapsDictionary;
    NSMutableArray *alerts;
    NSMutableArray *schedulePdfs;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:ROUTE_DETAILS_TITLE];
        [self setTitle:ROUTE_DETAILS_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        stopsDictionary = [[NSMutableDictionary alloc] init];
        headerTapsDictionary = [[NSMutableDictionary alloc] init];
        alerts = [[NSMutableArray alloc] init];
        schedulePdfs = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setViewDetails:[NSString stringWithFormat:@"Route %@", self.route.routeId]];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Route Details" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    // Change title of back button on next screen
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:nil
                                                                              action:nil]];
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Header"];
    
    RouteBadge *badge = [[RouteBadge alloc] initWithFrame:CGRectMake(self.routeBadge.frame.origin.x,
                                                                     self.routeBadge.frame.origin.y,
                                                                     ROUTE_BADGE_RADIUS,
                                                                     ROUTE_BADGE_RADIUS)
                                               badgeColor:[UIColor colorWithHexString:self.route.color]
                                                textColor:[UIColor colorWithHexString:self.route.textColor]
                                                     text:[NSString stringWithFormat:@"%@", self.route.routeId]];
    
    [self.routeBadge setImage:badge.image];
    
    [self.routeName setText:[CDTAUtilities formatLocationName:self.route.name]];
    
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//    [spinner startAnimating];
    [self showProgressDialog];
    
    GetStopsService *stopsService = [[GetStopsService alloc] initWithListener:self
                                                                      routeId:[self.route.routeId intValue]
                                                         managedObjectContext:self.managedObjectContext];
    [stopsService execute];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [alerts removeAllObjects];
    
    NSArray *allAlerts = [[CDTARuntimeData instance] alerts];
    
    for (Alert *alert in allAlerts) {
        if ([[alert routeType] isEqualToString:ALERT_ALL_ROUTES]
            || ([[alert routeType] isEqualToString:ALERT_NX_ROUTE] && [self.route.routeId intValue] == NX_ROUTE_ID)
            || [alert containsRouteId:[self.route.routeId intValue]]) {
            [alerts addObject:alert];
        }
    }

    //iOS6 Support
    [self.scheduleButtonProperty setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    [self.mapButtonProperty setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    [self.aboutButtonProperty setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]] forState:UIControlStateNormal];
    //iOS6 Support
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetStopsService class]]) {
        [self setTableData];
    }
    [self dismissProgressDialog];
    //[spinner stopAnimating];
    //[self.navigationItem setRightBarButtonItem:logoBarButton];

}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self setTableData];

    [self dismissProgressDialog];
 //  [spinner stopAnimating];
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
}

- (void)setTableData
{
    [stopsDictionary removeAllObjects];
    [headerTapsDictionary removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STOP_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"routeId == %d", [self.route.routeId intValue]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *stops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *headers = [[NSMutableArray alloc] init];
    
    // Get all direction headers
    for (Stop *stop in stops) {
        [headers addObject:stop.direction];
    }
    
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:headers];
    NSSet *uniqueHeaders = [orderedSet set];
    
    // Create arrays of stops for each unique direction
    int index = 0;
    for (NSString *uniqueHeader in uniqueHeaders) {
        NSMutableArray *stopsInDirection = [[NSMutableArray alloc] init];
        
        for (Stop *stop in stops) {
            NSString *header = stop.direction;
            if ([header isEqualToString:uniqueHeader]) {
                [stopsInDirection addObject:stop];
            }
        }
        
        [stopsDictionary setObject:[stopsInDirection copy] forKey:uniqueHeader];
        [headerTapsDictionary setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:index]];
        
        index++;
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([alerts count] > 0) {
        return [stopsDictionary count] + 1;
    } else {
        return [stopsDictionary count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [stopsDictionary allKeys];
    
    if (([alerts count] > 0) && (section == 0)) {
        static NSString *headerReuseIdentifier = @"Header";
        
        // Reuse the instance that was created in viewDidLoad
        UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
        [sectionHeaderView.textLabel setText:@"Alerts"];
        [sectionHeaderView.textLabel setTextColor:[UIColor redColor]];
        
        return sectionHeaderView;
    } else {
        NSInteger index = ([alerts count] > 0) ? section - 1 : section;
        
        RouteDetailsHeaderView *routeHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"RouteDetailsHeaderView"
                                                                                 owner:self
                                                                               options:nil]
                                                   objectAtIndex:0];
        [routeHeaderView setTag:section];
        
        NSNumber *headerIsTapped = [headerTapsDictionary objectForKey:[NSNumber numberWithInteger:index]];
        
        if ([headerIsTapped intValue] == 0) {
            [routeHeaderView.expandedLabel setText:@"+"];
        } else {
            [routeHeaderView.expandedLabel setText:@"-"];
        }
        
        [routeHeaderView.titleLabel setText:[keys objectAtIndex:index]];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(handleHeaderTap:)];
        [tapRecognizer setDelegate:self];
        
        [routeHeaderView addGestureRecognizer:tapRecognizer];
        
        return routeHeaderView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (([alerts count] > 0) && (section == 0)) {
        // Standard table view header height
        return 22.0f;
    } else {
        return 44.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    NSArray *keys = [stopsDictionary allKeys];
    
    if (([alerts count] > 0) && (section == 0)) {
        count = [alerts count];
    } else {
        NSInteger index = ([alerts count] > 0) ? section - 1 : section;
        
        NSNumber *headerIsTapped = [headerTapsDictionary objectForKey:[NSNumber numberWithInteger:index]];
        
        if ([headerIsTapped intValue] == 0) {
            count = 0;
        } else {
            count = [[stopsDictionary objectForKey:[keys objectAtIndex:index]] count];
        }
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (([alerts count] > 0) && (indexPath.section == 0)) {
        static NSString *cellIdentifier = @"AlertCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        Alert *alert = [alerts objectAtIndex:indexPath.row];
        
        [cell.textLabel setNumberOfLines:2];
        [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_TEXT_SIZE_SMALL]];
        [cell.textLabel setText:alert.header];
        
        return cell;
    } else {
        NSInteger index = ([alerts count] > 0) ? indexPath.section - 1 : indexPath.section;
        
        static NSString *cellIdentifier = @"StopInfoSearchCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        NSArray *keys = [stopsDictionary allKeys];
        NSArray *stops = [stopsDictionary objectForKey:[keys objectAtIndex:index]];
        
        Stop *stop = [stops objectAtIndex:indexPath.row];
        
        [cell.textLabel setNumberOfLines:2];
        [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_TEXT_SIZE_SMALL]];
        [cell.textLabel setText:[CDTAUtilities formatLocationName:stop.name]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (([alerts count] > 0) && (indexPath.section == 0)) {
        AlertInfoViewController *alertInfoView = [[AlertInfoViewController alloc] initWithNibName:@"AlertInfoViewController"
                                                                                           bundle:[NSBundle mainBundle]];
        [alertInfoView setAlert:[alerts objectAtIndex:indexPath.row]];
        [alertInfoView setManagedObjectContext:self.managedObjectContext];
        [self.navigationController pushViewController:alertInfoView animated:YES];
    } else {
        NSInteger index = ([alerts count] > 0) ? indexPath.section - 1 : indexPath.section;
        
        NSArray *keys = [stopsDictionary allKeys];
        NSArray *stops = [stopsDictionary objectForKey:[keys objectAtIndex:index]];
        
        Stop *stop = [stops objectAtIndex:indexPath.row];
        
        StopInfoViewController *stopInfoView = [[StopInfoViewController alloc] initWithNibName:@"StopInfoViewController"
                                                                                        bundle:[NSBundle mainBundle]
                                                                                        stopId:[stop.stopId intValue]
                                                                                      stopName:stop.name
                                                                                    servicedBy:stop.servicedBy
                                                                                      latitude:[stop.latitude doubleValue]
                                                                                     longitude:[stop.longitude doubleValue]];
        [stopInfoView setManagedObjectContext:self.managedObjectContext];
        
        [self.navigationController pushViewController:stopInfoView animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (void)handleHeaderTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSNumber *key = ([alerts count] > 0) ? [NSNumber numberWithInteger:gestureRecognizer.view.tag - 1] : [NSNumber numberWithInteger:gestureRecognizer.view.tag];
    int previousValue = [[headerTapsDictionary objectForKey:key] intValue];
    
    if (previousValue == 0) {
        [headerTapsDictionary setObject:[NSNumber numberWithInt:1] forKey:key];
    } else {
        [headerTapsDictionary setObject:[NSNumber numberWithInt:0] forKey:key];
    }
    
    [self.tableView reloadData];
}

#pragma mark - View controls

- (IBAction)viewSchedule:(id)sender
{
    if ([self.route.scheduleUrl length] > 0) {
        if ([schedulePdfs count] == 0) {
//            [spinner startAnimating];
            [self showProgressDialog];
            
            NSRange lastSlash = [self.route.scheduleUrl rangeOfString:@"/" options:NSBackwardsSearch];
            NSString *filename = [self.route.scheduleUrl substringWithRange:NSMakeRange(lastSlash.location + 1,
                                                                                        [self.route.scheduleUrl length] - lastSlash.location - 1)];
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.route.scheduleUrl]];
            AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
            
            [requestOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:path append:NO]];
            
            __block RouteDetailsViewController *blockSafeSelf = self;
            
            [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (operation.response.statusCode == 200) {
                    [schedulePdfs addObject:[NSURL fileURLWithPath:path]];
                    
                    QLPreviewController *previewController = [[QLPreviewController alloc] init];
                    [previewController setDataSource:blockSafeSelf];
                    [previewController setDelegate:blockSafeSelf];
                    [previewController setCurrentPreviewItemIndex:0];
                    
                    [self.navigationController presentViewController:previewController animated:YES completion:nil];
                    
//                    [spinner stopAnimating];
                    [self dismissProgressDialog];
                    //[self.navigationItem setRightBarButtonItem:logoBarButton];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                [spinner stopAnimating];
                [self dismissProgressDialog];
                //[self.navigationItem setRightBarButtonItem:logoBarButton];
            }];
            
            [requestOperation start];
        } else {
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            [previewController setDataSource:self];
            [previewController setDelegate:self];
            [previewController setCurrentPreviewItemIndex:0];
            
            [self.navigationController presentViewController:previewController animated:YES completion:nil];
        }
    }
}

- (IBAction)viewMap:(id)sender
{
    Map *map = [[Map alloc] init];
    [map setName:[NSString stringWithFormat:@"Route %@", self.route.routeId]];
    [map setIsLocal:NO];
    [map setUri:self.route.mapImageUrl];
    
    CDTAMapImageViewController *mapImageView = [[CDTAMapImageViewController alloc] initWithNibName:@"CDTAMapImageViewController"
                                                                                            bundle:[NSBundle mainBundle]
                                                                                               map:map];
    [mapImageView setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:mapImageView animated:YES];
}

- (IBAction)viewDescription:(id)sender
{
    RouteDescriptionViewController *routeDescriptionView = [[RouteDescriptionViewController alloc] initWithNibName:@"RouteDescriptionViewController"
                                                                                                            bundle:[NSBundle mainBundle]
                                                                                                             route:self.route];
    [routeDescriptionView setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:routeDescriptionView animated:YES];
}

#pragma mark - QLPreviewController methods

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return [schedulePdfs count];
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [schedulePdfs objectAtIndex:index];
}

@end
