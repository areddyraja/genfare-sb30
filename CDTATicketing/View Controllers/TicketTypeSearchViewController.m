//
//  TicketTypeSearchViewController.m
//  CDTATicketing
//
//  Created by CooCooTech on 8/26/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "TicketTypeSearchViewController.h"
#import "GetStoredValueProductsService.h"

@interface TicketTypeSearchViewController ()

@end

@implementation TicketTypeSearchViewController
{
//    UIActivityIndicatorView *spinner;
    UIAlertView *syncAlertView;
    NSMutableArray *storedValueProducts;
    UILabel *emptyLabel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"search_ticket_types"]];
        
//        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        storedValueProducts = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Show cached products
    [self loadTableData];
    
    if ([storedValueProducts count] > 0) {
//        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
//        [spinner startAnimating];
        [self showProgressDialog];
        
        [self.tableView reloadData];
    } else {
        syncAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"loading_products_title"]
                                                   message:[Utilities stringResourceForId:@"loading_tickets_msg"]
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                         otherButtonTitles:nil];
        [syncAlertView show];
    }
    
    // Always check for new products
    GetStoredValueProductsService *getStoredValueProductsService = [[GetStoredValueProductsService alloc] initWithListener:self
                                                                                                      managedObjectContext:self.managedObjectContext cardId:self.cardId];
    [getStoredValueProductsService execute];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (syncAlertView) {
        [syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        syncAlertView = nil;
    }else{
        [self dismissProgressDialog];
    }
//    else if (spinner) {
//        [spinner stopAnimating];
//
//        spinner = nil;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self loadTableData];
    
    if ([storedValueProducts count] > 0) {
        [self.tableView reloadData];
    } else {
        if (!emptyLabel) {
            // Should only ever happen if there is a server request error on the very first load of this View Controller
            CGRect applicationFrame = [[UIScreen mainScreen] bounds];
            
            emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width - 20, 0)];
            [emptyLabel setText:[Utilities stringResourceForId:@"no_products"]];
            [emptyLabel setTextAlignment:NSTextAlignmentCenter];
            [emptyLabel setFont:[UIFont systemFontOfSize:16]];
            [emptyLabel setNumberOfLines:0];
            [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [emptyLabel sizeToFit];
            [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                              (applicationFrame.size.height / 2) - (emptyLabel.frame.size.height/2 + HELP_SLIDER_HEIGHT))];
            
            [emptyLabel setHidden:NO];
            
            [self.view addSubview:emptyLabel];
        }
    }
    
    if (syncAlertView) {
        [syncAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        syncAlertView = nil;
    }else{
    }
//    else if (spinner) {
//        [spinner stopAnimating];
//
//        spinner = nil;
//    }
    [self dismissProgressDialog];


}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];

    [self threadSuccessWithClass:service response:response];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [storedValueProducts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TicketTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        [cell.detailTextLabel setNumberOfLines:0];
    }
    
    StoredValueProduct *product = [storedValueProducts objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ - $%.2f/ride", product.name, [product.amount floatValue]]];
    [cell.detailTextLabel setText:product.productDescription];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.listener onTicketTypeSelected:[storedValueProducts objectAtIndex:indexPath.row]];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

#pragma mark - Other methods

- (void)loadTableData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_PRODUCT_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    storedValueProducts = [[NSMutableArray alloc] initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
}

@end
