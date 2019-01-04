//
//  TicketPageViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 4/13/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "TicketPageViewController.h"
#import "AppConstants.h"
#import "BasePageViewController.h"
#import "CardEvent.h"
#import "CardEventContent.h"
#import "CardSyncService.h"
#import "CustomerRequestService.h"
#import "EncryptionSet.h"
#import "GetTicketEventsService.h"
#import "RuntimeData.h"
#import "ServiceDay.h"
#import "StoredData.h"
#import "TicketBarcodeViewController.h"
#import "TicketInformationViewController.h"
#import "TicketSecurityViewController.h"
#import "TicketSyncService.h"
#import "UIColor+HexString.h"
#import "Utilities.h"
#import "Product.h"
#import "EncryptionKey.h"
#import "GetWalletContentUsage.h"


NSString *const POP_NOTIFICATION_NAME = @"popFromChildPage";
NSString *const MOVE_PAGE = @"MOVE_PAGE";

int const PAGE_COUNT = 3;
int const ACTIVATE_ALERT_TAG = 1;
int const REQUEST_ALERT_TAG = 2;
int const TOKEN_ALERT_TAG = 3;
int const ACTIVATION_MAX_ALERT_TAG = 4;
int const ACTIVATE_TIME_ALERT_TAG = 5;
int const RESET_TIME_ALERT_TAG = 6;
int const NO_ENCRYPTION_TAG = 7;
int const ANOTHER_ACTIVE_TICKET_TAG = 8;
int const STORED_VALUE_TAG = 9;
int const OUT_OF_SERVICE_DAY_TAG = 10;
int const TICKET_PADDING = 25;
int const TICKET_VIEW_PADDING = 5;

float const TICKET_CORNER_RADIUS = 15.0f;

@interface TicketPageViewController () <UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *pageViewTitle;
@property (weak, nonatomic) IBOutlet UIButton *informationBtn;
@property (weak, nonatomic) IBOutlet UIButton *barcodeBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomIndicatorView;

@end

@implementation TicketPageViewController
{
    CGRect applicationFrame;
    NSArray *viewControllers;
    TicketInformationViewController *informationView;
    BOOL pageControlBeingUsed;
    NSString *serviceRequestComment;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    UIAlertView *singleAlertView;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"my_ticket"]];
        
        locationManager = [[CLLocationManager alloc] init];
        currentLocation = [[CLLocation alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleEnterForeground:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(popPagerViewController:)
                                                     name:POP_NOTIFICATION_NAME
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movePage:)
                                                     name:MOVE_PAGE
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    applicationFrame = [[UIScreen mainScreen] bounds];
    
    Ticket *currentTicket = [Utilities currentTicket:self.managedObjectContext];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    
    if (self.createCustomBarcodeViewController) {
        BasePageViewController *barcodeViewController = self.createCustomBarcodeViewController();
        [barcodeViewController setPageIndex:0];
        [barcodeViewController setManagedObjectContext:self.managedObjectContext];
        [barcodeViewController setProduct:self.product];
        [barcodeViewController setWalletContent:self.walletContent];

        [controllers addObject:barcodeViewController];
    } else {
        TicketBarcodeViewController *barcodeViewController = [[TicketBarcodeViewController alloc] initWithNibName:@"TicketBarcodeViewController" bundle:nil];
        [barcodeViewController setPageIndex:0];
        [barcodeViewController setManagedObjectContext:self.managedObjectContext];
        [barcodeViewController setWalletContent:self.walletContent];
        [barcodeViewController setProduct:self.product];
        if ([self.cardAccountId length] > 0) {
            [barcodeViewController setCardAccountId:self.cardAccountId];
        }
        
        [controllers addObject:barcodeViewController];
    }
    
    if (self.createCustomSecurityViewController) {
        BasePageViewController *securityViewController = self.createCustomSecurityViewController();
//        [securityViewController setPageIndex:1];
//        [securityViewController setManagedObjectContext:self.managedObjectContext];
        
       // [controllers addObject:securityViewController];
    } else {
//        TicketSecurityViewController *securityViewController = [[TicketSecurityViewController alloc] init];
//        [securityViewController setTicketSourceId:self.ticketSourceId];
//        [securityViewController setPageIndex:1];
//        [securityViewController setManagedObjectContext:self.managedObjectContext];
        
        //[controllers addObject:securityViewController];
    }
    
    informationView = [[TicketInformationViewController alloc] init];
    [informationView setPageIndex:1];
    [informationView setManagedObjectContext:self.managedObjectContext];
     [informationView setWalletContent:self.walletContent];
    [informationView setProduct:self.product];
    [controllers addObject:informationView];
    
    viewControllers = [[NSArray alloc] initWithArray:[controllers copy]];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    [self.pageViewController setDataSource:self];
    [self.pageViewController setDelegate:self];
    [self.pageViewController.view setFrame:[self.view bounds]];
    
    if ([currentTicket.type isEqualToString:ACTIVE]) {
        if ([Utilities featuresFromId:@"barcode_after_ticket_activation"]) {
            [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        } else {
            [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }
        
    } else if ([currentTicket.type isEqualToString:HISTORY]) {
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
    } else {
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    
    [self addChildViewController:self.pageViewController];
    
    [self.view addSubview:[self.pageViewController view]];
    
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.view bringSubviewToFront:self.pageViewTitle];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Pager" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager startUpdatingLocation];
    
    // Show results of GetTicketEventsService in TicketInformationViewController
//    GetTicketEventsService *getTicketEventsService = [[GetTicketEventsService alloc] initWithListener:self
//                                                                                        ticketGroupId:currentTicket.ticketGroupId
//                                                                                             memberId:currentTicket.memberId];
//    [getTicketEventsService execute];
}

// Disable iOS7+ swipe back gesture
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.interactivePopGestureRecognizer setDelegate:self];
        [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self.navigationController.interactivePopGestureRecognizer]) {
        return NO;
    } else {
        return YES;
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    UIViewController *previous = previousViewControllers.firstObject;
    if ([previous isKindOfClass:[TicketBarcodeViewController class]]) {
        [self animateToButton:self.informationBtn];
    }else{
        [self animateToButton:self.barcodeBtn];
    }
}

// End Disable iOS7+ swipe back gesture

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [singleAlertView dismissWithClickedButtonIndex:singleAlertView.cancelButtonIndex animated:YES];
    
    // Enable iOS7+ swipe back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
        [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    }
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View controls

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Ticket *currentTicket = [Utilities currentTicket:self.managedObjectContext];
    
    if (alertView.tag == ACTIVATE_ALERT_TAG) {
        if (buttonIndex == 1) {
            NSDate *now = [NSDate date];
            
            // Update ticket information locally until phone syncs up with GetTicketsService
            [currentTicket setType:ACTIVE];
            [currentTicket setStatus:STATUS_ACTIVATED];
            [currentTicket setActivationType:ACTIVATION_TYPE];
            
            NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
            NSInteger epochSeconds = [[NSNumber numberWithDouble:epochSecondsDecimals] integerValue];
            [currentTicket setActivationDateTime:[NSNumber numberWithInteger:epochSeconds]];
            [currentTicket setActivatedSeconds:[NSNumber numberWithInteger:epochSeconds]];
            [currentTicket setLastUpdated:[NSNumber numberWithInteger:epochSeconds]];
            
            [currentTicket setEventType:EVENT_TYPE_ACTIVATE];
            [currentTicket setActivationCount:[NSNumber numberWithInt:[currentTicket.activationCount intValue] + 1]];
            
            [currentTicket setEventLat:[NSNumber numberWithDouble:currentLocation.coordinate.latitude]];
            [currentTicket setEventLng:[NSNumber numberWithDouble:currentLocation.coordinate.longitude]];
            
            // Save updated ticket
            NSError *saveError;
            if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&saveError]) {
                NSLog(@"TicketPagerViewController Error, couldn't save: %@", [saveError localizedDescription]);
            }
            
            // Add ticket to Ticket Event Queue
            /*NSMutableArray *ticketsQueue = [StoredData ticketsQueue];
            
            if ([ticketsQueue indexOfObject:threadSafeTicket.id] == NSNotFound) {
                [ticketsQueue addObject:threadSafeTicket.id];
            }
            
            [StoredData commitTicketsQueueWithList:ticketsQueue];*/
            
            CardEvent *activationEvent = (CardEvent *)[NSEntityDescription insertNewObjectForEntityForName:CARD_EVENT_MODEL inManagedObjectContext:self.managedObjectContext];
            
            [activationEvent setOccurredOnDateTime:now];
            [activationEvent setType:CARD_EVENT_TYPE_ACTIVATE];
            [activationEvent setDetail:@"Activation"];
            
            CardEventContent *cardEventContent = [[CardEventContent alloc] init];
            
            [cardEventContent setTicketGroupId:currentTicket.ticketGroupId];
            [cardEventContent setMemberId:currentTicket.memberId];
            [cardEventContent setBornOnDateTime:[NSDate dateWithTimeIntervalSince1970:[currentTicket.purchaseDateTime doubleValue]]];
            
            CardEventFare *cardEventFare = [[CardEventFare alloc] init];
            
            [cardEventFare setCode:currentTicket.fareCode];
            
            CardEventRevision *cardEventRevision = [[CardEventRevision alloc] init];
            
            [cardEventRevision setRevisionId:0];
            
            [cardEventFare setRevision:cardEventRevision];
            
            [cardEventContent setFare:cardEventFare];
            
            NSData *contentData = [NSKeyedArchiver archivedDataWithRootObject:cardEventContent];
            
            [activationEvent setContent:contentData];
            
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"TicketPageViewController Create Activation Event Error, couldn't save: %@", [saveError localizedDescription]);
            }
            
            [self runCardSyncService];
            
            [self reloadPagerViews];
            
            // Check which page to open after ticket has been activated
            if ([Utilities featuresFromId:@"barcode_after_ticket_activation"]) {
                [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
            }
        }
    } else if (alertView.tag == REQUEST_ALERT_TAG) {
        if (buttonIndex == 1) {
            serviceRequestComment = [[alertView textFieldAtIndex:0] text];
            if ([serviceRequestComment length] > 0) {
                [self showProgressDialog];
                CustomerRequestService *requestService = [[CustomerRequestService alloc] initWithListener:self
                                                                                            ticketGroupId:currentTicket.ticketGroupId
                                                                                                  comment:serviceRequestComment];
                [requestService execute];
            }
        }
    } else if (alertView.tag == TOKEN_ALERT_TAG) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (alertView.tag == ACTIVATION_MAX_ALERT_TAG) {
    } else if (alertView.tag == ACTIVATE_TIME_ALERT_TAG) {
    } else if (alertView.tag == RESET_TIME_ALERT_TAG) {
    } else if (alertView.tag == ANOTHER_ACTIVE_TICKET_TAG) {
        if (buttonIndex == 1) {
            [self activateTicket];
        }
    } else if (alertView.tag == STORED_VALUE_TAG) {
    } else if (alertView.tag == OUT_OF_SERVICE_DAY_TAG) {
    }
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[CustomerRequestService class]]) {
        NSString *message = [NSString stringWithFormat:@"Successfully sent request:\n\n%@", serviceRequestComment];
        
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"request_sent"]
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                           otherButtonTitles:nil];
        [singleAlertView show];
    } else if ([service isMemberOfClass:[GetTicketEventsService class]]) {
        if (informationView) {
            [informationView setInformationDisplay];
        }
    }
    else if ([service isMemberOfClass:[GetWalletContentUsage class]]) {
    }
    
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
}

#pragma mark - UIPageViewControllerDataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int pageIndex = ((BasePageViewController *)viewController).pageIndex;
    
    if (pageIndex == 0) {
        return nil;
    }
    
    pageIndex--;
    
    return [viewControllers objectAtIndex:pageIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int pageIndex = ((BasePageViewController *)viewController).pageIndex;
    
    pageIndex++;
    
    if (pageIndex == PAGE_COUNT) {
        return nil;
    }
    if(pageIndex > 1)
        return nil;
    
    return [viewControllers objectAtIndex:pageIndex];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
    
    [locationManager stopUpdatingLocation];
}

#pragma mark - Other methods

- (void)reloadPagerViews
{
    Ticket *currentTicket = [Utilities currentTicket:self.managedObjectContext];
    
    if (currentTicket) {
        // Reload pager views
        UIView *parent = self.view.superview;
        [self.view removeFromSuperview];
        self.view = nil;                // Unloads the view
        [parent addSubview:self.view];  // Reloads the view from the nib
        
        // Move view below navigation bar
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
            CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
            
            CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
            
            [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                           self.createCustomSecurityViewController ? applicationFrame.origin.y + navigationBarHeight
                                           : statusBarHeight + navigationBarHeight,
                                           applicationFrame.size.width,
                                           self.createCustomSecurityViewController ? applicationFrame.size.height - statusBarHeight - navigationBarHeight
                                           : applicationFrame.size.height)];
        }
        
        // Show results of GetTicketEventsService in TicketInformationViewController
//        GetTicketEventsService *getTicketEventsService = [[GetTicketEventsService alloc] initWithListener:self
//                                                                                            ticketGroupId:currentTicket.ticketGroupId
//                                                                                                 memberId:currentTicket.memberId];
//        [getTicketEventsService execute];
    }
}

- (void)handleEnterForeground:(id)sender
{
    Ticket *currentTicket = [Utilities currentTicket:self.managedObjectContext];
    
    // AC: Have seen the pop notification go off when it wasn't supposed to, perhaps add in this check for safety
    if ([currentTicket.type isEqualToString:ACTIVE] && ([[NSDate date] timeIntervalSince1970] >= ([currentTicket.activationDateTime doubleValue]
                                                               + ([currentTicket.activationLiveTime intValue] * SECONDS_PER_MINUTE)))) {
        [self popPagerViewController:nil];
    } else {
        [self reloadPagerViews];
    }
}

- (void)reloadForReplacedTicket
{
    NSLog(@"+++++++++++++++++ reloadForReplacedTicket +++++++++++++++");
    
    [self.navigationController popViewControllerAnimated:NO];
    
    TicketPageViewController *pageView = [[TicketPageViewController alloc] initWithNibName:@"TicketPageViewController" bundle:[NSBundle baseResourcesBundle]];
    [pageView setTicketSourceId:self.ticketSourceId];
    [pageView setManagedObjectContext:self.managedObjectContext];
    
    if (self.createCustomBarcodeViewController) {
        [pageView setCreateCustomBarcodeViewController:self.createCustomBarcodeViewController];
    }
    
    if (self.createCustomSecurityViewController) {
        [pageView setCreateCustomSecurityViewController:self.createCustomSecurityViewController];
    }
    
    [self.navigationController pushViewController:pageView animated:NO];
}

- (void)checkForActiveTickets
{
    BOOL activeTicket = NO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:PRODUCT_MODEL
                                        inManagedObjectContext:self.managedObjectContext]];
    
    NSArray *products = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (Product *product in products) {
        if ([[NSString stringWithFormat:@"%@",[product productId]] isEqualToString: [_walletContent valueForKey:@"ticketIdentifier"]]) {
            activeTicket = YES;
            NSLog(@"Matched Product %@ and identifier %@",product,[_walletContent valueForKey:@"ticketIdentifier"]);
        }
    }
    
    // Skip alert message if features.plist has skip_activation_alert set to true
    if (activeTicket && ![Utilities featuresFromId:@"skip_activation_alert"]) {
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"alert"]
                                                     message:[Utilities stringResourceForId:@"another_active_ticket"]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                           otherButtonTitles:[Utilities stringResourceForId:@"yes"],nil];
        [singleAlertView setTag:ANOTHER_ACTIVE_TICKET_TAG];
        [singleAlertView show];
        
    } else {
        [self activateTicket];
    }
}
/*- (void)checkForActiveTickets
{
    BOOL activeTicket = NO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:TICKET_MODEL
                                        inManagedObjectContext:self.managedObjectContext]];
    
    NSArray *tickets = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (Ticket *ticket in tickets) {
        if ([[ticket type] isEqualToString: ACTIVE]) {
            activeTicket = YES;
        }
    }
    
    // Skip alert message if features.plist has skip_activation_alert set to true
    if (activeTicket && ![Utilities featuresFromId:@"skip_activation_alert"]) {
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"alert"]
                                                     message:[Utilities stringResourceForId:@"another_active_ticket"]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                           otherButtonTitles:[Utilities stringResourceForId:@"yes"],nil];
        [singleAlertView setTag:ANOTHER_ACTIVE_TICKET_TAG];
        [singleAlertView show];
        
    } else {
        [self activateTicket];
    }
}*/

- (void)activateTicket
{
    NSArray *encryptionKeys = [[NSArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ENCRYPTION_KEY_MODEL];
    encryptionKeys = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    
    BOOL encrypted = NO;
    for (EncryptionKey *key in encryptionKeys) {
        if (key.secretKey && [key.algorithm.lowercaseString isEqualToString:ENCRYPTION_TYPE_AES]) {
            encrypted = YES;
        }
    }
    
    if (encrypted) {
        
        
        NSMutableArray *chargeDatesArray = [[NSMutableArray alloc]init];
        NSDate *now = [NSDate date];
        NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
        NSInteger epochSeconds = [[NSNumber numberWithDouble:epochSecondsDecimals] integerValue];
        NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
        [dict setObject:[NSNumber numberWithInteger:epochSeconds] forKey:@"chargeDate"];
        [chargeDatesArray addObject:dict];
        
        GetWalletContentUsage *GetWalletContentusage  = [[GetWalletContentUsage alloc] initWithListener:self managedObjectContext:self.managedObjectContext withArray:chargeDatesArray walletContentUsageIdentifier:self.walletContent.identifier];
        [GetWalletContentusage execute];
        
        
        self.walletContent.ticketEffectiveDate=[NSNumber numberWithLong:epochSeconds];
        NSError *saveError;
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&saveError]) {
            NSLog(@"TicketPagerViewController Error, couldn't save: %@", [saveError localizedDescription]);
        }
        
        
        
        /*
        Ticket *currentTicket = [Utilities currentTicket:self.managedObjectContext];
        
        if (currentTicket.activationCount) {
            if (([currentTicket.activationCount intValue] >= [currentTicket.activationCountMax intValue]) && ([currentTicket.activationCountMax intValue] != 0)) {
                singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_max_title"]
                                                             message:[Utilities stringResourceForId:@"activate_max_msg"]
                                                            delegate:self
                                                   cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                   otherButtonTitles:nil];
                [singleAlertView setTag:ACTIVATION_MAX_ALERT_TAG];
                [singleAlertView show];
            } else {
                long long nowEpochTime = [[NSDate date] timeIntervalSince1970];
                long long validStartEpochTime = [currentTicket.validStartDateTime doubleValue];
                long long expirationEpochTime = [currentTicket.expirationDateTime doubleValue];
                long long activationEpochTime = [currentTicket.activationDateTime doubleValue];
                long long resetEpochTime = [currentTicket.activationResetTime doubleValue];
                long long nextActivationEpochTime = (activationEpochTime + (resetEpochTime * SECONDS_PER_MINUTE));
                
                if ((nowEpochTime < validStartEpochTime) || (nowEpochTime >= expirationEpochTime)) {
                    singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_time_title"]
                                                                 message:[Utilities stringResourceForId:@"activate_time_msg"]
                                                                delegate:self
                                                       cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                       otherButtonTitles:nil];
                    [singleAlertView setTag:ACTIVATE_TIME_ALERT_TAG];
                    [singleAlertView show];
                } else if (nowEpochTime < nextActivationEpochTime) {
                    long long differenceInSeconds = nextActivationEpochTime - nowEpochTime;
                    NSString *timeString = @"";
                    NSString *timeSuffix = @"";
                    if (differenceInSeconds < 60) {
                        timeString = [NSString stringWithFormat:@"%lld", differenceInSeconds];
                        
                        if (differenceInSeconds == 1) {
                            timeSuffix = @"second";
                        } else {
                            timeSuffix = @"seconds";
                        }
                    } else if (differenceInSeconds < 120) {
                        timeString = @"1";
                        timeSuffix = @"minute";
                    } else {
                        int minutes = ceil(differenceInSeconds / 60);
                        timeString = [NSString stringWithFormat:@"%d", minutes];
                        timeSuffix = @"minutes";
                    }
                    
                    // TODO: Change hard coded string because of ticket vs. pass usage
                    NSString *message = [NSString stringWithFormat:@"This ticket has %@ %@ before it can be activated again.", timeString, timeSuffix];
                    
                    singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_reset_title"]
                                                                 message:message
                                                                delegate:self
                                                       cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                       otherButtonTitles:nil];
                    [singleAlertView setTag:RESET_TIME_ALERT_TAG];
                    [singleAlertView show];
                } else {
                    singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_ticket_title"]
                                                                 message:[Utilities stringResourceForId:@"activate_msg"]
                                                                delegate:self
                                                       cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                                       otherButtonTitles:[Utilities stringResourceForId:@"yes"], nil];
                    [singleAlertView setTag:ACTIVATE_ALERT_TAG];
                    [singleAlertView show];
                }
            }
        } else {
            singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"ticket_outdated_title"]
                                                         message:[Utilities stringResourceForId:@"ticket_outdated_msg"]
                                                        delegate:self
                                               cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                               otherButtonTitles:nil];
            [singleAlertView setTag:TOKEN_ALERT_TAG];
            [singleAlertView show];
        }
         */
    }
    else {
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"no_encryption_title"]
                                                     message:[Utilities stringResourceForId:@"no_encryption_msg"]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                           otherButtonTitles:nil];
        [singleAlertView setTag:NO_ENCRYPTION_TAG];
        [singleAlertView show];
    }
}


- (void)runCardSyncService
{
    if ([[RuntimeData ticketSourceId:self.managedObjectContext] isEqualToString:[Utilities deviceId]]) {
        TicketSyncService *syncService = [[TicketSyncService alloc] initWithContext:self.managedObjectContext];
        [syncService execute];
    } else {
        CardSyncService *cardSyncService = [[CardSyncService alloc] initWithContext:self.managedObjectContext];
        [cardSyncService execute];
    }
}

- (void)requestService
{
    singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"service_request_title"]
                                                 message:[Utilities stringResourceForId:@"service_request_msg"]
                                                delegate:self
                                       cancelButtonTitle:[Utilities stringResourceForId:@"cancel"]
                                       otherButtonTitles:[Utilities stringResourceForId:@"send"], nil];
    [singleAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [singleAlertView setTag:REQUEST_ALERT_TAG];
    [singleAlertView show];
}

- (void)popPagerViewController:(NSNotification *)notification
{
    [self.navigationController popViewControllerAnimated:YES];
}

+ (UIView *)pageLabelWithTitle:(NSString *)title frameWidth:(CGFloat)frameWidth
{
    if ([title isEqualToString:[Utilities stringResourceForId:@"barcode"]]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, PAGER_STRIP_HEIGHT)];
        
        UILabel *barcodeLabel = [[UILabel alloc] initWithFrame:view.frame];
        
        [barcodeLabel setText:[Utilities stringResourceForId:@"barcode"]];
        [barcodeLabel setTextAlignment:NSTextAlignmentCenter];
        [barcodeLabel setTextColor:[UIColor whiteColor]];
        [barcodeLabel setFont:[UIFont systemFontOfSize:14]];
        [barcodeLabel setBackgroundColor:[UIColor clearColor]];
        
        [view addSubview:barcodeLabel];
        
        UIButton *ticketButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [ticketButton setFrame:CGRectMake(frameWidth/3*2, 0, frameWidth/3, PAGER_STRIP_HEIGHT)];
        [ticketButton setTitle:[Utilities stringResourceForId:@"information_label_right"] forState:UIControlStateNormal];
        ticketButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        ticketButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [ticketButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities textInactiveColor]]] forState:UIControlStateNormal];
        [ticketButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [ticketButton setBackgroundColor:[UIColor clearColor]];
        [ticketButton addTarget:self action:@selector(handleStatusClick:) forControlEvents:UIControlEventTouchUpInside];
        [ticketButton setTag:1];
        
        [view addSubview:ticketButton];
        
        [view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pagerStripBgColor]]]];
        
        return view;
    } else if ([title isEqualToString:[Utilities stringResourceForId:@"status"]]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, PAGER_STRIP_HEIGHT)];
        
        UIButton *barcodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [barcodeButton setFrame:CGRectMake(0, 0, frameWidth/3, PAGER_STRIP_HEIGHT)];
        [barcodeButton setTitle:[Utilities stringResourceForId:@"barcode_label_left"] forState:UIControlStateNormal];
        barcodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        barcodeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [barcodeButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities textInactiveColor]]] forState:UIControlStateNormal];
        [barcodeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [barcodeButton setBackgroundColor:[UIColor clearColor]];
        [barcodeButton addTarget:self action:@selector(handleBarcodeClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:barcodeButton];
        
        UILabel *ticketLabel = [[UILabel alloc] initWithFrame:view.frame];
        
        [ticketLabel setText:[Utilities stringResourceForId:@"ticket_label"]];
        [ticketLabel setTextAlignment:NSTextAlignmentCenter];
        [ticketLabel setTextColor:[UIColor whiteColor]];
        [ticketLabel setFont:[UIFont systemFontOfSize:14]];
        [ticketLabel setBackgroundColor:[UIColor clearColor]];
        
        [view addSubview:ticketLabel];
        
        UIButton *informationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [informationButton setFrame:CGRectMake(frameWidth/3*2, 0, frameWidth/3, PAGER_STRIP_HEIGHT)];
        [informationButton setTitle:[Utilities stringResourceForId:@"information_label_right"] forState:UIControlStateNormal];
        informationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        informationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [informationButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities textInactiveColor]]] forState:UIControlStateNormal];
        [informationButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [informationButton setBackgroundColor:[UIColor clearColor]];
        [informationButton addTarget:self action:@selector(handleInformationClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:informationButton];
        
        [view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pagerStripBgColor]]]];
        
        return view;
    }else if ([title isEqualToString:[Utilities stringResourceForId:@"information"]]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, PAGER_STRIP_HEIGHT)];
        
        UIButton *barcodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [barcodeButton setFrame:CGRectMake(0, 0, frameWidth/3, PAGER_STRIP_HEIGHT)];
        [barcodeButton setTitle:[Utilities stringResourceForId:@"barcode_label_left"] forState:UIControlStateNormal];
        barcodeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        barcodeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [barcodeButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities textInactiveColor]]] forState:UIControlStateNormal];
        [barcodeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [barcodeButton setBackgroundColor:[UIColor clearColor]];
        [barcodeButton addTarget:self action:@selector(handleBarcodeClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:barcodeButton];
        
        UILabel *ticketLabel = [[UILabel alloc] initWithFrame:view.frame];
        
        [ticketLabel setText:[Utilities stringResourceForId:@"information"]];
        [ticketLabel setTextAlignment:NSTextAlignmentCenter];
        [ticketLabel setTextColor:[UIColor whiteColor]];
        [ticketLabel setFont:[UIFont systemFontOfSize:14]];
        [ticketLabel setBackgroundColor:[UIColor clearColor]];
        
        [view addSubview:ticketLabel];
        
        UIButton *informationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [informationButton setFrame:CGRectMake(frameWidth/3*2, 0, frameWidth/3, PAGER_STRIP_HEIGHT)];
        [informationButton setTitle:[Utilities stringResourceForId:@"information_label_right"] forState:UIControlStateNormal];
        informationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        informationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [informationButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities textInactiveColor]]] forState:UIControlStateNormal];
        [informationButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [informationButton setBackgroundColor:[UIColor clearColor]];
        [informationButton addTarget:self action:@selector(handleInformationClick:) forControlEvents:UIControlEventTouchUpInside];
        
//        [view addSubview:informationButton];
        
        [view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pagerStripBgColor]]]];
        
        return view;
    }
    else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameWidth, PAGER_STRIP_HEIGHT)];
        
        UIButton *ticketButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [ticketButton setFrame:CGRectMake(0, 0, frameWidth/3, PAGER_STRIP_HEIGHT)];
        [ticketButton setTitle:[Utilities stringResourceForId:@"barcode_label_left"] forState:UIControlStateNormal];
        ticketButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        ticketButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [ticketButton setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities textInactiveColor]]] forState:UIControlStateNormal];
        [ticketButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [ticketButton setBackgroundColor:[UIColor clearColor]];
        [ticketButton addTarget:self action:@selector(handleStatusClick:) forControlEvents:UIControlEventTouchUpInside];
        [ticketButton setTag:0];
        
        [view addSubview:ticketButton];
        
        UILabel *informationLabel = [[UILabel alloc] initWithFrame:view.frame];
        
        [informationLabel setText:[Utilities stringResourceForId:@"information"]];
        [informationLabel setTextAlignment:NSTextAlignmentCenter];
        [informationLabel setTextColor:[UIColor whiteColor]];
        [informationLabel setFont:[UIFont systemFontOfSize:14]];
        [informationLabel setBackgroundColor:[UIColor clearColor]];
        
        [view addSubview:informationLabel];
        
        [view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pagerStripBgColor]]]];
        
        return view;
    }
}

/*- (Ticket *)threadSafeTicket
{
    Ticket *threadSafeTicket = nil;
    
    // Check if _ticket still has valid information that is not null
    if (self.ticket.activationCount) {
        NSLog(@"threadSafeTicket found");
        
        threadSafeTicket = self.ticket;
    } else {
        NSLog(@"need to reload threadSafeTicket with values: %@, %@, %f", self.ticketGroupId, self.memberId, self.firstActivationDateTime);
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:TICKET_MODEL
                                            inManagedObjectContext:self.managedObjectContext]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticketGroupId == %@ AND memberId == %@ AND firstActivationDateTime == %lf",
                                  self.ticketGroupId, self.memberId, self.firstActivationDateTime];
        [fetchRequest setPredicate:predicate];
        
        NSArray *tickets = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        NSLog(@"threadSafeTicket count: %lu", (unsigned long)[tickets count]);
        
        if ([tickets count] > 0) {
            threadSafeTicket = [tickets objectAtIndex:0];
        }
    }
    
    return threadSafeTicket;
}*/

#pragma mark - Action on top buttons
//Using notifications since actions have to be class methods and not instance methods, so there is no easy access to properties.
+ (void)handleBarcodeClick:(id)sender{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"NO", @"moveRight",
                                @0, @"pageIndex", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_PAGE object:nil userInfo:dictionary];
}

+ (void)handleInformationClick:(id)sender{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"YES", @"moveRight",
                                @1, @"pageIndex", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_PAGE object:nil userInfo:dictionary];
    
}

+ (void)handleStatusClick:(id)sender{
    NSString *moveRight;
    if ([sender tag] == 0)
        moveRight = @"NO";
    else
        moveRight = @"YES";
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:moveRight, @"moveRight",
                                @1, @"pageIndex", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MOVE_PAGE object:nil userInfo:dictionary];
    
}

- (void)movePage:(NSNotification *)notification
{
    if ([[[notification userInfo] valueForKey:@"moveRight"] isEqualToString:@"YES"]){
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:[[[notification userInfo] valueForKey:@"pageIndex"] intValue]]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    } else {
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:[[[notification userInfo] valueForKey:@"pageIndex"] intValue]]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
}

#pragma mark - IBActions

- (IBAction)menuButtonAction:(UIButton *)sender {
    if (sender == self.informationBtn) {
        [TicketPageViewController handleInformationClick:sender];
    }else{
        [TicketPageViewController handleBarcodeClick:sender];
    }
    [self animateToButton:sender];
}

-(void)animateToButton:(UIButton *)button {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.bottomIndicatorView.frame = CGRectMake(button.frame.origin.x, self.bottomIndicatorView.frame.origin.y, button.frame.size.width, self.bottomIndicatorView.frame.size.height);
    } completion:^(BOOL finished) {
        //code for completion
    }];
}

@end
