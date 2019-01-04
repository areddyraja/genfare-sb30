//
//  TripsViewController.m
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TripsViewController.h"
#import "CDTAAppConstants.h"
#import "SavedTrip.h"
#import "SavedTripCell.h"

@interface TripsViewController ()

@end

float const ROUTE_IMAGE_OFFSET_X = 73.0f;

// TODO: Needed?
@implementation TripsViewController
{
    UIBarButtonItem *newTripButton;
    NSArray *savedTrips;
    NSMutableArray *expandedCells;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Trips"];
        
        newTripButton = [[UIBarButtonItem alloc] initWithTitle:@"New Trip" style:UIBarButtonItemStylePlain target:self action:NULL];
        
        [self.navigationItem setRightBarButtonItem:newTripButton];
        
        SavedTrip *defaultTrip = [[SavedTrip alloc] init];
        [defaultTrip setDepartingStop:@"Albany International Airport"];
        [defaultTrip setArrivingStop:@"Washington Ave & Lark St"];
        [defaultTrip setDuration:@"36 min"];
        [defaultTrip setPrice:@"$3.00"];
        
        savedTrips = [[NSArray alloc] initWithObjects:defaultTrip, defaultTrip, defaultTrip, nil];
        
        expandedCells = [[NSMutableArray alloc] init];
        for (int i = 0; i < savedTrips.count; i++) {
            [expandedCells addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Saved Trips";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [savedTrips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SavedTripCell";
    SavedTripCell *cell = (SavedTripCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.detailsView = [[UIView alloc] init];
    }
    
    SavedTrip *savedTrip = [savedTrips objectAtIndex:indexPath.row];
    
    [cell.departLabel setText:savedTrip.departingStop];
    [cell.arriveLabel setText:savedTrip.arrivingStop];
    [cell.durationAndPriceLabel setText:[NSString stringWithFormat:@"Duration: %@ - %@", savedTrip.duration, savedTrip.price]];
    
    BOOL isExpanded = [[expandedCells objectAtIndex:indexPath.row] boolValue];
    [cell.detailsLabel setHidden:isExpanded];
    
    if (isExpanded) {
        cell.detailsView = [self createTripDetailsViewInRow:(int)indexPath.row
                                                    offsetX:cell.departLabel.frame.origin.x
                                                    offsetY:cell.detailsLabel.frame.origin.y];
        
        [cell addSubview:cell.detailsView];
    } else {
        if ([cell.subviews containsObject:cell.detailsView]) {
            [cell.detailsView removeFromSuperview];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SavedTripCell";
    SavedTripCell *cell = (SavedTripCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    BOOL isExpanded = [[expandedCells objectAtIndex:indexPath.row] boolValue];
    [expandedCells replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:!isExpanded]];

    [tableView reloadData];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 90.0f;
    
    static NSString *cellIdentifier = @"SavedTripCell";
    SavedTripCell *cell = (SavedTripCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if ([[expandedCells objectAtIndex:indexPath.row] boolValue]) {
        UIView *detailsView = [self createTripDetailsViewInRow:(int)indexPath.row
                                                       offsetX:0.0f
                                                       offsetY:0.0f];
        
        rowHeight = cell.frame.size.height + detailsView.frame.size.height - 16;
    } else {
        rowHeight = cell.frame.size.height;
    }
    
    return rowHeight;
}

- (UIView *)createTripDetailsViewInRow:(int)row offsetX:(float)offsetX offsetY:(float)offsetY
{
    UIView *detailsView = [[UIView alloc] init];
    
    UILabel *dateLabel = [self createDetailLabelWithText:@"October 1, 2013 departing at 3:30PM"];
    [dateLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    [dateLabel setFrame:CGRectMake(offsetX,
                                     offsetY,
                                     self.tableView.frame.size.width - offsetX - VIEW_PADDING,
                                     dateLabel.frame.size.height)];
    
    [detailsView addSubview:dateLabel];
    
    UIImage *startImage = [UIImage imageNamed:@"route_start"];
    UIImageView *startImageView = [[UIImageView alloc] initWithImage:startImage];
    
    [startImageView setFrame:CGRectMake(ROUTE_IMAGE_OFFSET_X,
                                        dateLabel.frame.origin.y + dateLabel.frame.size.height + (VIEW_PADDING * 2),
                                        startImage.size.width,
                                        startImage.size.height)];
    
    [detailsView addSubview:startImageView];
    
    UILabel *startLabel = [self createDetailLabelWithText:@"Albany International Airport"];
    [startLabel setFrame:CGRectMake(startImageView.frame.origin.x + startImageView.frame.size.width + VIEW_PADDING,
                                    startImageView.frame.origin.y + (startImageView.frame.size.height / 2) - (startLabel.frame.size.height / 2),
                                    startLabel.frame.size.width,
                                    startLabel.frame.size.height)];
    
    [detailsView addSubview:startLabel];
    
    UIImage *route1Image = [UIImage imageNamed:@"route_117"];
    UIImageView *route1ImageView = [[UIImageView alloc] initWithImage:route1Image];
    
    [route1ImageView setFrame:CGRectMake(ROUTE_IMAGE_OFFSET_X,
                                         startImageView.frame.origin.y + startImageView.frame.size.height + VIEW_PADDING,
                                         route1Image.size.width,
                                         route1Image.size.height)];
    
    [detailsView addSubview:route1ImageView];
    
    UILabel *time1Label = [self createDetailLabelWithText:@"3:40PM"];
    [time1Label setFrame:CGRectMake(offsetX,
                                    route1ImageView.frame.origin.y + (route1Image.size.height / 2) - (time1Label.frame.size.height / 2),
                                    ROUTE_IMAGE_OFFSET_X - offsetX,
                                    time1Label.frame.size.height)];
    
    [detailsView addSubview:time1Label];
    
    UILabel *route1Label = [self createDetailLabelWithText:@"Guilderland/Colonie\nCrosstown - (South)Colonie"];
    [route1Label setFrame:CGRectMake(startLabel.frame.origin.x,
                                     route1ImageView.frame.origin.y + (route1ImageView.frame.size.height / 2) - (route1Label.frame.size.height / 2),
                                     self.tableView.frame.size.width - ROUTE_IMAGE_OFFSET_X - 32,
                                     route1Label.frame.size.height)];
    
    [detailsView addSubview:route1Label];
    
    UIImage *transferImage = [UIImage imageNamed:@"route_transfer"];
    UIImageView *transferImageView = [[UIImageView alloc] initWithImage:transferImage];
    
    [transferImageView setFrame:CGRectMake(ROUTE_IMAGE_OFFSET_X,
                                           route1ImageView.frame.origin.y + route1ImageView.frame.size.height + VIEW_PADDING,
                                           transferImage.size.width,
                                           transferImage.size.height)];
    
    [detailsView addSubview:transferImageView];
    
    UILabel *timeTransferLabel = [self createDetailLabelWithText:@"3:53PM"];
    [timeTransferLabel setFrame:CGRectMake(offsetX,
                                           transferImageView.frame.origin.y + (transferImage.size.height / 2) - (timeTransferLabel.frame.size.height / 2),
                                           ROUTE_IMAGE_OFFSET_X - offsetX,
                                           timeTransferLabel.frame.size.height)];
    
    [detailsView addSubview:timeTransferLabel];
    
    UILabel *transferLabel = [self createDetailLabelWithText:@"Exit: Central Ave & Northway Mall"];
    [transferLabel setFrame:CGRectMake(transferImageView.frame.origin.x + transferImageView.frame.size.width + VIEW_PADDING,
                                       transferImageView.frame.origin.y + (transferImageView.frame.size.height / 2) - (transferLabel.frame.size.height / 2),
                                       transferLabel.frame.size.width,
                                       transferLabel.frame.size.height)];
    
    [detailsView addSubview:transferLabel];
    
    UIImage *route2Image = [UIImage imageNamed:@"route_1"];
    UIImageView *route2ImageView = [[UIImageView alloc] initWithImage:route2Image];
    
    [route2ImageView setFrame:CGRectMake(ROUTE_IMAGE_OFFSET_X,
                                         transferImageView.frame.origin.y + transferImageView.frame.size.height + VIEW_PADDING,
                                         route2Image.size.width,
                                         route2Image.size.height)];
    
    [detailsView addSubview:route2ImageView];
    
    UILabel *time2Label = [self createDetailLabelWithText:@"3:55PM"];
    [time2Label setFrame:CGRectMake(offsetX,
                                    route2ImageView.frame.origin.y + (route2Image.size.height / 2) - (time2Label.frame.size.height / 2),
                                    ROUTE_IMAGE_OFFSET_X - offsetX,
                                    time2Label.frame.size.height)];
    
    [detailsView addSubview:time2Label];
    
    UILabel *route2Label = [self createDetailLabelWithText:@"Central Avenue - East"];
    [route2Label setFrame:CGRectMake(route2ImageView.frame.origin.x + route2ImageView.frame.size.width + VIEW_PADDING,
                                     route2ImageView.frame.origin.y + (route2ImageView.frame.size.height / 2) - (route2Label.frame.size.height / 2),
                                     route2Label.frame.size.width,
                                     route2Label.frame.size.height)];
    
    [detailsView addSubview:route2Label];
    
    UIImage *endImage = [UIImage imageNamed:@"route_end"];
    UIImageView *endImageView = [[UIImageView alloc] initWithImage:endImage];
    
    [endImageView setFrame:CGRectMake(ROUTE_IMAGE_OFFSET_X,
                                      route2ImageView.frame.origin.y + route2ImageView.frame.size.height + VIEW_PADDING,
                                      endImage.size.width,
                                      endImage.size.height)];
    
    [detailsView addSubview:endImageView];
    
    UILabel *timeEndLabel = [self createDetailLabelWithText:@"4:15PM"];
    [timeEndLabel setFrame:CGRectMake(offsetX,
                                      endImageView.frame.origin.y + (endImage.size.height / 2) - (timeEndLabel.frame.size.height / 2),
                                      ROUTE_IMAGE_OFFSET_X - offsetX,
                                      timeEndLabel.frame.size.height)];
    
    [detailsView addSubview:timeEndLabel];
    
    UILabel *endLabel = [self createDetailLabelWithText:@"Exit: Washington Ave & Lark St"];
    [endLabel setFrame:CGRectMake(endImageView.frame.origin.x + endImageView.frame.size.width + VIEW_PADDING,
                                  endImageView.frame.origin.y + (endImageView.frame.size.height / 2) - (endLabel.frame.size.height / 2),
                                  endLabel.frame.size.width,
                                  endLabel.frame.size.height)];
    
    [detailsView addSubview:endLabel];
    
    [detailsView setFrame:CGRectMake(0,
                                     0,
                                     self.tableView.frame.size.width,
                                     endLabel.frame.origin.y + endLabel.frame.size.height)];
    
    return detailsView;
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

@end
