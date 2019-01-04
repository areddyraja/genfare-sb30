//
//  RoutesViewController.m
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RoutesViewController.h"
#import "Alert.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
#import "GetDirectionsForRouteService.h"
#import "GetRoutesService.h"
//#import "LogoBarButtonItem.h"
#import "Route.h"
#import "RouteBadge.h"
#import "RouteDetailsViewController.h"

@interface RoutesViewController ()

@end

NSString *const ROUTES_TITLE = @"Routes";

@implementation RoutesViewController
{
    //LogoBarButtonItem *logoBarButton;
//    UIActivityIndicatorView *spinner;
    NSArray *routes;
    NSArray *alerts;
    BOOL allRoutesAlert;
    Route *selectedRoute;
    UILabel *emptyLabel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:ROUTES_TITLE];
        [self setTitle:ROUTES_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        routes = [[NSArray alloc] init];
        alerts = [[NSArray alloc] init];
        
        emptyLabel = [[UILabel alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSString *emptyText = @"Unable to communicate with server. Please ensure that you are connected to the internet.";
    [emptyLabel setTextAlignment:NSTextAlignmentCenter];
    [emptyLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [emptyLabel setNumberOfLines:0];
    
    CGRect rect;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        rect = [emptyText boundingRectWithSize:CGSizeMake(self.view.frame.size.width - (VIEW_PADDING * 2), CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:emptyLabel.font}
                                       context:nil];
    } else {
        CGSize size = [emptyText sizeWithFont:emptyLabel.font
                            constrainedToSize:CGSizeMake(self.view.frame.size.width - (VIEW_PADDING * 2),
                                                         self.view.frame.size.height)];
        rect.size = size;
    }
    
    [emptyLabel setFrame:rect];
    [emptyLabel setText:emptyText];
//    [emptyLabel setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                      (applicationFrame.size.height / 2) - (emptyLabel.frame.size.height/2 + HELP_SLIDER_HEIGHT))];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Routes" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
    
    alerts = [[CDTARuntimeData instance] alerts];
    
    allRoutesAlert = NO;
    for (Alert *alert in alerts) {
        if ([alert.routeType isEqualToString:ALERT_ALL_ROUTES]) {
            allRoutesAlert = YES;
            
            break;
        }
    }
    
    [emptyLabel removeFromSuperview];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ROUTE_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    routes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([routes count] > 0) {
        [emptyLabel setHidden:YES];
        
        [self.tableView reloadData];
    } else {
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//        [spinner startAnimating];
        [self showProgressDialog];
        
        GetRoutesService *routesService = [[GetRoutesService alloc] initWithListener:self
                                                                managedObjectContext:self.managedObjectContext];
        [routesService execute];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetRoutesService class]]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:ROUTE_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        routes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([routes count] > 0) {
            [emptyLabel setHidden:YES];
            
            [self.tableView reloadData];
        } else {
            [emptyLabel setHidden:NO];
            [self.view addSubview:emptyLabel];
        }
        
//        [spinner stopAnimating];
        //[self.navigationItem setRightBarButtonItem:logoBarButton];
    } else if ([service isMemberOfClass:[GetDirectionsForRouteService class]]) {
        RouteDetailsViewController *routeDetailsView = [[RouteDetailsViewController alloc]
                                                        initWithNibName:@"RouteDetailsViewController"
                                                        bundle:[NSBundle mainBundle]];
        [routeDetailsView setManagedObjectContext:self.managedObjectContext];
        [routeDetailsView setRoute:selectedRoute];
        
        [self.navigationController pushViewController:routeDetailsView animated:YES];
        
//        [spinner stopAnimating];
    }
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    if ([service isMemberOfClass:[GetRoutesService class]]) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:ROUTE_MODEL
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        routes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([routes count] > 0) {
            [emptyLabel setHidden:YES];
            
            [self.tableView reloadData];
        } else {
            [emptyLabel setHidden:NO];
            [self.view addSubview:emptyLabel];
        }
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
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [routes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RouteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    Route *route = [routes objectAtIndex:indexPath.row];
    
    RouteBadge *routeBadge = [[RouteBadge alloc] initWithFrame:CGRectMake(0.0f,
                                                                          0.0f,
                                                                          ROUTE_BADGE_RADIUS,
                                                                          ROUTE_BADGE_RADIUS)
                                                    badgeColor:[UIColor colorWithHexString:route.color]
                                                     textColor:[UIColor colorWithHexString:route.textColor]
                                                          text:[NSString stringWithFormat:@"%@", route.routeId]];
    
    [cell.imageView setImage:[routeBadge image]];
    
    [cell.textLabel setNumberOfLines:2];
    [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_TEXT_SIZE_SMALL]];
    [cell.textLabel setText:[CDTAUtilities formatLocationName:route.name]];
    
    if (allRoutesAlert) {
        [cell.detailTextLabel setText:@"Alert"];
        [cell.detailTextLabel setTextColor:[UIColor redColor]];
        [cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:ALERT_TEXT_SIZE]];
    } else {
        for (Alert *alert in alerts) {
            if (([alert.routeType isEqualToString:ALERT_NX_ROUTE] && [route.routeId intValue] == NX_ROUTE_ID)
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//    [spinner startAnimating];
    [self showProgressDialog];
    
    Route *route = [routes objectAtIndex:indexPath.row];
    
    GetDirectionsForRouteService *directionsService = [[GetDirectionsForRouteService alloc] initWithListener:self
                                                                                                     routeId:[route.routeId intValue]
                                                                                        managedObjectContext:self.managedObjectContext];
    [directionsService execute];
    
    selectedRoute = route;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT_LARGE;
}

@end
