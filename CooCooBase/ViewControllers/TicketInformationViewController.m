//
//  TicketInformationViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TicketInformationViewController.h"
#import "AppConstants.h"
#import "BaseService.h"
#import "BorderedButton.h"
#import "CardEvent.h"
#import "RuntimeData.h"
#import "TicketEvent.h"
#import "TicketPageViewController.h"
#import "UIColor+HexString.h"
#import "Utilities.h"
#import "StationInfo.h"
#import "TicketActivation.h"
int const TAG_PAGE_LABEL = 1;
float const LABEL_HEIGHT = 30;
float const LABEL_TITLE_OFFSET_X = 10;
float const LABEL_OFFSET_X = 30;
float const LABEL_OFFSET_Y = 60;



@interface TicketInformationViewController ()

@end

@implementation TicketInformationViewController
{
    UIScrollView *infoScrollView;
    NSDateFormatter *fullDateFormatter;
}

- (id)init
{
    if (self = [super init]) {
        fullDateFormatter = [[NSDateFormatter alloc] init];
        [fullDateFormatter setDateFormat:@"MM/dd/yy - hh:mma"];
        
        [self setPageIndex:2];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height - STATUS_BAR_HEIGHT;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            self.view.frame.size.width,
                                                            screenHeight)];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    self.view = view;
    
//    UIView *pageLabel = [TicketPageViewController pageLabelWithTitle:[Utilities stringResourceForId:@"information"] frameWidth:self.view.frame.size.width];
//    [pageLabel setTag:TAG_PAGE_LABEL];
//
//    [self.view addSubview:pageLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setInformationDisplay];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Information" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRODUCT_MODEL  inManagedObjectContext: self.managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ticketId == %@)",self.walletContent.ticketIdentifier]];
    NSError * error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetch error:&error];
    if(fetchedObjects.count>0){
        self.product=fetchedObjects.firstObject;
        NSLog(@"product id %@",self.product);
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setInformationDisplay
{
    // Allow lookup of ticket in case _ticket is nullified by a background service
    //Ticket *threadSafeTicket = [self threadSafeTicket];
    
    Ticket *currentTicket = [Utilities currentTicket:self.managedObjectContext];
    
    NSArray *subviews = [self.view subviews];
    for (UIView *subview in subviews) {
        if (subview.tag != TAG_PAGE_LABEL) {
            [subview removeFromSuperview];
        }
    }
    
    infoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                    50.0,
                                                                    self.view.frame.size.width,
                                                                    self.view.frame.size.height - PAGER_STRIP_HEIGHT - 55)];
    
    [infoScrollView setScrollEnabled:YES];
    [infoScrollView setShowsVerticalScrollIndicator:YES];
    [infoScrollView setUserInteractionEnabled:YES];
    
    CGRect detailsRect;
    
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[[currentTicket fullName] stringByTrimmingCharactersInSet: set] length] == 0) {
        //        UILabel *nameTitle = [self createLabelTitle:[Utilities stringResourceForId:@"name"]];
        UILabel *nameTitle = [self createLabelTitle:[Utilities stringResourceForId:@"name"]];
        [nameTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X, 0, infoScrollView.frame.size.width, LABEL_HEIGHT)];
        [infoScrollView addSubview:nameTitle];
        
        UILabel *nameLabel = [self createLabel:self.walletContent.descriptation];
        [nameLabel setFrame:CGRectMake(LABEL_OFFSET_X, nameTitle.frame.origin.y + nameTitle.frame.size.height, infoScrollView.frame.size.width, nameLabel.frame.size.height)];
        [infoScrollView addSubview:nameLabel];
        detailsRect = CGRectMake(LABEL_TITLE_OFFSET_X, nameLabel.frame.origin.y + nameLabel.frame.size.height, infoScrollView.frame.size.width, LABEL_HEIGHT);
    } else {
        detailsRect = CGRectMake(LABEL_TITLE_OFFSET_X, 0, infoScrollView.frame.size.width, LABEL_HEIGHT);
    }
    
    
    UILabel *detailsTitle = [self createLabelTitle:[Utilities stringResourceForId:@"ticket_heading"]];
    [detailsTitle setFrame:detailsRect];
    [infoScrollView addSubview:detailsTitle];
    
    NSString *originDestinationLabel = @"";
    if (currentTicket.arrivalStation != nil) {
        NSString *departing = @"";
        NSString *arriving = @"";
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:STATION_INFO_MODEL inManagedObjectContext:self.managedObjectContext]];
        NSError *error = nil;
        NSArray *station;
        NSPredicate *predicate;
        StationInfo *departingStation;
        StationInfo *arrivingStation;
        
        predicate = [NSPredicate predicateWithFormat:@"stationId == %@", currentTicket.departureStation];
        [fetchRequest setPredicate:predicate];
        error = nil;
        station = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (station.count > 0) {
            departingStation = station[0];
            if (departingStation.displayName) {
                departing = departingStation.displayName;
            } else {
                departing = departingStation.name;
            }
        }
        
        predicate = [NSPredicate predicateWithFormat:@"stationId == %@", currentTicket.arrivalStation];
        [fetchRequest setPredicate:predicate];
        error = nil;
        station = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (station.count > 0) {
            arrivingStation = station[0];
            if (arrivingStation.displayName) {
                arriving = arrivingStation.displayName;
            } else {
                arriving = arrivingStation.name;
            }
        }
        
        if ((departingStation != nil) && (arrivingStation != nil)) {
            originDestinationLabel = [NSString stringWithFormat:@"\nFrom: %@\nTo: %@", departing, arriving];
        }
    }
    
    originDestinationLabel = [NSString stringWithFormat:@"%@%@",[currentTicket stackedLabel],originDestinationLabel];
    
    //    UILabel *detailsLabel = [self createLabel:self.walletContent.ticketIdentifier];
    NSString * type;
    if([self.walletContent.type isEqualToString:@"1"] || [self.walletContent.type isEqualToString:@"Single ride"]){
        type = @"Single ride";
    }else{
        NSString *typeString = [self.walletContent.type stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        type = [Utilities capitalizedOnlyFirstLetter:typeString];
    }
    UILabel *detailsLabel = [self createLabel:[NSString stringWithFormat:@"%@\n%@\n%Total Fare: $ %.2f",type,self.walletContent.ticketIdentifier,self.walletContent.fare.floatValue]];
    [detailsLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                      detailsTitle.frame.origin.y + detailsTitle.frame.size.height,
                                      infoScrollView.frame.size.width,
                                      detailsLabel.frame.size.height)];
    [infoScrollView addSubview:detailsLabel];
    
    UILabel *idTitle = [self createLabelTitle:[Utilities stringResourceForId:@"ticket_id"]];
    [idTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X, detailsLabel.frame.origin.y + detailsLabel.frame.size.height, infoScrollView.frame.size.width, LABEL_HEIGHT)];
    [infoScrollView addSubview:idTitle];
    
    UILabel *idLabel = [self createLabelTitle:self.walletContent.ticketIdentifier];
    
    [idLabel setFrame:CGRectMake(LABEL_OFFSET_X, idTitle.frame.origin.y + idTitle.frame.size.height, infoScrollView.frame.size.width, idTitle.frame.size.height)];
    [infoScrollView addSubview:idLabel];
    
    CGRect previousRect = idLabel.frame;
    
    if ((currentTicket.invoiceId != nil) && (currentTicket.invoiceId.length > 0))//Check to see if it matches the text "InvoiceId"
    {
        
        
        UILabel *invoiceTitle = [self createLabelTitle:[Utilities stringResourceForId:@"invoice"]];
        [invoiceTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X, previousRect.origin.y + previousRect.size.height, infoScrollView.frame.size.width, LABEL_HEIGHT)];
        [infoScrollView addSubview:invoiceTitle];
        
        UILabel *invoiceLabel = [self createLabel:currentTicket.invoiceId];
        [invoiceLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                          invoiceTitle.frame.origin.y + invoiceTitle.frame.size.height,
                                          infoScrollView.frame.size.width,
                                          invoiceLabel.frame.size.height)];
        [infoScrollView addSubview:invoiceLabel];
        previousRect = invoiceLabel.frame;
    }
    if ((currentTicket.creditCard != nil) && (currentTicket.creditCard.length > 0))//Check to see if it matches "CC"
    {
        UILabel *creditCardTitle = [self createLabelTitle:[Utilities stringResourceForId:@"credit_card"]];
        [creditCardTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X,
                                             previousRect.origin.y + previousRect.size.height,
                                             infoScrollView.frame.size.width,
                                             LABEL_HEIGHT)];
        [infoScrollView addSubview:creditCardTitle];
        
        UILabel *creditCardLabel = [self createLabel:[NSString stringWithFormat:@"%@%@",
                                                      [Utilities stringResourceForId:@"credit_card_mask"],
                                                      currentTicket.creditCard]];
        [creditCardLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                             creditCardTitle.frame.origin.y + creditCardTitle.frame.size.height,
                                             infoScrollView.frame.size.width,
                                             creditCardLabel.frame.size.height)];
        [infoScrollView addSubview:creditCardLabel];
        previousRect = creditCardLabel.frame;
    }
    
    //    UILabel *statusTitle = [self createLabelTitle:[Utilities stringResourceForId:@"status"]];
    //    UILabel *statusTitle = [self createLabel:[NSString stringWithFormat:@"%@\n%@",
    //                       [Utilities stringResourceForId:@"status"],
    //                                              self.walletContent.status]];
    UILabel *statusTitle = [self createLabelTitle:[Utilities stringResourceForId:@"status"]];
    [statusTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X,
                                     previousRect.origin.y + previousRect.size.height,
                                     infoScrollView.frame.size.width,
                                     LABEL_HEIGHT)];
    [infoScrollView addSubview:statusTitle];
    //    [statusTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X,
    //                                     previousRect.origin.y + previousRect.size.height,
    //                                     infoScrollView.frame.size.width,
    //                                     LABEL_HEIGHT + 30)];
    //    [infoScrollView addSubview:statusTitle];
    // Get the earliest activation date with which to calculate a proper expiration date
    //NSDate *firstActivationDate = nil;
    
    NSArray *fetchedObjects;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:Activation_Model  inManagedObjectContext: context];
    [fetch setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticketIdentifier == %@",self.walletContent.ticketIdentifier];
    [fetch setPredicate:predicate];
    NSError * error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    NSLog(@"%@",fetchedObjects);
    if(!fetchedObjects){
        //  NSArray *ticketEvents = [[RuntimeData instance] ticketEvents];
        NSMutableArray *activationEventsTemp = [[NSMutableArray alloc] init];
        
        for (TicketActivation *ticketEvent in fetchedObjects) {
            if (ticketEvent.activationDate >0) {
                [activationEventsTemp addObject:ticketEvent];
            }
        }
        
        // Sort from oldest event to newest
        NSArray *activationEvents = [[activationEventsTemp reverseObjectEnumerator] allObjects];
        NSUInteger eventsCount = [activationEvents count];
        
        UILabel *lastStatusLabel = statusTitle;
        
        if (self.walletContent.purchasedDate >0) {
            NSUInteger limit = eventsCount;
            
            
            for (int i = 0; i < activationEvents.count; i++) {
                UILabel *statusLabel = nil;
                
                if (i < eventsCount) {
                    TicketActivation *ticketEvent = [activationEvents objectAtIndex:i];
                    
                    
                    NSDateFormatter *df=[[NSDateFormatter alloc] init];
                    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                    //                NSDate *activationDate = [NSDate dateWithTimeIntervalSince1970:ticketEvent.activationDate];
                    //
                    //                NSDate *inactiveDate = [NSDate dateWithTimeIntervalSince1970:ticketEvent.eventDateTime
                    //                                        + ([currentTicket.activationLiveTime intValue] * SECONDS_PER_MINUTE)];
                    
                    
                    
                    //
                    NSString *inactiveString = @"";
                    
                    //   if ([[NSDate date] compare:inactiveDate] == NSOrderedAscending) {
                    inactiveString = [Utilities stringResourceForId:@"deactivates_on"];
                    //  } else {
                    //      inactiveString = [Utilities stringResourceForId:@"deactivated_on"];
                    //   }
                    
                    
                    //                NSString *statusText = [NSString stringWithFormat:@"Trip %d\nActivated On: %@\n%@: %@",
                    //                                        i + 1,
                    //                                        ticketEvent.activationDate,
                    //                                        inactiveString,
                    //                                        ticketEvent.activationExpDate];
                    
                    //                NSString *statusText = [NSString stringWithFormat:@"Trip %d\nActivated On: %@\n%@: %@",
                    //                                        i + 1,
                    //                                        [fullDateFormatter stringFromDate:ticketEvent.activationDate],
                    //                                        inactiveString,
                    //                                        [fullDateFormatter stringFromDate:[self.product.barcodeTimer intValue]]];
                    //                [NSNumber numberWithDouble:epochSeconds+[self.product.barcodeTimer intValue]]
                    NSString *statusText = [self.walletContent status];
                    
                    statusLabel = [self createLabel:statusText];
                } else {
                    statusLabel = [self createLabel:[NSString stringWithFormat:@"Trip %d\nPending Activation", i + 1]];
                }
                
                [statusLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                                 lastStatusLabel.frame.origin.y + lastStatusLabel.frame.size.height,
                                                 infoScrollView.frame.size.width,
                                                 statusLabel.frame.size.height)];
                [infoScrollView addSubview:statusLabel];
                
                
                statusLabel.text = self.walletContent.status;
                lastStatusLabel = statusLabel;
            }
        } else {
            // TODO: Store local activation events; use original code here for now
            UILabel *statusLabel = nil;
            
            // An inactive ticket has a default activation date of 01/01/2000 00:00 GMT sent from server
            if ([currentTicket.activationDateTime intValue] > DEFAULT_ACTIVATION_TIMESTAMP) {
                NSDate *activationDate = [NSDate dateWithTimeIntervalSince1970:[currentTicket.activationDateTime doubleValue]];
                
                NSDate *inactiveDate = [NSDate dateWithTimeIntervalSince1970:([currentTicket.activationDateTime doubleValue]
                                                                              + ([currentTicket.activationLiveTime intValue] * SECONDS_PER_MINUTE))];
                
                NSString *inactiveString = @"";
                
                if ([[NSDate date] compare:inactiveDate] == NSOrderedAscending) {
                    inactiveString = [Utilities stringResourceForId:@"deactivates_on"];
                } else {
                    inactiveString = [Utilities stringResourceForId:@"deactivated_on"];
                }
                
                NSString *statusText = [NSString stringWithFormat:@"Activated On: %@\n%@: %@",
                                        [fullDateFormatter stringFromDate:activationDate],
                                        inactiveString,
                                        [fullDateFormatter stringFromDate:inactiveDate]];
                
                statusLabel = [self createLabel:statusText];
            } else {
                statusLabel = [self createLabel:self.walletContent.status];
            }
            
            [statusLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                             statusTitle.frame.origin.y + statusTitle.frame.size.height,
                                             infoScrollView.frame.size.width,
                                             statusLabel.frame.size.height)];
            [infoScrollView addSubview:statusLabel];
            //  statusLabel.text = self.walletContent.status;
            //  lastStatusLabel = statusLabel;
        }
    }
    UILabel *statusLabel = [self createLabel:self.walletContent.status];
    
    [statusLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                     statusTitle.frame.origin.y + statusTitle.frame.size.height,
                                     infoScrollView.frame.size.width,
                                     statusLabel.frame.size.height)];
    [infoScrollView addSubview:statusLabel];
    UILabel *lastStatusLabel = statusLabel;
    UILabel *soldOnTitle = [self createLabelTitle:[Utilities stringResourceForId:@"sold_on"]];
    [soldOnTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X,
                                     lastStatusLabel.frame.origin.y + lastStatusLabel.frame.size.height,
                                     infoScrollView.frame.size.width,
                                     LABEL_HEIGHT)];
    [infoScrollView addSubview:soldOnTitle];
    
    // NSDate *purchaseDate = [NSDate dateWithTimeIntervalSince1970:[currentTicket.purchaseDateTime doubleValue]];
    NSDate *purchaseDate = [NSDate dateWithTimeIntervalSince1970:[self.walletContent.purchasedDate doubleValue]/1000];
    UILabel *soldOnLabel = [self createLabel:[fullDateFormatter stringFromDate:purchaseDate]];
    [soldOnLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                     soldOnTitle.frame.origin.y + soldOnTitle.frame.size.height,
                                     infoScrollView.frame.size.width,
                                     soldOnLabel.frame.size.height)];
    [infoScrollView addSubview:soldOnLabel];
    
    UILabel *validFromTitle = [self createLabelTitle:[Utilities stringResourceForId:@"valid_from"]];
    [validFromTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X,
                                        soldOnLabel.frame.origin.y + soldOnLabel.frame.size.height,
                                        infoScrollView.frame.size.width,
                                        LABEL_HEIGHT)];
    [infoScrollView addSubview:validFromTitle];
    
    UILabel *validFromLabel = [self createLabel:[fullDateFormatter stringFromDate:purchaseDate]];
    [validFromLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                        validFromTitle.frame.origin.y + validFromTitle.frame.size.height,
                                        infoScrollView.frame.size.width,
                                        validFromLabel.frame.size.height)];
    [infoScrollView addSubview:validFromLabel];
    
    UILabel *expiresOnTitle = [self createLabelTitle:[Utilities stringResourceForId:@"expires_on"]];
    [expiresOnTitle setFrame:CGRectMake(LABEL_TITLE_OFFSET_X,
                                        validFromLabel.frame.origin.y + validFromLabel.frame.size.height,
                                        infoScrollView.frame.size.width,
                                        LABEL_HEIGHT)];
    [infoScrollView addSubview:expiresOnTitle];
    
    UILabel *expiresOnLabel = [self createLabel:[fullDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.walletContent.ticketActivationExpiryDate.longLongValue]]];
    [expiresOnLabel setFrame:CGRectMake(LABEL_OFFSET_X,
                                        expiresOnTitle.frame.origin.y + expiresOnTitle.frame.size.height,
                                        infoScrollView.frame.size.width,
                                        expiresOnLabel.frame.size.height)];
    [infoScrollView addSubview:expiresOnLabel];
    
    [infoScrollView setContentSize:CGSizeMake(self.view.frame.size.width,
                                              expiresOnLabel.frame.origin.y + expiresOnLabel.frame.size.height + 3)];
    
    [self.view addSubview:infoScrollView];
}

#pragma mark - Other methods

- (UILabel *)createLabelTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [label setTextColor:[UIColor blackColor]];
    [label setText:title];
    
    return label;
}

- (UILabel *)createLabel:(NSString *)content
{
    UILabel *label = [[UILabel alloc] init];
    [label setFont:[UIFont systemFontOfSize:16.0f]];
    [label setTextColor:[UIColor blackColor]];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setText:content];
    [label sizeToFit];
    
    return label;
}

@end

