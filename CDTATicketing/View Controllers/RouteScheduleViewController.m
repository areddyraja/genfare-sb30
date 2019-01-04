//
//  RouteScheduleViewController.m
//  CDTA
//
//  Created by CooCooTech on 11/13/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RouteScheduleViewController.h"
#import "CooCooBase.h"
#import "CDTAAppConstants.h"

@interface RouteScheduleViewController ()

@end

// TODO: Needed?
@implementation RouteScheduleViewController
{
//    UIActivityIndicatorView *spinner;
    SlideUpTableView *slideUpTableView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setViewName:@"Route Schedule"];
    [self setViewDetails:[NSString stringWithFormat:@"Route %@", self.route.routeId]];
    
    [self setTitle:self.route.name];
    
//    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//    [spinner startAnimating];
    [self showProgressDialog];
    
    GetCDTASchedulesService *schedulesService = [[GetCDTASchedulesService alloc] initWithListener:self
                                                                                          routeId:[self.route.routeId intValue]
                                                                                      serviceType:@"Weekday"
                                                                             managedObjectContext:self.managedObjectContext];
    [schedulesService execute];
    
    slideUpTableView = [SlideUpTableView viewWithNibName:@"SlideUpTableView" owner:self];
    [slideUpTableView.tableView setDataSource:self];
    [slideUpTableView.tableView setDelegate:self];
    [slideUpTableView initialize];
    [slideUpTableView addTargetForCloseButton:self action:@selector(closePressed)];
    [slideUpTableView setHidden:YES parentFrame:self.view.frame animated:NO];
    
    [slideUpTableView.tableView setContentInset:UIEdgeInsetsMake(0,
                                                                 0,
                                                                 CGRectGetHeight(self.tabBarController.tabBar.frame)
                                                                 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
                                                                 + TOOLBAR_HEIGHT + VIEW_PADDING,
                                                                 0)];
    
    [self.view addSubview:slideUpTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];

    if ([service isMemberOfClass:[GetCDTASchedulesService class]]) {
        
        [slideUpTableView.tableView reloadData];
    }
    
//    [spinner stopAnimating];
    [self dismissProgressDialog];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                             target:self
                                                                                             action:@selector(showServiceTypes)]];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];

//    [spinner stopAnimating];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                             target:self
                                                                                             action:@selector(showServiceTypes)]];
}

#pragma mark - View controls

- (void)showServiceTypes
{
    [self setTitle:@"Service Types"];
    
    [slideUpTableView.tableView reloadData];
    
    [slideUpTableView setHidden:NO parentFrame:self.view.frame animated:YES];
}

#pragma mark - SlideUpTableView callbacks

- (void)closePressed
{
    [self setTitle:self.route.name];
    
    [slideUpTableView setHidden:YES parentFrame:self.view.frame animated:YES];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RouteSchedulesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
