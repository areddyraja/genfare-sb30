//
//  TicketBarcodeViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TicketBarcodeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppConstants.h"
#import "BarcodeUtilities.h"
#import "EncryptionSet.h"
#import "NSData+AES128.h"
#import "NSData+Base64.h"
#import "StoredData.h"
#import "TicketPageViewController.h"
#import "UIColor+HexString.h"
#import "UIImage+SimpleResize.h"
#import "Utilities.h"
#import "zint.h"
#import "CardEvent.h"
#import "CardEventContent.h"
#import "ReportExceptionsService.h"
#import "RuntimeData.h"
#import "TicketSyncService.h"
#import "CardSyncService.h"
#import "Token.h"
#import "AppException.h"
#import "GetWalletContentUsage.h"
#import "Product.h"
#import "EncryptionKey.h"
#import "TicketActivation.h"
#import "Event.h"
#import "CooCooAccountUtilities1.h"
#import "Singleton.h"
#import "GetWalletContentUsagePayAsYouGo.h"
#import "iRide-Swift.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define maxValidTime 300
double const BARCODE_REGENERATION_INTERVAL = 57.0;

@interface TicketBarcodeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *barcodeHolderView;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel1;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel2;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel3;
@property (weak, nonatomic) IBOutlet UILabel *expiresLabel;
@property (weak, nonatomic) IBOutlet UILabel *passTitle;
@property (weak, nonatomic) IBOutlet GFMenuButton *activatePassButton;

@end
#pragma mark - Variables Declarations
@implementation TicketBarcodeViewController{
    UIView *box;
    Ticket *currentTicket;
    UIImageView *barcodeView;
    NSTimer *timer;
    NSTimer *timerSecurity;
    NSTimer *regenerateBarcodeTimer;
    int activationEpochTime;
    int transitionSeconds;
    int activationLiveMinutes;
    NSString *documentsPath;
    UIColor *backgroundActive;
    UIColor *backgroundInactive;
    UIColor *backgroundTransition;
    UILabel *elapsedTimeLabel;
    UIImage *tokenImage;
    UIImage *primaryTokenImage;
    UIImageView *tokenView;
    BOOL visualModeSwitched;
    float boxWidth;
    float boxHeight;
    float boxPadding;
    UILabel *detailsLabel;
    BOOL showingAlternateToken;
    UIAlertView *singleAlertView;
    UIButton *activateCodeButton;
    BOOL isActive;
    NSArray *totalProdcutArray;
    NSDateFormatter *df;
    Event *event;
}
@synthesize product;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                         stringByAppendingPathComponent:TICKET_IMAGES];
        [self setPageIndex:0];
    }
    return self;
}

- (id)init{
    if (self = [super init]) {
        documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                         stringByAppendingPathComponent:TICKET_IMAGES];
        [self setPageIndex:0];
    }
    return self;
}

#pragma mark - View lifecycle Methods
- (void)loadView{
    [super loadView];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height - STATUS_BAR_HEIGHT;
    backgroundActive = [UIColor whiteColor]; //[UIColor colorWithPatternImage:[UIImage loadOverrideImageNamed:@"bg_check_blue"]];
    backgroundInactive = [UIColor colorWithPatternImage:[UIImage loadOverrideImageNamed:@"bg_check_gray"]];
    backgroundTransition = [UIColor colorWithPatternImage:[UIImage loadOverrideImageNamed:@"bg_check_yellow"]];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
//                                                            0,
//                                                            self.view.frame.size.width,
//                                                            screenHeight)];
//    [view setBackgroundColor:backgroundInactive];
//    self.view = view;
    //[self.view addSubview:[TicketPageViewController pageLabelWithTitle:[Utilities stringResourceForId:@"barcode"] frameWidth:self.view.frame.size.width]];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reInitializeTimerWithImage:)
                                                      name:UIApplicationWillEnterForegroundNotification object:nil];
    [self initializeBarCodeView];
    //self.activatePassButton.hidden = YES;
    [self.activatePassButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
}
-(void)reInitializeTimerWithImage:(NSNotification *)notification{
    //[[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [box removeFromSuperview];
    [self.view addSubview:[TicketPageViewController pageLabelWithTitle:[Utilities stringResourceForId:@"barcode"] frameWidth:self.view.frame.size.width]];
    [self initializeBarCodeView];
    [self checkAndDisplayBarcodeView];
    [self displayBarCodeViewWithContent];
}
-(void)initializeBarCodeView{
    BOOL isExpired = NO;
    df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    NSInteger remainingActiveTime = self.walletContent.ticketActivationExpiryDate.longLongValue-epochSecondsDecimals;
    isActive = [self.walletContent.status isEqualToString:ACTIVE]&&remainingActiveTime>0;
    CGFloat screenHeight = [Utilities currentDeviceHeight];
    //Dynamic background
    UIView *dynamicBackground = [[UIView alloc] initWithFrame:CGRectMake(0, PAGER_STRIP_HEIGHT, 120, screenHeight - PAGER_STRIP_HEIGHT)];
//    [dynamicBackground setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_dynamic_bg"]]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setFrame:dynamicBackground.bounds];
    [gradient setColors:[NSArray arrayWithObjects:
                         (id)[UIColor clearColor].CGColor,
                         (id)[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_dynamic_bg"]].CGColor,
                         (id)[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_dynamic_bg"]].CGColor,
                         (id)[UIColor clearColor].CGColor, nil]];
    [gradient setStartPoint:CGPointMake(0, 0)];
    [gradient setEndPoint:CGPointMake(1.0f, 0)];
    [dynamicBackground.layer setMask:gradient];

    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(TICKET_PADDING,
                                                              TICKET_PADDING + PAGER_STRIP_HEIGHT,
                                                              SCREEN_WIDTH - (TICKET_PADDING * 2),
                                                              screenHeight - HELP_SLIDER_HEIGHT -PAGER_STRIP_HEIGHT - (TICKET_PADDING * 4))];
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
    //[self.view addSubview:border];
    //Layer 2: Ticket content box All ticket text and graphics go inside this layout
    float boxPadding = TICKET_PADDING + TICKET_CORNER_RADIUS;
    box = [[UIView alloc] initWithFrame:CGRectMake(boxPadding,
                                                   TICKET_PADDING + PAGER_STRIP_HEIGHT,
                                                   SCREEN_WIDTH - (boxPadding * 2),
                                                   screenHeight - HELP_SLIDER_HEIGHT - PAGER_STRIP_HEIGHT - (TICKET_PADDING * 4))];
    [box setBackgroundColor:[UIColor clearColor]];
    box.alpha = 0.5;
    boxWidth = box.frame.size.width;
    boxHeight = box.frame.size.height;
    //Layer 3: Ticket content Barcode ADD TO Ticket content box
    float boxWidth = box.frame.size.width;
    float boxHeight = box.frame.size.height;
    // Layer 3 code in viewDidAppear
    //Layer 4: Transit logo
    UIImage *logoImage = [UIImage loadOverrideImageNamed:@"ticket_logo"];
    float imageRatio = 180 / logoImage.size.width;
    float targetHeight = logoImage.size.height * imageRatio;
    float targetWidth = 180;
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((boxWidth / 2) - (targetWidth / 2), TICKET_VIEW_PADDING, targetWidth, targetHeight)];
    [logoView setImage:logoImage];
    //[box addSubview:logoView];
    //Layer 5: Ticket message
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
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
    //[box addSubview:messageLabel];
    NSString *filename = [NSString stringWithFormat:@"%@.png", self.walletContent.type];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", documentsPath, filename];
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    NSDateFormatter *fullDateFormatter = [[NSDateFormatter alloc] init];
    [fullDateFormatter setDateFormat:@"MM/dd/yy hh:mm aa"];

    if (imageData != nil) {
        UIImage *ticketImage = [UIImage imageWithData:imageData];
        float targetWidth = 80;
        float imageRatio = targetWidth / ticketImage.size.width;
        float targetHeight = ticketImage.size.height * imageRatio;
        UIImageView *ticketImageView = [[UIImageView alloc] initWithImage:ticketImage];
        [ticketImageView setFrame:CGRectMake(TICKET_VIEW_PADDING, boxHeight - targetHeight - TICKET_VIEW_PADDING, targetWidth, targetHeight)];
        //[box addSubview:ticketImageView];
        self.barcodeHolderView.image = ticketImage;
        UILabel *detailsLabel = [[UILabel alloc] init];
        [detailsLabel setTextAlignment:NSTextAlignmentLeft];
        if (isActive) {
            [detailsLabel setText:[self.walletContent descriptation]];
        } else {
            [detailsLabel setText:[self.walletContent descriptation]];
        }
        if ([Utilities featuresFromId:@"large_ticket_details_font"]) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenHeight = screenRect.size.height;
            //NSLog(@"%f",screenHeight/26);
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
        //[box addSubview:detailsLabel];
    } else {
        NSString * type;
        if([self.walletContent.type isEqualToString:@"1"] || [self.walletContent.type isEqualToString:@"Single ride"]){
            type = @"Single ride";
        }else{
            NSString *typeString = [self.walletContent.type stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            type = [Utilities capitalizedOnlyFirstLetter:typeString];
        }
        UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, box.frame.size.height-100.0, box.frame.size.width, 100.0)];
        [detailsLabel setText:[NSString stringWithFormat:@"Total Fare : $ %.2f\n%@\n%@", [self.walletContent.fare floatValue] ,self.walletContent.descriptation,type]];
        [detailsLabel setTextAlignment:NSTextAlignmentCenter];

        self.passTitle.text = self.walletContent.descriptation;
        
        if ([Utilities featuresFromId:@"large_ticket_details_font"]) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenHeight = screenRect.size.height;
            [detailsLabel setFont:[UIFont systemFontOfSize:screenHeight/26]];
        } else {
            [detailsLabel setFont:[UIFont systemFontOfSize:12]];
        }
        [detailsLabel setNumberOfLines:4];
        //   [detailsLabel setCenter:CGPointMake(box.frame.size.width / 2, box.frame.size.height - (detailsLabel.frame.size.height / 2) - TICKET_VIEW_PADDING)];
        [box addSubview:detailsLabel];
        //  [detailsLabel setFrame:CGRectMake((boxWidth / 2) - (detailsLabel.frame.size.width / 4),
        //                                          boxHeight - (detailsLabel.frame.size.height / 2) - TICKET_VIEW_PADDING,
        //                                          detailsLabel.frame.size.width / 2,
        //                                          detailsLabel.frame.size.height / 2)];
        if (isExpired){
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage loadOverrideImageNamed:@"bg_check_red"]]];
        }
    }
    [self.view addSubview:box];
    if (!isActive) {
        [self checkAndActiveButton];
        self.expiresLabel.text = @" ";
    }else{
        if (self.walletContent.ticketActivationExpiryDate.longLongValue > 0) {
            self.expiresLabel.text = [NSString stringWithFormat:@"Expires %@",[fullDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.walletContent.ticketActivationExpiryDate.longLongValue]]];
        }else{
            self.expiresLabel.text = @" ";
        }
    }
    
    [self.view bringSubviewToFront:self.activatePassButton];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.activatePassButton.hidden = YES;
    [self checkAndDisplayBarcodeView];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Pager" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

-(void)checkAndDisplayBarcodeView{
    NSDate *now = [NSDate date];
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    NSInteger remainingActiveTime = self.walletContent.ticketActivationExpiryDate.longLongValue-epochSecondsDecimals;
    if(remainingActiveTime < 0){
        self.activatePassButton.hidden = NO;
        return;
    }
    isActive = [self.walletContent.status isEqualToString:ACTIVE]&&remainingActiveTime>0;
    if(isActive){
        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
        dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
            [self calculateTimeAndShowRemainingTime];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self displayBarCodeViewWithContent];
    self.view.backgroundColor = UIColor.clearColor;
}

-(void)displayBarCodeViewWithContent{
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    [self.view setFrame:frame];
    NSLog(@"Frame is:%@",NSStringFromCGRect(frame));
    if (box && isActive) {
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        self.barcodeHolderView.image = [BarcodeUtilities generateBarcodeWithTicket:self.walletContent
                                                                         accountId:[NSString stringWithFormat:@"%@",account.accountId]
                                                              managedObjectContext:self.managedObjectContext];
        
        regenerateBarcodeTimer = [NSTimer scheduledTimerWithTimeInterval:BARCODE_REGENERATION_INTERVAL
                                                                  target:self
                                                                selector:@selector(regenerateBarcodeByTimer:)
                                                                userInfo:nil
                                                                 repeats:YES];
    }
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
            [cardEventContent setTicketGroupId:self.walletContent.ticketGroup];
            [cardEventContent setMemberId:self.walletContent.member];
            [cardEventContent setBornOnDateTime:now];
            CardEventFare *cardEventFare = [[CardEventFare alloc] init];
            [cardEventFare setCode:self.walletContent.fare?[self.walletContent.fare stringValue]:@""];
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
            // if (isViewControllerVisible) {
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
            }else{
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
                //                    [tokenView setFrame:CGRectMake((boxWidth / 2) - (tokenWidth / 2),
                //                                                   (boxHeight / 2) - (tokenHeight / 2) - 120,
                //                                                   tokenWidth,
                //                                                   tokenHeight)];
                [tokenView setFrame:CGRectMake((boxWidth / 2) - (tokenWidth / 2),
                                               (SCREEN_HEIGHT/2.2)+40,
                                               tokenWidth,
                                               tokenHeight)];
                UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
                // [tokenView addGestureRecognizer:panRecognizer];
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
        });
        if ([self.walletContent.status isEqualToString:ACTIVE]) {
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateTimerBarcodeView:)
                                                   userInfo:nil
                                                    repeats:YES];
        }
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    if(timerSecurity){
        [timerSecurity invalidate];
        timerSecurity=nil;
    }
    if (regenerateBarcodeTimer) {
        [regenerateBarcodeTimer invalidate];
        regenerateBarcodeTimer = nil;
    }
    if (tokenImage) {
        tokenImage = nil;
    }
    if (tokenView) {
        [tokenView removeFromSuperview];
        tokenView = nil;
    }
}

#pragma mark - Initial Methods
-(void)checkAndActiveButton{
    self.activatePassButton.hidden = NO;
    [self.view sendSubviewToBack:box];
    [self.view bringSubviewToFront:self.activatePassButton];
    return;
    if(activateCodeButton==nil){
        [self.view setBackgroundColor:backgroundInactive];
        UIImage *activateImage = [UIImage loadOverrideImageNamed:@"button_activate_old"];
        activateCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        float buttonWidth = activateImage.size.width / 2;
        float buttonHeight = activateImage.size.height / 2;
        [activateCodeButton setFrame:CGRectMake((boxWidth / 2) - (buttonWidth / 2),SCREEN_HEIGHT/2,
                                            buttonWidth,
                                            buttonHeight)];
        [activateCodeButton setBackgroundImage:activateImage forState:UIControlStateNormal];
        // if (!isExpired) {
        UIPageViewController *parent = (UIPageViewController *)self.parentViewController;
        TicketPageViewController *dataSource = (TicketPageViewController *)parent.dataSource;
        [activateCodeButton addTarget:self action:@selector(checkForActiveTickets:) forControlEvents:UIControlEventTouchUpInside];
        // }
    }
    activateCodeButton.hidden=NO;
    [box addSubview:activateCodeButton];
}
#pragma mark UIButton Action Method for Activate Ticket
- (IBAction)checkForActiveTickets:(UIButton*)button{
    BOOL activeTicket = NO;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRODUCT_MODEL  inManagedObjectContext: self.managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ticketId == %@)",self.walletContent.ticketIdentifier]];
    NSError * error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetch error:&error];
    //    NSMutableArray *filteredProdcutArray = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketId == %d)",[wc.ticketIdentifier intValue]]];
    if(fetchedObjects.count>0){
        self.product=fetchedObjects.firstObject;
        NSLog(@"product id %@",self.product);
        activeTicket = YES;
    }
    // Skip alert message if features.plist has skip_activation_alert set to true
    if (activeTicket && ![Utilities featuresFromId:@"skip_activation_alert"]) {
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_ticket_title"]
                                                     message:[Utilities stringResourceForId:@"activate_msg"]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                           otherButtonTitles:[Utilities stringResourceForId:@"yes"],nil];
        [singleAlertView show];
    } else {
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"activate_ticket_title"]
                                                     message:[Utilities stringResourceForId:@"activate_msg"]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                           otherButtonTitles:[Utilities stringResourceForId:@"yes"], nil];
        [singleAlertView setTag: 1];
        [singleAlertView show];
        //   [self activateTicket];
        [button removeFromSuperview];
    }
}
#pragma mark - ActivateTicket Selector Methods
- (void)activateTicket{
    self.activatePassButton.hidden = YES;
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
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]!=NotReachable){
        }
        event = (Event *)[NSEntityDescription insertNewObjectForEntityForName:Event_Model inManagedObjectContext:self.managedObjectContext];
        NSDate *now = [NSDate date];
        NSTimeInterval epochSecondsDecimals1 = [now timeIntervalSince1970];
        NSInteger epochSeconds1 = [[NSNumber numberWithDouble:epochSecondsDecimals1] integerValue];
        [event setType:@"passes"];
        [event setIdentifier:@"no"];
        [event setClickedTime:[NSNumber numberWithInteger:epochSeconds1*1000]];
        [event setTicketid:self.walletContent.ticketIdentifier];
        [event setWalletContentUsageIdentifier:self.walletContent.identifier];
        NSError *error1;
        if (![self.managedObjectContext save:&error1]) {
            NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
        } else {
            NSLog(@"Saved ");
        }
        TicketActivation *ticketactivation;
        ticketactivation = (TicketActivation *)[NSEntityDescription insertNewObjectForEntityForName:Activation_Model inManagedObjectContext:self.managedObjectContext];
        //   NSDate *expDate=[NSDate dateWithTimeIntervalSince1970:self.walletContent.ticketActivationExpiryDate.doubleValue];
        [ticketactivation setActivationDate:[df stringFromDate:[NSDate date]]];
        [ticketactivation setTicketIdentifier:self.walletContent.ticketIdentifier];
        NSError *error2;
        if (![self.managedObjectContext save:&error2]) {
            NSLog(@"Error, couldn't save: %@", [error2 localizedDescription]);
        } else {
            NSLog(@"Saved ");
        }
        long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
        if(self.walletContent.activationDate.stringValue.length==0||self.walletContent.activationDate==nil){
            self.walletContent.activationDate=[NSNumber numberWithLong:milliseconds];
        }
        if(self.walletContent.status != ACTIVE){
            self.walletContent.generationDate=[NSNumber numberWithLong:milliseconds];
        }
        NSTimeInterval epochSecondsDecimals = ([now timeIntervalSince1970]);
        NSInteger epochSeconds = [[NSNumber numberWithDouble:epochSecondsDecimals] integerValue];
        self.walletContent.ticketEffectiveDate=[NSNumber numberWithLong:epochSeconds];
        self.walletContent.status=ACTIVE;
        self.walletContent.ticketActivationExpiryDate=[NSNumber numberWithDouble:epochSeconds+[self.product.barcodeTimer intValue]];
        NSDate *expDate=[NSDate dateWithTimeIntervalSince1970:self.walletContent.ticketActivationExpiryDate.doubleValue];
        //  [event setTicketActivationExpiryDate:[df stringFromDate:expDate]];
        [ticketactivation setActivationExpDate:[df stringFromDate:expDate]];
        NSArray *fetchedObjects;
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:WALLET_CONTENT_MODEL  inManagedObjectContext: self.managedObjectContext];
        [fetch setEntity:entityDescription];
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ticketIdentifier == %@)",self.walletContent.ticketIdentifier]];
        NSError * error = nil;
        fetchedObjects = [self.managedObjectContext executeFetchRequest:fetch error:&error];
        if(fetchedObjects.count>0){
            WalletContents *wallet=fetchedObjects.firstObject;
            wallet.status=ACTIVE;
            wallet.ticketActivationExpiryDate=[NSNumber numberWithDouble:epochSeconds+[self.product.barcodeTimer intValue]];
            if([wallet.type isEqualToString:@"stored_ride"]){
                wallet.valueRemaining=[NSNumber numberWithInt:[wallet.valueRemaining intValue] -1];
            }else{
                wallet.activationCount=[NSNumber numberWithInt:[wallet.activationCount intValue] + 1];
            }
        }
        NSError *saveError;
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&saveError]) {
            NSLog(@"TicketPagerViewController Error, couldn't save: %@", [saveError localizedDescription]);
        }
        else{
            [self syncActivatedTicketToServer];
        }
        
        [self initializeBarCodeView];
        [self checkAndDisplayBarcodeView];
        [self displayBarCodeViewWithContent];
    } else {
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"no_encryption_title"]
                                                     message:[Utilities stringResourceForId:@"no_encryption_msg"]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                           otherButtonTitles:nil];
        [singleAlertView show];
    }
}

-(void)calculateTimeAndShowRemainingTime{
    NSDate *now = [NSDate date];
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    NSInteger remainingActiveTime = self.walletContent.ticketActivationExpiryDate.longLongValue-epochSecondsDecimals;
    if(remainingActiveTime>0){
        barcodeView.hidden=NO;
        self.activatePassButton.hidden = YES;
        if(activateCodeButton)
            activateCodeButton.hidden=true;
        [self checkAndAddElapsedTimeLabel];
        [self updateTimerSecurityView:remainingActiveTime];
        timerSecurity = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerSecurityView:) userInfo:nil repeats:YES];
    }
    else{
        self.activatePassButton.hidden = NO;
        [self checkAndActiveButton];
        barcodeView.hidden=YES;
    }
}
-(void)checkAndAddElapsedTimeLabel{
    if (!elapsedTimeLabel) {
        elapsedTimeLabel = [[UILabel alloc] init];
        [elapsedTimeLabel setText:@"00:00:00"];
        [elapsedTimeLabel setTextAlignment:NSTextAlignmentCenter];
        [elapsedTimeLabel setTextColor:[UIColor clearColor]];
        [elapsedTimeLabel setFont:[UIFont systemFontOfSize:60.0f]];
        [elapsedTimeLabel setBackgroundColor:[UIColor clearColor]];
        [elapsedTimeLabel setNumberOfLines:1];
        [elapsedTimeLabel sizeToFit];
        //[elapsedTimeLabel setCenter:CGPointMake(boxWidth / 2, boxHeight / 2 - 120)];
        [elapsedTimeLabel setCenter:CGPointMake(boxWidth / 2, (SCREEN_HEIGHT/2)+40)];
    }
    [UIView animateWithDuration:4.0f
                          delay:0.2f
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat
                     animations:^ {
                         [elapsedTimeLabel setTransform:CGAffineTransformMakeTranslation(-1 * ((boxWidth / 2) - boxPadding - 20), 0)];
                         [elapsedTimeLabel setTransform:CGAffineTransformMakeTranslation((boxWidth / 2) - boxPadding - 20, 0)];
                     }
                     completion:^ (BOOL finished) {
                     }];
    elapsedTimeLabel.hidden=NO;
    [box addSubview:elapsedTimeLabel];
}
#pragma mark - BarcodeView Selector Methods
- (void)updateTimerBarcodeView:(NSTimer *)animationTimer{
    long long nowEpochTime = [[NSDate date] timeIntervalSince1970];
    long long secondsElapsed;
    if ([Utilities featuresFromId:@"count_down"]) {
        secondsElapsed = ((activationLiveMinutes * SECONDS_PER_MINUTE) + [self.walletContent.purchasedDate doubleValue]) - nowEpochTime;
    } else {
        secondsElapsed  = nowEpochTime - activationEpochTime;
    }
    if ([Utilities featuresFromId:@"count_down"]) {
        if (secondsElapsed > (activationLiveMinutes *SECONDS_PER_MINUTE - transitionSeconds)) {
            [self.view setBackgroundColor:backgroundTransition];
        } else if (secondsElapsed >= (activationLiveMinutes *SECONDS_PER_MINUTE - transitionSeconds*2)) {
            [self.view setBackgroundColor:backgroundActive];
        } else {
            [self.view setBackgroundColor:backgroundActive];
        }
    }else{
        if (secondsElapsed >= (transitionSeconds * 2)) {
            [self.view setBackgroundColor:backgroundActive];
        } else if (secondsElapsed >= transitionSeconds) {
            [self.view setBackgroundColor:backgroundActive];
        } else {
            [self.view setBackgroundColor:backgroundTransition];
        }
    }
}
- (void)updateTimerSecurityView:(long long )secondsElapsed{
    NSDate *now = [NSDate date];
    NSTimeInterval epochSecondsDecimals = [now timeIntervalSince1970];
    NSInteger remainingActiveTime = self.walletContent.ticketActivationExpiryDate.longLongValue-epochSecondsDecimals;
    if(remainingActiveTime>0){
        if(activateCodeButton)
            activateCodeButton.hidden=YES;
        elapsedTimeLabel.hidden=NO;
        [box bringSubviewToFront:elapsedTimeLabel];
        [box addSubview:elapsedTimeLabel];
        int seconds = remainingActiveTime % SECONDS_PER_MINUTE;
        int minutes = (remainingActiveTime / SECONDS_PER_MINUTE) % SECONDS_PER_MINUTE;
        long long int hours = remainingActiveTime / SECONDS_PER_HOUR;
        if (hours > 0) {
            [elapsedTimeLabel setText:[NSString stringWithFormat:@"%02lld:%02d:%02d", hours, minutes, seconds]];
        } else {
            [elapsedTimeLabel setText:[NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
        }
        //        NSLog(@"elapsedTimeLabel label text %@",elapsedTimeLabel.text);
        
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
        }else{
            if (minutes >= 6) {
                //[self.view setBackgroundColor:backgroundActive];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_3"]]];
            } else if (minutes >= 2) {
                //[self.view setBackgroundColor:backgroundActive];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_2"]]];
            } else {
                //[self.view setBackgroundColor:backgroundTransition];
                [elapsedTimeLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"ticket_timer_1"]]];
            }
        }
        //TODO - Update color here
    }else{
        if([self.walletContent.ticketSource  isEqual: @"local"]){
            barcodeView.hidden=YES;
            elapsedTimeLabel.hidden=YES;
            [timerSecurity invalidate];
            self.walletContent.status=INACTIVE;
            [self.managedObjectContext deleteObject:self.walletContent];
            NSError *error1;
            if (![self.managedObjectContext save:&error1]) {
                NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
            } else {
                NSLog(@"Saved ");
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self checkAndActiveButton];
            barcodeView.hidden=YES;
            elapsedTimeLabel.hidden=YES;
            [timerSecurity invalidate];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
- (void)toggleSecurityToken{
    float xOffset = 0.0f;
    if (showingAlternateToken) {
        tokenImage = primaryTokenImage;
        showingAlternateToken = NO;
    }else{
        tokenImage = [UIImage loadOverrideImageNamed:@"token_alternate"];
        xOffset = tokenImage.size.width / -4;
        showingAlternateToken = YES;
    }
    float tokenWidth = tokenImage.size.width / 2;
    float tokenHeight = tokenImage.size.height / 2;
    [tokenView setImage:tokenImage];
    [tokenView setUserInteractionEnabled:YES];
    [tokenView setFrame:CGRectMake((boxWidth / 2) - xOffset,
                                   (boxHeight / 2) - (tokenHeight),
                                   tokenWidth,
                                   tokenHeight)];
}
- (void)regenerateBarcodeByTimer:(NSTimer *)rtimer{
}
#pragma mark - UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self activateTicket];
    }
}
#pragma mark - Sync ActivatedTicket Methods
-(void)syncActivatedTicketToServer{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:Event_Model];
    NSError *error = nil;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clickedTime" ascending:YES];
    [request setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
    NSArray *fetchedObjects1 = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"%@",fetchedObjects1);
    NSMutableArray *EventsTemp = [[NSMutableArray alloc] init];
    for (Event *event in fetchedObjects1) {
        [EventsTemp addObject:event];
    }
    if(EventsTemp>0){
        NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
        for (Event *tevent in EventsTemp) {
            if([tevent.identifier isEqualToString:@"no"]&&[tevent.type isEqualToString:@"passes"]){
                NSMutableArray *productsListArray = [[NSMutableArray alloc]init];
                [dict setObject:tevent.clickedTime forKey:@"chargeDate"];
                NSString *identifier =  tevent.walletContentUsageIdentifier;
                [productsListArray addObject:dict];
                GetWalletContentUsage *GetWalletContentusage  = [[GetWalletContentUsage alloc] initWithListener:self managedObjectContext:self.managedObjectContext withArray:productsListArray walletContentUsageIdentifier:identifier];
                [GetWalletContentusage execute];
            }else if([tevent.identifier isEqualToString:@"no"]&&[tevent.type isEqualToString:@"payasyougo"]){
                NSMutableArray *productsListArray = [[NSMutableArray alloc]init];
                [dict setObject: tevent.amountRemaining forKey:@"amountRemaining"];
                [dict setObject:tevent.clickedTime forKey:@"chargeDate"];
                [dict setObject:tevent.fare forKey:@"amountCharged"];
                [dict setObject:tevent.ticketid?tevent.ticketid:@"" forKey:@"ticketIdentifier"];
                [productsListArray addObject:dict];
                NSString *identifier =  tevent.walletContentUsageIdentifier;
                GetWalletContentUsagePayAsYouGo *getWalletContentUsagePayAsYouGo  = [[GetWalletContentUsagePayAsYouGo alloc] initWithListener:self managedObjectContext:self.managedObjectContext withArray:productsListArray walletContentUsageIdentifier:identifier];
                [getWalletContentUsagePayAsYouGo execute];
            }
        }
    }
    else{
        NSLog(@"hello");
    }
}
#pragma mark - Service Call Success method
- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if([service isMemberOfClass:[GetWalletContentUsage class]]) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSManagedObjectContext *context = [self managedObjectContext];
        [request setEntity:[NSEntityDescription entityForName:Event_Model inManagedObjectContext:context]];
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        //                if(results.count>0)
        //                {
        //                    Event *passes = results.firstObject;
        //                     [self.managedObjectContext deleteObject:passes];
        //                }
        for (Event *tempEvent in results) {
            [self.managedObjectContext deleteObject:tempEvent];
        }
        [self.managedObjectContext save:nil];
    }
    else if ([service isMemberOfClass:[GetWalletContentUsagePayAsYouGo class]]) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSManagedObjectContext *context = [self managedObjectContext];
        [request setEntity:[NSEntityDescription entityForName:Event_Model inManagedObjectContext:context]];
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        for (Event *tempEvent in results) {
            [self.managedObjectContext deleteObject:tempEvent];
        }
        [self.managedObjectContext save:nil];
    }
    [self dismissProgressDialog];
}
#pragma mark - Service Call Error method
- (void)threadErrorWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
}
@end
