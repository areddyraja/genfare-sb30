//
//  StopsSearchViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "StopsSearchViewController.h"
#import "CooCooBase.h"
#import "Alert.h"
#import "AlertCell.h"
#import "AlertInfoViewController.h"
#import "CDTAAppConstants.h"
#import "CDTARuntimeData.h"
#import "CDTAUtilities.h"
//#import "LogoBarButtonItem.h"
#import "Stop.h"

@interface StopsSearchViewController ()

@end

@implementation StopsSearchViewController
{
    //LogoBarButtonItem *logoBarButton;
//    UIActivityIndicatorView *spinner;
    NSArray *stops;
    NSMutableArray *alerts;
    NSMutableArray *filteredStops;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"search_stops"]];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        alerts = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    [self setTitle:[NSString stringWithFormat:@"Search Route %d", self.routeId]];
    
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//    [spinner startAnimating];
    [self showProgressDialog];
    
    GetStopsService *stopsService = [[GetStopsService alloc] initWithListener:self
                                                                      routeId:self.routeId
                                                         managedObjectContext:self.managedObjectContext];
    [stopsService execute];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSArray *allAlerts = [[CDTARuntimeData instance] alerts];
    
    for (Alert *alert in allAlerts) {
        if ([alert containsRouteId:self.routeId]) {
            [alerts addObject:alert];
        }
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
    if ([service isMemberOfClass:[GetStopsService class]]) {
        [self setTableData];
    }
    
//    [spinner stopAnimating];
    [self dismissProgressDialog];
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self setTableData];
    
//    [spinner stopAnimating];
    [self dismissProgressDialog];

    //[self.navigationItem setRightBarButtonItem:logoBarButton];
}

- (void)setTableData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STOP_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"routeId == %d", self.routeId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    stops = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    filteredStops = [NSMutableArray arrayWithCapacity:[stops count]];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        if ([alerts count] > 0) {
            return 2;
        } else {
            return 1;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Stops";
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        if ([alerts count] > 0) {
            switch (section) {
                case 0:
                    title = @"Alerts";
                    break;
                    
                case 1:
                    title = @"Stops";
                    break;
                    
                default:
                    title = @"Stops";
                    break;
            }
        }
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        count = [filteredStops count];
    } else {
        if ([alerts count] > 0) {
            switch (section) {
                case 0:
                    count = [alerts count];
                    break;
                    
                case 1:
                    count = [stops count];
                    break;
                    
                default:
                    count = 0;
                    break;
            }
        } else {
            count = [stops count];
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
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        Stop *stop = [filteredStops objectAtIndex:indexPath.row];
        [cell.textLabel setNumberOfLines:2];
        [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_TEXT_SIZE_SMALL]];
        
        [cell.textLabel setText:[CDTAUtilities formatLocationName:stop.name]];
        
        return cell;
    } else {
        if ([alerts count] > 0) {
            if (indexPath.section == 0) {
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
                static NSString *cellIdentifier = @"StopsSearchCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                
                Stop *stop = [stops objectAtIndex:indexPath.row];
                
                [cell.textLabel setText:[CDTAUtilities formatLocationName:stop.name]];
                [cell.textLabel setNumberOfLines:2];
                [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_TEXT_SIZE_SMALL]];
                
                return cell;
            }
        } else {
            static NSString *cellIdentifier = @"StopsSearchCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            Stop *stop = [stops objectAtIndex:indexPath.row];
            
            [cell.textLabel setText:[CDTAUtilities formatLocationName:stop.name]];
            [cell.textLabel setNumberOfLines:2];
            [cell.textLabel setFont:[UIFont systemFontOfSize:CELL_TEXT_SIZE_SMALL]];
            
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self.listener onStopSelected:[filteredStops objectAtIndex:indexPath.row]
                             arriving:self.arriving];
    } else {
        if ([alerts count] > 0) {
            if (indexPath.section == 0) {
                AlertInfoViewController *alertInfoView = [[AlertInfoViewController alloc] initWithNibName:@"AlertInfoViewController"
                                                                                                   bundle:[NSBundle mainBundle]];
                [alertInfoView setAlert:[alerts objectAtIndex:indexPath.row]];
                [alertInfoView setManagedObjectContext:self.managedObjectContext];
                [self.navigationController pushViewController:alertInfoView animated:YES];
            } else {
                [self.listener onStopSelected:[stops objectAtIndex:indexPath.row]
                                     arriving:self.arriving];
            }
        } else {
            [self.listener onStopSelected:[stops objectAtIndex:indexPath.row]
                                 arriving:self.arriving];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search Bar methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    [filteredStops removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains [cd] %@", searchText];
    
    filteredStops = [NSMutableArray arrayWithArray:[stops filteredArrayUsingPredicate:resultPredicate]];
}

@end
