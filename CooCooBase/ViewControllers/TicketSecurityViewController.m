//
//  TicketSecurityViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TicketSecurityViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppConstants.h"
#import "AppException.h"
#import "CardEvent.h"
#import "CardEventContent.h"
#import "CardSyncService.h"
#import "ReportExceptionsService.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "TicketPageViewController.h"
#import "TicketSyncService.h"
#import "Token.h"
#import "UIColor+HexString.h"
#import "UIImage+SimpleResize.h"
#import "Utilities.h"


@interface TicketSecurityViewController ()

@end

@implementation TicketSecurityViewController
{
    UIView *box;
    float boxWidth;
    float boxHeight;
    float boxPadding;
    Ticket *currentTicket;
    UIImage *tokenImage;
    UIImage *primaryTokenImage;
    BOOL showingAlternateToken;
    UIImageView *tokenView;
    UILabel *elapsedTimeLabel;
    NSTimer *timer;
    UILabel *detailsLabel;
    int activationEpochTime;
    int transitionSeconds;
    int activationLiveMinutes;
    NSDate *expirationDate;
    NSString *documentsPath;
    BOOL visualModeSwitched;
    BOOL isViewControllerVisible;
    UIColor *backgroundActive;
    UIColor *backgroundInactive;
    UIColor *backgroundTransition;
}

- (id)init
{
    if (self = [super init]) {
        documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                         stringByAppendingPathComponent:TICKET_IMAGES];
        
        [self setPageIndex:1];
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
    
    backgroundActive = [UIColor colorWithPatternImage:[UIImage loadOverrideImageNamed:@"bg_check_blue"]];
    backgroundInactive = [UIColor colorWithPatternImage:[UIImage loadOverrideImageNamed:@"bg_check_gray"]];
    backgroundTransition = [UIColor colorWithPatternImage:[UIImage loadOverrideImageNamed:@"bg_check_yellow"]];
    
    [view setBackgroundColor:backgroundInactive];
    
    self.view = view;
    
    [self.view addSubview:[TicketPageViewController pageLabelWithTitle:[Utilities stringResourceForId:@"ticket_label"] frameWidth:self.view.frame.size.width]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    currentTicket = [Utilities currentTicket:self.managedObjectContext];
    activationEpochTime = [currentTicket.activationDateTime doubleValue];
    transitionSeconds = [currentTicket.activationTransitionTime doubleValue];
    activationLiveMinutes = [currentTicket.activationLiveTime intValue];
    expirationDate = [NSDate dateWithTimeIntervalSince1970:[currentTicket.expirationDateTime doubleValue]];
    
    BOOL isExpired = NO;
    
    //int64_t is equavlent to a "long long" or an 8 byte integer on a 32Bit machine or a "long" on a 64Bit machine
    long long nowEpochTime = [[NSDate date] timeIntervalSince1970];
    long long expirationEpochTime = [expirationDate timeIntervalSince1970];
    
    BOOL isActive = [currentTicket.type isEqualToString:ACTIVE];
    
    if  (!isActive && (
                       (([currentTicket.activationCountMax intValue] != 0) && (currentTicket.activationCount == currentTicket.activationCountMax)) || (nowEpochTime > expirationEpochTime) || ([currentTicket.isHistory intValue] == 1))) {
        isExpired = YES;
    }
    
    /*
     * Layer 1: Ticket border
     */
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(TICKET_PADDING,
                                                              TICKET_PADDING + PAGER_STRIP_HEIGHT,
                                                              self.view.frame.size.width - (TICKET_PADDING * 2),
                                                              self.view.frame.size.height - PAGER_STRIP_HEIGHT - (TICKET_PADDING * 4))];
    [border.layer setMasksToBounds:YES];
    [border.layer setCornerRadius:TICKET_CORNER_RADIUS];
    
    if (isExpired) {
        [border setBackgroundColor:[UIColor lightGrayColor]];
    } else {
        if (isActive) {
            [border setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities ticketBorderColor]]]];
        } else {
            [border setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
    
    [self.view addSubview:border];
    
    /*
     * Layer 2: Ticket content box
     *             All ticket text and graphics go inside this layout
     */
    boxPadding = TICKET_PADDING + TICKET_CORNER_RADIUS;
    box = [[UIView alloc] initWithFrame:CGRectMake(boxPadding,
                                                   TICKET_PADDING + PAGER_STRIP_HEIGHT,
                                                   self.view.frame.size.width - (boxPadding * 2),
                                                   self.view.frame.size.height - PAGER_STRIP_HEIGHT - (TICKET_PADDING * 4))];
    [box setBackgroundColor:[UIColor whiteColor]];
    
    /*
     * Layer 3: Ticket content
     *             Activate button / security token + elapsed validation time + animation
     *             ADD TO Ticket content box
     */
    boxWidth = box.frame.size.width;
    boxHeight = box.frame.size.height;
    
    if (!isActive) {
        UIImage *activateImage = [UIImage loadOverrideImageNamed:@"button_activate"];
        UIButton *activateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        float buttonWidth = activateImage.size.width / 2;
        float buttonHeight = activateImage.size.height / 2;
        
        [activateButton setFrame:CGRectMake((boxWidth / 2) - (buttonWidth / 2),
                                            (boxHeight / 2) - (buttonHeight / 2),
                                            buttonWidth,
                                            buttonHeight)];
        [activateButton setBackgroundImage:activateImage forState:UIControlStateNormal];
        
        if (!isExpired) {
            UIPageViewController *parent = (UIPageViewController *)self.parentViewController;
            TicketPageViewController *dataSource = (TicketPageViewController *)parent.dataSource;
            
            [activateButton addTarget:dataSource action:@selector(checkForActiveTickets) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [box addSubview:activateButton];
    }
    
    /*
     * Layer 4: Transit logo
     */
    UIImage *logoImage = [UIImage loadOverrideImageNamed:@"ticket_logo"];
    
    float targetWidth = 180;
    float imageRatio = targetWidth / logoImage.size.width;
    float targetHeight = logoImage.size.height * imageRatio;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(toggleSecurityToken)];
    [tapGesture setNumberOfTapsRequired:5];
    
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake((boxWidth / 2) - (targetWidth / 2), TICKET_VIEW_PADDING, targetWidth, targetHeight)];
    [logoView setUserInteractionEnabled:YES];
    [logoView setImage:logoImage];
    [logoView addGestureRecognizer:tapGesture];
    
    [box addSubview:logoView];
    
    /*
     * Layer 5: Ticket message
     */
    UILabel *messageLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(0,
                                                      logoView.frame.origin.y + logoView.frame.size.height + 10,
                                                      box.frame.size.width,
                                                      0)];
    
    [messageLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_message"]]];
    if (isActive) {
        [messageLabel setText:[Utilities stringResourceForId:@"this_is_your_ticket_active"]];
    } else if (!isExpired) {
        [messageLabel setText:[Utilities stringResourceForId:@"please_activate_ticket"]];
    } else {
        [messageLabel setText:[Utilities stringResourceForId:@"cannot_activate"]];
        [messageLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_message_expired"]]];
    }
    
    [messageLabel setTextAlignment:NSTextAlignmentCenter];
    
    [messageLabel setNumberOfLines:0];
    [messageLabel sizeToFit];
    [messageLabel setCenter:CGPointMake(box.frame.size.width / 2, messageLabel.center.y - TICKET_VIEW_PADDING)];
    
    [box addSubview:messageLabel];
    
    /*
     * Layer 6: Ticket image + stations + details
     */
    /*NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
     NSEntityDescription *entity = [NSEntityDescription entityForName:STATION_MODEL
     inManagedObjectContext:self.managedObjectContext];
     [fetchRequest setEntity:entity];
     
     NSError *error;
     NSArray *stations = [[NSArray alloc] initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
     
     NSString *departStation = @"";
     NSString *arriveStation = @"";
     for (Station *station in stations) {
     if ([station.id isEqualToString:ticket.departStationId]) {
     departStation = station.name;
     } else if ([station.id isEqualToString:ticket.arriveStationId]) {
     arriveStation = station.name;
     }
     }*/
    
    NSString *filename = [NSString stringWithFormat:@"%@.png", currentTicket.ticketTypeCode];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", documentsPath, filename];
    
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    if (imageData != nil) {
        UIImage *ticketImage = [UIImage imageWithData:imageData];
        
        float targetWidth = 80;
        float imageRatio = targetWidth / ticketImage.size.width;
        float targetHeight = ticketImage.size.height * imageRatio;
        
        UIImageView *ticketImageView = [[UIImageView alloc] initWithImage:ticketImage];
        [ticketImageView setFrame:CGRectMake(TICKET_VIEW_PADDING, boxHeight - targetHeight - TICKET_VIEW_PADDING, targetWidth, targetHeight)];
        
        [box addSubview:ticketImageView];
        
        detailsLabel = [[UILabel alloc] init];
        
        if (isActive) {
            [detailsLabel setText:[currentTicket activeDetails]];
        } else {
            [detailsLabel setText:[currentTicket details]];
        }
        
        [detailsLabel setTextAlignment:NSTextAlignmentLeft];
        if ([Utilities featuresFromId:@"large_ticket_details_font"]) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenHeight = screenRect.size.height;
            //[detailsLabel setFont:[UIFont systemFontOfSize:30]];
            [detailsLabel setFont:[UIFont systemFontOfSize:screenHeight/26]];
        } else {
            [detailsLabel setFont:[UIFont systemFontOfSize:12]];
        }
        [detailsLabel setNumberOfLines:0];
        [detailsLabel setLineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect resizedFrame = detailsLabel.frame;
        resizedFrame.size = [detailsLabel.text sizeWithFont:detailsLabel.font
                                          constrainedToSize:CGSizeMake(boxWidth - (ticketImageView.frame.origin.x + ticketImageView.frame.size.width + (TICKET_VIEW_PADDING * 2)), FLT_MAX)
                                              lineBreakMode:detailsLabel.lineBreakMode];
        
        [detailsLabel setFrame:CGRectMake(ticketImageView.frame.origin.x + ticketImageView.frame.size.width + TICKET_VIEW_PADDING,
                                          boxHeight - resizedFrame.size.height - TICKET_VIEW_PADDING,
                                          resizedFrame.size.width,
                                          resizedFrame.size.height)];
        
        [box addSubview:detailsLabel];
        
        /*UILabel *stationsLabel = [[UILabel alloc] init];
         [stationsLabel setText:[NSString stringWithFormat:@"%@ to %@", departStation, arriveStation]];
         [stationsLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_message"]]];
         [stationsLabel setTextAlignment:NSTextAlignmentLeft];
         [stationsLabel setFont:[UIFont systemFontOfSize:12]];
         [stationsLabel setNumberOfLines:0];
         [stationsLabel setLineBreakMode:NSLineBreakByWordWrapping];
         
         resizedFrame = stationsLabel.frame;
         resizedFrame.size = [stationsLabel.text sizeWithFont:stationsLabel.font
         constrainedToSize:CGSizeMake(boxWidth - (ticketImageView.frame.origin.x + ticketImageView.frame.size.width + (TICKET_VIEW_PADDING * 2)), FLT_MAX)
         lineBreakMode:stationsLabel.lineBreakMode];
         
         [stationsLabel setFrame:CGRectMake(ticketImageView.frame.origin.x + ticketImageView.frame.size.width + TICKET_VIEW_PADDING,
         boxHeight - detailsLabel.frame.size.height - TICKET_VIEW_PADDING - resizedFrame.size.height,
         resizedFrame.size.width,
         resizedFrame.size.height)];
         
         [box addSubview:stationsLabel];*/
    } else {
        detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, box.frame.size.width, 0)];
        
        if (isActive) {
            [detailsLabel setText:[currentTicket activeDetails]];
        } else {
            [detailsLabel setText:[currentTicket details]];
        }
        
        [detailsLabel setTextAlignment:NSTextAlignmentCenter];
        if ([Utilities featuresFromId:@"large_ticket_details_font"]) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenHeight = screenRect.size.height;
            //[detailsLabel setFont:[UIFont systemFontOfSize:30]];
            [detailsLabel setFont:[UIFont systemFontOfSize:screenHeight/26]];
        } else {
            [detailsLabel setFont:[UIFont systemFontOfSize:12]];
        }
        [detailsLabel setNumberOfLines:0];
        [detailsLabel sizeToFit];
        [detailsLabel setCenter:CGPointMake(box.frame.size.width / 2, box.frame.size.height - (detailsLabel.frame.size.height / 2) - TICKET_VIEW_PADDING)];
        
        [box addSubview:detailsLabel];
        
        /*UILabel *stationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, box.frame.size.width, 0)];
         [stationsLabel setText:[NSString stringWithFormat:@"%@\n%@", departStation, arriveStation]];
         [stationsLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_message"]]];
         [stationsLabel setTextAlignment:NSTextAlignmentCenter];
         [stationsLabel setFont:[UIFont systemFontOfSize:12]];
         [stationsLabel setNumberOfLines:2];
         [stationsLabel sizeToFit];
         [stationsLabel setCenter:CGPointMake(box.frame.size.width / 2,
         box.frame.size.height - detailsLabel.frame.size.height - (stationsLabel.frame.size.height / 2) - TICKET_VIEW_PADDING)];
         
         [box addSubview:stationsLabel];*/
    }
    
    /*
     * Layer 7: Expired ticket image
     */
    if (isExpired) {
        UIImage *expiredImage = [UIImage loadOverrideImageNamed:@"expired"];
        expiredImage = [expiredImage scaleImageToSizeAspectFit:CGSizeMake(180, 180)];
        
        UIImageView *expiredView = [[UIImageView alloc] initWithImage:expiredImage];
        [expiredView setFrame:CGRectMake((boxWidth / 2) - (expiredImage.size.width / 2),
                                         boxHeight / 2 - (expiredImage.size.height / 2),
                                         expiredImage.size.width,
                                         expiredImage.size.height)];
        
        [box addSubview:expiredView];
    }
    
    
    if (isExpired){
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage loadOverrideImageNamed:@"bg_check_red"]]];
    }
    
    [self.view addSubview:box];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BOOL isActive = [currentTicket.type isEqualToString:ACTIVE] ? YES : NO;
    
    if (isActive) {
        long long nowEpochTime = [[NSDate date] timeIntervalSince1970];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSInteger lastAccessDateTime = [defaults integerForKey:KEY_LAST_TOKEN_ACCESS];
        
        /* If the last recorded time is AFTER the current time,
         * the user may have manually changed the phone date to a future time
         * and activated a ticket (perhaps to view an upcoming security token)
         * then set the phone back to an earlier time.
         * A user may also have set their phone time back to try to extend a ticket's live time.
         */
        if (nowEpochTime < lastAccessDateTime) {
            [currentTicket setEventType:EVENT_TYPE_FLAG_TIME];
            
            // Add ticket to Ticket Event Queue
            /*NSMutableArray *ticketsQueue = [StoredData ticketsQueue];
             
             if ([ticketsQueue indexOfObject:ticket.id] == NSNotFound) {
             [ticketsQueue addObject:ticket.id];
             }
             
             [StoredData commitTicketsQueueWithList:ticketsQueue];*/
            
            NSDate *now = [NSDate date];
            
            CardEvent *activationEvent = (CardEvent *)[NSEntityDescription insertNewObjectForEntityForName:CARD_EVENT_MODEL inManagedObjectContext:self.managedObjectContext];
            
            [activationEvent setOccurredOnDateTime:now];
            [activationEvent setType:@"FLAG_TIME"];
            [activationEvent setDetail:@"Suspicious phone date/time activity"];
            
            CardEventContent *cardEventContent = [[CardEventContent alloc] init];
            
            [cardEventContent setTicketGroupId:currentTicket.ticketGroupId];
            [cardEventContent setMemberId:currentTicket.memberId];
            [cardEventContent setBornOnDateTime:now];
            
            CardEventFare *cardEventFare = [[CardEventFare alloc] init];
            
            [cardEventFare setCode:currentTicket.fareCode];
            
            CardEventRevision *cardEventRevision = [[CardEventRevision alloc] init];
            
            [cardEventRevision setRevisionId:0];
            
            [cardEventFare setRevision:cardEventRevision];
            
            [cardEventContent setFare:cardEventFare];
            
            NSData *contentData = [NSKeyedArchiver archivedDataWithRootObject:cardEventContent];
            
            [activationEvent setContent:contentData];
            
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"TicketSecurityViewController Create FLAG_TIME Event Error, couldn't save: %@", [saveError localizedDescription]);
            }
            
            if ([[RuntimeData ticketSourceId:self.managedObjectContext] isEqualToString:[Utilities deviceId]]) {
                TicketSyncService *syncService = [[TicketSyncService alloc] initWithContext:self.managedObjectContext];
                [syncService execute];
            } else {
                CardSyncService *cardSyncService = [[CardSyncService alloc] initWithContext:self.managedObjectContext];
                [cardSyncService execute];
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"date_changed_title"]
                                                                message:[Utilities stringResourceForId:@"date_changed_msg"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        // Security token sometimes fails to load immediately, perhaps add some delay
        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
        dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
            if (isViewControllerVisible) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:TOKEN_MODEL
                                                          inManagedObjectContext:self.managedObjectContext];
                [fetchRequest setEntity:entity];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", [Token tokenDateStringFromDate:[NSDate date]]];
                [fetchRequest setPredicate:predicate];
                
                NSError *error;
                NSArray *tokens = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                
                if ([tokens count] > 0) {
                    // There should not be more than one token for a given date, but just in case there are
                    // (perhaps because of a bug), choose the one that has a non-nil image
                    Token *token = nil;
                    
                    for (Token *savedToken in tokens) {
                        if (savedToken.image) {
                            token = savedToken;
                            break;
                        }
                    }
                    
                    tokenImage = token.image;
                    if (token.image && token.image != nil){
                        tokenImage = token.image;
                    }else{
                        tokenImage = [UIImage loadOverrideImageNamed:@"token_default"];
                    }

                } else {
                    tokenImage = [UIImage loadOverrideImageNamed:@"token_default"];
                    
                    NSMutableArray *exceptions = [[NSMutableArray alloc] initWithArray:[[RuntimeData instance] appExceptions]];
                    
                    AppException *exception = [[AppException alloc] init];
                    [exception setErrorType:7];
                    [exception setErrorDetail:[Utilities stringResourceForId:@"exception_no_tokens"]];
                    [exception setErrorDateTime:[[NSDate date] timeIntervalSince1970]];
                    
                    [exceptions addObject:exception];
                    
                    [[RuntimeData instance] setAppExceptions:[exceptions copy]];
                    
                    ReportExceptionsService *exceptionsService = [[ReportExceptionsService alloc] init];
                    [exceptionsService execute];
                }
                
                if (tokenImage && ![box.subviews containsObject:tokenView]) {
                    primaryTokenImage = tokenImage;
                    
                    float tokenWidth = tokenImage.size.width / 2;
                    float tokenHeight = tokenImage.size.height / 2;
                    
                    tokenView = [[UIImageView alloc] initWithImage:tokenImage];
                    [tokenView setAlpha:0.5];
                    [tokenView setUserInteractionEnabled:YES];
                    [tokenView setFrame:CGRectMake((boxWidth / 2) - (tokenWidth / 2),
                                                   (boxHeight / 2) - (tokenHeight / 2),
                                                   tokenWidth,
                                                   tokenHeight)];
                    
                    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
                    //[tokenView addGestureRecognizer:panRecognizer];
                    
                    [UIView animateWithDuration:4.0f
                                          delay:0.2f
                                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction
                                     animations:^ {
                                         [tokenView setTransform:CGAffineTransformMakeTranslation(-1 * ((boxWidth / 2) - boxPadding - 20), 0)];
                                         [tokenView setTransform:CGAffineTransformMakeTranslation((boxWidth / 2) - boxPadding - 20, 0)];
                                     }
                                     completion:^ (BOOL finished) {
                                     }];
                    
                    //Add fade in and fade out effect
                    [UIView animateWithDuration:4.0f
                                          delay:0.2f
                                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction
                                     animations:^ {
                                         tokenView.alpha = 0.1f;
                                     }
                                     completion:^ (BOOL finished) {
                                         tokenView.alpha = 0.8f;
                                     }];
                    
                    
                    
                    [box addSubview:tokenView];
                    
                    if (visualModeSwitched) {
                        visualModeSwitched = !visualModeSwitched;
                        
                        [detailsLabel setFont:[UIFont systemFontOfSize:12]];
                        [detailsLabel setFrame:CGRectMake((boxWidth / 2) - (detailsLabel.frame.size.width / 4),
                                                          boxHeight - (detailsLabel.frame.size.height / 2) - TICKET_VIEW_PADDING,
                                                          detailsLabel.frame.size.width / 2,
                                                          detailsLabel.frame.size.height / 2)];
                    }
                }
                
                if (![box.subviews containsObject:elapsedTimeLabel]) {
                    elapsedTimeLabel = [[UILabel alloc] init];
                    [elapsedTimeLabel setText:@"00:00:00"];
                    [elapsedTimeLabel setTextAlignment:NSTextAlignmentCenter];
                    [elapsedTimeLabel setTextColor:[UIColor clearColor]];
                    [elapsedTimeLabel setFont:[UIFont systemFontOfSize:60.0f]];
                    [elapsedTimeLabel setBackgroundColor:[UIColor clearColor]];
                    [elapsedTimeLabel setNumberOfLines:1];
                    [elapsedTimeLabel sizeToFit];
                    [elapsedTimeLabel setCenter:CGPointMake(boxWidth / 2, boxHeight / 2)];
                    
                    [UIView animateWithDuration:4.0f
                                          delay:0.2f
                                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat
                                     animations:^ {
                                         [elapsedTimeLabel setTransform:CGAffineTransformMakeTranslation(-1 * ((boxWidth / 2) - boxPadding - 20), 0)];
                                         [elapsedTimeLabel setTransform:CGAffineTransformMakeTranslation((boxWidth / 2) - boxPadding - 20, 0)];
                                     }
                                     completion:^ (BOOL finished) {
                                     }];
                    
                    [box addSubview:elapsedTimeLabel];
                }
            }
        });
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerSecurityView:) userInfo:nil repeats:YES];
        
        [defaults setInteger:nowEpochTime forKey:KEY_LAST_TOKEN_ACCESS];
    }
    
    isViewControllerVisible = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    if (tokenImage) {
        tokenImage = nil;
    }
    
    if (tokenView) {
        [tokenView removeFromSuperview];
        tokenView = nil;
    }
    
    if (elapsedTimeLabel) {
        [elapsedTimeLabel removeFromSuperview];
        elapsedTimeLabel = nil;
    }
    
    isViewControllerVisible = NO;
}

#pragma mark - View controls

- (void)panDetected:(UIPanGestureRecognizer *)panRecognizer
{
    CGPoint translation = [panRecognizer translationInView:self.view];
    
    CGFloat positionY = tokenView.frame.origin.y;
    
    positionY += translation.y;
    
    if (visualModeSwitched && (positionY + (tokenView.frame.size.height / 2)) < (detailsLabel.frame.origin.y + (detailsLabel.frame.size.height / 2))) {
        visualModeSwitched = !visualModeSwitched;
        
        [self switchVisualMode];
    } else if (!visualModeSwitched && (positionY + (tokenView.frame.size.height / 2)) >= (detailsLabel.frame.origin.y + (detailsLabel.frame.size.height / 2))) {
        visualModeSwitched = !visualModeSwitched;
        
        [self switchVisualMode];
    } else {
        [tokenView setFrame:CGRectMake(tokenView.frame.origin.x, positionY, tokenView.frame.size.width, tokenView.frame.size.height)];
    }
    
    [panRecognizer setTranslation:CGPointZero inView:self.view];
}

- (void)switchVisualMode
{
    if (visualModeSwitched) {
        [detailsLabel setFont:[UIFont systemFontOfSize:16]];
        [detailsLabel setFrame:CGRectMake((boxWidth / 2) - (detailsLabel.frame.size.width),
                                          (boxHeight / 2) - (detailsLabel.frame.size.height),
                                          detailsLabel.frame.size.width * 2,
                                          detailsLabel.frame.size.height * 2)];
        
        [tokenView setFrame:CGRectMake(tokenView.frame.origin.x + (tokenView.frame.size.width / 4),
                                       boxHeight - (tokenView.frame.size.height / 2) - TICKET_VIEW_PADDING,
                                       tokenView.frame.size.width / 2,
                                       tokenView.frame.size.height / 2)];
        
        [elapsedTimeLabel setFrame:CGRectMake(elapsedTimeLabel.frame.origin.x,
                                              boxHeight - elapsedTimeLabel.frame.size.height - TICKET_VIEW_PADDING,
                                              elapsedTimeLabel.frame.size.width,
                                              elapsedTimeLabel.frame.size.height)];
    } else {
        [tokenView setFrame:CGRectMake(tokenView.frame.origin.x - (tokenView.frame.size.width / 2),
                                       (boxHeight / 2) - tokenView.frame.size.height,
                                       tokenView.frame.size.width * 2,
                                       tokenView.frame.size.height * 2)];
        
        [detailsLabel setFont:[UIFont systemFontOfSize:12]];
        [detailsLabel setFrame:CGRectMake((boxWidth / 2) - (detailsLabel.frame.size.width / 4),
                                          boxHeight - (detailsLabel.frame.size.height / 2) - TICKET_VIEW_PADDING,
                                          detailsLabel.frame.size.width / 2,
                                          detailsLabel.frame.size.height / 2)];
        
        [elapsedTimeLabel setCenter:CGPointMake(boxWidth / 2, boxHeight / 2)];
    }
}

- (void)toggleSecurityToken
{
    float xOffset = 0.0f;
    
    if (showingAlternateToken) {
        tokenImage = primaryTokenImage;
        
        showingAlternateToken = NO;
    } else {
        tokenImage = [UIImage loadOverrideImageNamed:@"token_alternate"];
        xOffset = tokenImage.size.width / -4;
        
        showingAlternateToken = YES;
    }
    
    float tokenWidth = tokenImage.size.width / 2;
    float tokenHeight = tokenImage.size.height / 2;
    
    [tokenView setImage:tokenImage];
    [tokenView setUserInteractionEnabled:YES];
    [tokenView setFrame:CGRectMake((boxWidth / 2) - xOffset,
                                   (boxHeight / 2) - (tokenHeight / 2),
                                   tokenWidth,
                                   tokenHeight)];
}

#pragma mark - Other methods

- (void)updateTimerSecurityView:(NSTimer *)animationTimer
{
    long long nowEpochTime = [[NSDate date] timeIntervalSince1970];
    
    if (elapsedTimeLabel) {
        long long secondsElapsed;
        
        if ([Utilities featuresFromId:@"count_down"]) {
            secondsElapsed = ((activationLiveMinutes * SECONDS_PER_MINUTE) + [currentTicket.activationDateTime doubleValue]) - nowEpochTime;
        } else {
            secondsElapsed  = nowEpochTime - activationEpochTime;
        }
        
        int seconds = secondsElapsed % SECONDS_PER_MINUTE;
        int minutes = (secondsElapsed / SECONDS_PER_MINUTE) % SECONDS_PER_MINUTE;
        long long int hours = secondsElapsed / SECONDS_PER_HOUR;
        
        if (hours > 0) {
            [elapsedTimeLabel setText:[NSString stringWithFormat:@"%02lld:%02d:%02d", hours, minutes, seconds]];
        } else {
            [elapsedTimeLabel setText:[NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
        }
        
        if ([Utilities featuresFromId:@"count_down"]) {
            
            if (secondsElapsed > (activationLiveMinutes *SECONDS_PER_MINUTE - transitionSeconds)) {
                [self.view setBackgroundColor:backgroundTransition];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_1"]]];
            } else if (secondsElapsed >= (activationLiveMinutes *SECONDS_PER_MINUTE - transitionSeconds*2)) {
                [self.view setBackgroundColor:backgroundActive];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_2"]]];
            } else {
                [self.view setBackgroundColor:backgroundActive];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_3"]]];
            }
            
        } else {
            if (secondsElapsed >= (transitionSeconds * 2)) {
                [self.view setBackgroundColor:backgroundActive];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_3"]]];
            } else if (secondsElapsed >= transitionSeconds) {
                [self.view setBackgroundColor:backgroundActive];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_2"]]];
            } else {
                [self.view setBackgroundColor:backgroundTransition];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_1"]]];
            }
        }
    }
    
    // AC: Have seen the pop notification go off when it wasn't supposed to, perhaps add in this check for safety
    if ([currentTicket.type isEqualToString:ACTIVE] && (nowEpochTime >= (activationEpochTime + (activationLiveMinutes * SECONDS_PER_MINUTE)))) {
        [[NSNotificationCenter defaultCenter] postNotificationName:POP_NOTIFICATION_NAME object:self];
    }
}

@end
