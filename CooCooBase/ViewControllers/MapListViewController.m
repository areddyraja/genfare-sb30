//
//  MapListViewController.m
//  CooCooBase
//
//  Created by John Scuteri on 7/21/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "MapListViewController.h"
#import "MapImageViewController.h"
#import "MapInformationCell.h"
#import "Utilities.h"
#import "RuntimeData.h"
#import "ContentDescription.h"

@interface MapListViewController ()

@end

@implementation MapListViewController
{
    NSArray *content;
    UIActivityIndicatorView *spinner;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        //Set navigation bar stuff
        [spinner startAnimating];
        [self setTitle:[Utilities stringInfoForId:@"maps"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spinner]];
    
    //Core Data retrevial
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:CONTENT_DESCRIPTION_MODEL];
    NSError *error = nil;
    content = [self.managedObjectContext executeFetchRequest:request error:&error];

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return content.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MapInformationCell";
    MapInformationCell *cell = (MapInformationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    ContentDescription *contentDescription = [content objectAtIndex:(indexPath.row)];
    
    [cell.typeLabel setText:contentDescription.name];
    [cell.noteLabel setText:contentDescription.cDescription];
    [cell.noteLabel setNumberOfLines:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.listener onContentDescriptionSelected:[content objectAtIndex:indexPath.row]];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}



#pragma mark - Other methods

@end
