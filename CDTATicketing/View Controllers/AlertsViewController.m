//
//  AlertsViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/29/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "AlertsViewController.h"
#import "CooCooBase.h"
#import "Alert.h"
#import "AlertCell.h"
#import "AlertInfoViewController.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "Route.h"
#import "RouteBadge.h"
#import "Singleton.h"
#import "SignInViewController.h"
#import "iRide-Swift.h"

@interface AlertsViewController ()
@end
NSString *const ALERTS_TITLE = @"Alerts";
@implementation AlertsViewController{
//    UIActivityIndicatorView *spinner;
    NSArray *routes;
    NSArray *alerts;
    UILabel *emptyLabel;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:ALERTS_TITLE];
        [self setTitle:ALERTS_TITLE];
       // spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        routes = [[NSArray alloc] init];
        alerts = [[NSArray alloc] init];
    }
    return self;
}
#pragma mark - View lifecycle Methods
- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kLoginScreenNavNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen:) name:@"kLoginScreenNavNotification" object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//    [spinner startAnimating];
    [self showProgressDialog];
    GetAlertsService *alertsService = [[GetAlertsService alloc] initWithListener:self];
    [alertsService execute];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ROUTE_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    routes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    [self displayAlertsEmptyLabel];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSideMenu:)];
    menuButton.tintColor = UIColor.whiteColor;
    [self.navigationItem setLeftBarButtonItem:menuButton];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Alerts" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - View Selector Methods
-(void)displayAlertsEmptyLabel{
    if ([alerts count] > 0) {
        [self.tableView setHidden:NO];
        [emptyLabel setHidden:YES];
    }else{
        [self.tableView setHidden:YES];
        [emptyLabel setHidden:NO];
        if (!emptyLabel) {
            // Should only ever happen if there is a server request error on the very first load of this View Controller
            CGRect applicationFrame = [[UIScreen mainScreen] bounds];
            emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width - 20, 0)];
            [emptyLabel setText:@"No Alerts"];
            [emptyLabel setTextAlignment:NSTextAlignmentCenter];
            [emptyLabel setFont:[UIFont systemFontOfSize:16]];
            [emptyLabel setNumberOfLines:0];
            [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [emptyLabel sizeToFit];
            [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                              (applicationFrame.size.height / 2) - (emptyLabel.frame.size.height/2 + HELP_SLIDER_HEIGHT))];

            [self.view addSubview:emptyLabel];
        }
    }
}
- (void)setAlertsCount:(int)count{
    [self.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d", count]];
}
#pragma mark - UITableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [alerts count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"AlertCell";
    AlertCell *cell = (AlertCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    Alert *alert = [alerts objectAtIndex:indexPath.row];
    NSArray *routeIds = [[NSArray alloc] initWithArray:alert.routeIds];
    NSInteger count = [routeIds count];
    if (count > 0) {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.routeId == %d", [[routeIds objectAtIndex:0] intValue]];
        NSArray *filteredRoutes = [routes filteredArrayUsingPredicate:resultPredicate];
        NSInteger filteredCount = [filteredRoutes count];
        if (filteredCount > 0) {
            Route *route = [filteredRoutes objectAtIndex:0];
            RouteBadge *routeBadge1 = [[RouteBadge alloc] initWithFrame:CGRectMake(cell.affectsLabel.frame.origin.x + cell.affectsLabel.frame.size.width + VIEW_PADDING,
                                                                                   cell.affectsLabel.frame.origin.y + (cell.affectsLabel.frame.size.height / 2)
                                                                                   - (ROUTE_BADGE_RADIUS / 2),
                                                                                   ROUTE_BADGE_RADIUS,
                                                                                   ROUTE_BADGE_RADIUS)
                                                             badgeColor:[UIColor colorWithHexString:route.color]
                                                              textColor:[UIColor colorWithHexString:route.textColor]
                                                                   text:[NSString stringWithFormat:@"%@", [routeIds objectAtIndex:0]]];
            [cell addSubview:routeBadge1];
            if (count > 1) {
                for (int i = 1; i < count; i++) {
                    resultPredicate = [NSPredicate predicateWithFormat:@"SELF.routeId == %d", [[routeIds objectAtIndex:i] intValue]];
                    filteredRoutes = [routes filteredArrayUsingPredicate:resultPredicate];
                    filteredCount = [filteredRoutes count];
                    if (filteredCount > 0) {
                        route = [filteredRoutes objectAtIndex:0];
                        RouteBadge *routeBadge = [[RouteBadge alloc] initWithFrame:CGRectMake(cell.affectsLabel.frame.origin.x + cell.affectsLabel.frame.size.width
                                                                                              + VIEW_PADDING + ((routeBadge1.frame.size.width + VIEW_PADDING) * i),
                                                                                              routeBadge1.frame.origin.y,
                                                                                              ROUTE_BADGE_RADIUS,
                                                                                              ROUTE_BADGE_RADIUS)
                                                                        badgeColor:[UIColor colorWithHexString:route.color]
                                                                         textColor:[UIColor colorWithHexString:route.textColor]
                                                                              text:[NSString stringWithFormat:@"%@", [routeIds objectAtIndex:i]]];
                        [cell addSubview:routeBadge];
                    }
                }
            }
        }
    } else{
        UILabel *routeTypeLabel = [[UILabel alloc] init];
        [routeTypeLabel setText:alert.routeType];
        [routeTypeLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [routeTypeLabel setNumberOfLines:0];
        [routeTypeLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [routeTypeLabel sizeToFit];
        [routeTypeLabel setFrame:CGRectMake(cell.affectsLabel.frame.origin.x + cell.affectsLabel.frame.size.width
                                            + VIEW_PADDING,
                                            cell.affectsLabel.frame.origin.y + (cell.affectsLabel.frame.size.height / 2)
                                            - (routeTypeLabel.frame.size.height / 2),
                                            routeTypeLabel.frame.size.width,
                                            routeTypeLabel.frame.size.height)];
        
        [cell addSubview:routeTypeLabel];
    }
    [cell.headerLabel setText:alert.header];
    return cell;
}
#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AlertInfoViewController *alertInfoView = [[AlertInfoViewController alloc] initWithNibName:@"AlertInfoViewController"
                                                                                       bundle:[NSBundle mainBundle]];
    [alertInfoView setAlert:[alerts objectAtIndex:indexPath.row]];
    alertInfoView.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:alertInfoView animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"AlertCell";
    AlertCell *cell = (AlertCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell.frame.size.height;
}
#pragma mark - Service callbacks
- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetAlertsService class]]) {
        alerts = [[CDTARuntimeData instance] alerts];
        if ([alerts count] > 0) {
            [self setAlertsCount:(int)[alerts count]];
            [self.tableView setHidden:NO];
            [emptyLabel setHidden:YES];
            [self.tableView reloadData];
        } else {
            [self displayAlertsEmptyLabel];
        }
    }
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service response:(id)response{
    [emptyLabel setHidden:NO];
    [self.view addSubview:emptyLabel];
    if ([service isMemberOfClass:[GetAlertsService class]]) {
        NSLog(@"GetAlertsService Failed");
    }
    [self dismissProgressDialog];
}

@end
