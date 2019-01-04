//
//  CDTATicketsViewController.m
//  CDTATicketing
//
//  Created by CooCooTech on 8/25/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//
#import "CooCooBase.h"

#import "CDTATicketsViewController.h"
#import "AppDelegate.h"
#import "CardDetailsViewController.h"
#import "PayAsYouGoViewController.h"
#import "RuntimeData.h"
#import "WalletInstructionsViewController.h"
#import "ReleaseCardService.h"
#import "StoredValueAccount.h"
#import "Product.h"
#import "Singleton.h"
#import "AppConstants.h"
#import "TicketsListViewController.h"
#import "iRide-Swift.h"
#import "GetStatusOfUserWallet.h"

//#import "CAPSPageMenu.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)



//static NSString *const CDTA_TICKETS_TITLE = @"My Connector";
static NSString *const NEW_CARD_NOTIFICATION = @"NewCardNotification";

@interface CDTATicketsViewController ()<CAPSPageMenuDelegate>{
    int walletStatusId;
    UIAlertView *singleAlertView;
}

@property (nonatomic) CAPSPageMenu *pagemenu;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *walletNameLabel;
@property (weak, nonatomic) IBOutlet GFMenuButton *purchaseBtn;
@property (weak, nonatomic) IBOutlet GFMenuButton *accountBtn;
@property (weak, nonatomic) IBOutlet UIView *pageViewHolder;

@end

@implementation CDTATicketsViewController
{
    UIViewController *currentViewController;
    NSNumber *selectedView;
    NSArray *cards;
    TicketsViewController *ticketsView;
    PayAsYouGoViewController *payAsYouGoView;
    TicketHistoryViewController *historyView;
    SettingsStore *settingsStore;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:[Utilities navigationBarTitle]]];
        
        cards = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectedView = 0;
    self.btnCardDetails.layer.cornerRadius = 5.0;
    [self.btnCardDetails.layer setMasksToBounds:YES];
    [self.btnCardDetails setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]]];
    [self setupCarousel];
    // [self CardDetailsUI];
    [self.btnCardDetails addTarget:self action:@selector(cardDetialsHandler) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.lblShadow.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.lblShadow.layer.shadowOffset = CGSizeMake(0,5);
    self.lblShadow.layer.shadowOpacity = 0.5;
    self.lblShadow.layer.masksToBounds = YES;
    
    //[self loadTicketViewFromLeft:NO];
    
    [self setUpPageMenu];
    [self updateNavBarUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNewCardNotification:)
                                                 name:NEW_CARD_NOTIFICATION
                                               object:nil];
}

-(void)updateNavBarUI {
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSideMenu:)];
    menuButton.tintColor = UIColor.whiteColor;
    [self.navigationItem setLeftBarButtonItem:menuButton];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@NavBarLogo",[[Utilities tenantId] lowercaseString]]]];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@NavBarColor",[[Utilities tenantId] lowercaseString]]]];
}


-(void)CardDetailsUI
{
    UILabel *label = nil;
    UILabel *nickname = nil;
    UIImageView *view = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        // don't do anything specific to the index within
        // this `if (view == nil) {...}` statement because the view will be
        // recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 35, 150.0f, 150.0f)];
        //        [view setImage:[UIImage imageNamed:@"card.png"]];
        [view setImage:[UIImage imageNamed:@"cota-cpass.png"]];
        view.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRect labelFrame = CGRectMake(20, 180.0, view.frame.size.width - 20, 20.0);
        label = [[UILabel alloc] initWithFrame:labelFrame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:14];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        [label setBackgroundColor:[self colorFromHexString:@"#ECA900"]];
        self.btnCardDetails.layer.cornerRadius = 5.0;
        [self.btnCardDetails.layer setMasksToBounds:YES];
        [self.btnCardDetails setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]]];
        // [self.carousel addSubview:label];
        
        nickname = [[UILabel alloc] initWithFrame:CGRectMake(0, 12.0, 150.0, 20.0)];
        nickname.backgroundColor = [UIColor clearColor];
        nickname.textAlignment = NSTextAlignmentCenter;
        nickname.font = [nickname.font fontWithSize:14];
        nickname.textColor = [UIColor darkTextColor];
        nickname.tag = 2;
        [self.view addSubview:nickname];
        [self.view addSubview:view];
    } else {
        
    }
    
}

-(void)logOutCheck
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Remove Account" message:@"Are you sure you wish to remove this account from the app?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *logOutAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[Singleton sharedManager] logOutHandler];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Do nothing
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:logOutAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)homeBtnHandler
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help My Tickets" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBalance" object:nil];
    cards = [[Utilities getCards:self.managedObjectContext] copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTickets" object:nil];
    if ([cards count] == 0) {
        // [self loadWalletInstructions];
    } else {
        //        GetCardsService *getCardsService = [[GetCardsService alloc] initWithListener:self
        //                                                                          walletUuid:[Utilities walletId]
        //                                                                managedObjectContext:self.managedObjectContext];
        //        [getCardsService execute];
        [self getCard];
    }
    //display Card Name
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        GetStatusOfUserWallet *getStatusOfUserWallet = [[GetStatusOfUserWallet alloc] initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
        [getStatusOfUserWallet execute];
    }

    [self updateUiBasedOnWalletState];
    self.view.backgroundColor = UIColor.blackColor;
    self.purchaseBtn.backgroundColor = [UIColor colorWithHexString:@"#6AA826"];
}

-(void)updateUiBasedOnWalletState1{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    NSString * walletId = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",walletId]];
    NSError *error = nil;
    NSArray *walletarray = [self.managedObjectContext executeFetchRequest:request error:&error];
    WalletContent *walletContent  = (WalletContent *)[walletarray lastObject];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        //        nickname=account.firstName;
        //        NSString * walletName=account.walletname.length==0?@" ":account.walletname;
        //        NSString * walletName=account.walletname.length==0?@" ":[NSString stringWithFormat:@"%@ - %@",account.walletname,account.status];
        NSString * walletName=walletContent.nickname.length==0?@" ":[NSString stringWithFormat:@"%@ - %@",walletContent.nickname,walletContent.status];
        [self.walletNameLabel setText:walletName];
    }
    if (walletarray.count == 0) {
        //
    }
}

-(void)updateUiBasedOnWalletState{
    walletStatusId = [Utilities getCurrentWalletState:self.managedObjectContext];
    if (walletStatusId == WALLET_STATUS_DEACTIVATED) {
        [self.purchaseBtn setUserInteractionEnabled:NO];
        [self.purchaseBtn setBackgroundColor:[UIColor lightGrayColor]];
    }else if (walletStatusId == WALLET_STATUS_ACTIVE || walletStatusId == WALLET_STATUS_EXPIRED){
        [self.purchaseBtn setUserInteractionEnabled:YES];
        [self.purchaseBtn setBackgroundColor:[UIColor colorWithHexString:@"#6aa826"] ];
    }else{
        [self.purchaseBtn setBackgroundColor:[UIColor lightGrayColor]];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    CGRect screenRect = self.view.frame;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.pagemenu.view.frame =CGRectMake(0.0, 240.0, screenWidth, screenHeight-240.0) ;
    BaseTicketsViewController *controller = self.pagemenu.childViewControllers.firstObject;
    if ([controller respondsToSelector:@selector(refreshView)] ){
        [controller refreshView];
    }
}

-(void)getCard
{
    cards = [[Utilities getCards:self.managedObjectContext] copy];
    
    NSUInteger cardsCount = [cards count];
    
    if ([cards count] == 0) {
        [self loadWalletInstructions];
    } else {
        // If an unassigned card had just been added to the wallet just prior to navigating back to this screen,
        // the carousel index will be at Retrieve Cards. Calling setCardForTicketsViewController with this index
        // will result in a crash, so reset it to the index of the last actual card if necessary.
        if ([self.carousel currentItemIndex] == cardsCount) {
            NSLog(@"New card added, set card index back by one....");
            [self.carousel setCurrentItemIndex:cardsCount - 1];
        }
        
        [self setCardForTicketsViewController];
        
        //[self.carousel reloadData];
    }
    
    
    Card *card = [cards objectAtIndex:0];
    self.lblNickname.text = card.nickname;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveNewCardNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:NEW_CARD_NOTIFICATION]) {
        NSLog (@"Successfully received notification of a new card");
        cards = [[Utilities getCards:self.managedObjectContext] copy];
        
        [self.carousel reloadData];
        [self.carousel setCurrentItemIndex:[cards count] - 1];
        
        [self loadTicketViewFromLeft:YES];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark iCarousel methods

- (void)setupCarousel
{
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.type = iCarouselTypeCoverFlow2;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [cards count]+1;
}

- (UIView *)carousel:(iCarousel *)carouselviewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UILabel *nickname = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        // don't do anything specific to the index within
        // this `if (view == nil) {...}` statement because the view will be
        // recycled and used with other index values later
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 35, 150.0f, 150.0f)];
        
        
        view.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRect labelFrame = CGRectMake(20, 180.0, view.frame.size.width - 20, 20.0);
        label = [[UILabel alloc] initWithFrame:labelFrame];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:14];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        [label setBackgroundColor:[self colorFromHexString:@"#ECA900"]];
        self.btnCardDetails.layer.cornerRadius = 5.0;
        [self.btnCardDetails.layer setMasksToBounds:YES];
        [self.btnCardDetails setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]]];
        // [self.carousel addSubview:label];
        
        nickname = [[UILabel alloc] initWithFrame:CGRectMake(0, 12.0, 150.0, 20.0)];
        nickname.backgroundColor = [UIColor clearColor];
        nickname.textAlignment = NSTextAlignmentCenter;
        nickname.font = [nickname.font fontWithSize:14];
        nickname.textColor = [UIColor darkTextColor];
        nickname.tag = 2;
        [view addSubview:nickname];
    } else {
        // get a reference to the label in the recycled view
        // label = (UILabel *)[view viewWithTag:1];
    }
    
    if (index == [cards count]) {
        [label setBackgroundColor:[UIColor clearColor]];
        
        // ((UIImageView *)view).image = [UIImage imageNamed:@"card_add.png"];
    } else {
        //        ((UIImageView *)view).image = [UIImage imageNamed:@"card.png"];
        ((UIImageView *)view).image = [UIImage imageNamed:@"cota-cpass.png"];
    }
    
    
    // set item label
    // remember to always set any properties of your carousel item
    // views outside of the `if (view == nil) {...}` check otherwise
    // you'll get weird issues with carousel item content appearing
    if (index == [cards count]) {
        [label setText:@""];
        // [nickname setText:@"Retrieve Cards"];
    } else {
        Card *card = [cards objectAtIndex:index];
        
        [label setText:@"Card Management"];
        [nickname setText:card.nickname];
    }
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing) {
        return value * 2.3;
    } else if (option == iCarouselOptionTilt) {
        return 0.7; //default was 0.9
    }
    
    return value;
}

-(void)cardDetialsHandler
{
    [self showCardDetailsClicked:0];
}

-(IBAction)showCardDetails:(id)sender {
    [self showCardDetailsClicked:0];
}

#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if (index != [cards count]) {
        [self showCardDetailsClicked:(int) index];
    }
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel
{
    return;
    if (self.carousel.currentItemIndex == [cards count]) {
        ClaimCardsViewController *claimCardsViewController = [[ClaimCardsViewController alloc] initWithNibName:@"ClaimCardsViewController"
                                                                                                        bundle:[NSBundle baseResourcesBundle]];
        [claimCardsViewController setManagedObjectContext:self.managedObjectContext];
        [claimCardsViewController.view setFrame:CGRectMake(self.view.frame.size.width,
                                                           self.segmentedControl.frame.origin.y,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height - STATUS_BAR_HEIGHT)];
        
        [self addChildViewController:claimCardsViewController];
        
        [self transitionFromViewController:currentViewController toViewController:claimCardsViewController duration:0.3 options:0 animations:^{
            [claimCardsViewController.view setFrame:CGRectMake(0,
                                                               self.segmentedControl.frame.origin.y,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height - STATUS_BAR_HEIGHT - HELP_SLIDER_HEIGHT - 8)];
            
            [currentViewController.view setFrame:CGRectMake(currentViewController.view.frame.size.width,
                                                            self.segmentedContainerView.frame.size.height,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height - STATUS_BAR_HEIGHT)];
        } completion:^(BOOL finished) {
            [currentViewController removeFromParentViewController];
            
            currentViewController = claimCardsViewController;
        }];
    } else {
        if ([currentViewController isKindOfClass:[ClaimCardsViewController class]]) {
            [self setCardForTicketsViewController];
            
            [self.segmentedControl setSelectedSegmentIndex:0];
            
            [self loadTicketViewFromLeft:NO];
        } else if ([selectedView intValue] == 0) {
            [self loadTicketViewFromLeft:YES];
        }
        
        [self setCardForPayAsYouGo];
        [self setCardForHistory];
    }
}

#pragma mark - View controls

-(void)setUpPageMenu
{
    
    ticketsView = [[TicketsViewController alloc] initWithNibName:@"TicketsViewController" bundle:[NSBundle baseResourcesBundle]];
    [ticketsView setRefactorView:YES];
    ticketsView.title = @"Passes";
    ticketsView.ticketsController = self;
    [ticketsView setManagedObjectContext:self.managedObjectContext];
    
    payAsYouGoView = [[PayAsYouGoViewController alloc] initWithNibName:@"PayAsYouGoViewController" bundle:[NSBundle mainBundle]];
    payAsYouGoView.title = @"Pay As You Go";
    [payAsYouGoView setManagedObjectContext:self.managedObjectContext];
    payAsYouGoView.payAsYouGoController = self;
    
    historyView = [[TicketHistoryViewController alloc] initWithNibName:@"TicketHistoryViewController"
                                                                bundle:[NSBundle baseResourcesBundle]];
    historyView.title = [Utilities stringResourceForId:[Utilities historyTitle]];
    [historyView setManagedObjectContext:self.managedObjectContext];
    historyView.ticketsController = self;
    
    NSArray *controllerArray = @[ticketsView,historyView];
    
    CGFloat pageMenuWidth;
    
    if(IS_IPHONE_6)
        pageMenuWidth = 3.2;
    else if (IS_IPHONE_6PS)
        pageMenuWidth = 3.5;
    else
        pageMenuWidth = 3.7;
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithHexString:@"#dadada"],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities pageMenuColor]]],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithHexString:@"#dadada"],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor clearColor],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"Montserrat" size:15.0],
                                 CAPSPageMenuOptionMenuHeight: @(50.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(SCREEN_WIDTH/2),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 240.0, 0, screenHeight - 240.0 ) options:parameters];
    self.pagemenu.delegate = self;
    self.pagemenu.view.layer.cornerRadius = 0;
    self.pagemenu.view.layer.borderWidth = 2;
    self.pagemenu.view.layer.borderColor = [AppDelegate colorFromHexString:@"#f5f5f5"].CGColor;
    self.pagemenu.view.layer.shadowColor = [[UIColor clearColor] CGColor];
    self.pagemenu.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.pagemenu.view.layer.shadowOpacity = 0.5f;
    
    [self.view addSubview:self.pagemenu.view];
    
    
    
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index{
    
    
    NSLog(@"%@",controller);
    if(controller == payAsYouGoView)
    {
        [payAsYouGoView setManagedObjectContext:self.managedObjectContext];
        
        [self setCardForPayAsYouGo];
        
        // [self loadViewController:payAsYouGoView fromLeft:([selectedView intValue] == 0)];
    }
    else if (controller == historyView)
    {
        [historyView setManagedObjectContext:self.managedObjectContext];
        
        [self setCardForHistory];
        
        //[self loadViewController:historyView fromLeft:YES];
    }
    else
    {
        //        ticketsView = [[TicketsViewController alloc] initWithNibName:@"TicketsViewController" bundle:[NSBundle baseResourcesBundle]];
        //        ticketsView.title = @"Passes";
        //        [ticketsView setManagedObjectContext:self.managedObjectContext];
        //
        //        [ticketsView setCreateCustomTicketsViewController:^BaseTicketsViewController *{
        //            return [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
        //        }];
        //
        //        [self setCardForTicketsViewController];
        //      [self loadTicketViewFromLeft:YES];
    }
}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"%@",controller);
}

-(IBAction)showPasses:(id)sender {
    if (walletStatusId == WALLET_STATUS_ACTIVE) {
        TicketsListViewController *ticketview = [[TicketsListViewController alloc]initWithNibName:@"TicketsListViewController" bundle:nil];
        [ticketview setManagedObjectContext:self.managedObjectContext];
        ticketview.title = @"Purchase Passes";
        
        [self.navigationController pushViewController:ticketview animated:YES];
    }else{
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"walletStatus_title"]
                                                     message:[Utilities stringResourceForId:@"walletStatus_msg"]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                           otherButtonTitles:nil];
        [singleAlertView show];
    }
}

- (IBAction)segmentValueChanged:(id)sender
{
    UISegmentedControl *segmentedControl = sender;
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    
    switch (selectedIndex) {
        case 0: {
            [self loadTicketViewFromLeft:NO];
            
            break;
        }
            
        case 1: {
            payAsYouGoView = [[PayAsYouGoViewController alloc] initWithNibName:@"PayAsYouGoViewController"
                                                                        bundle:[NSBundle mainBundle]];
            [payAsYouGoView setCreateCustomTicketsViewController:^BaseTicketsViewController *{
                return [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController"
                                                                   bundle:[NSBundle mainBundle]];
            }];
            [payAsYouGoView setManagedObjectContext:self.managedObjectContext];
            
            [self setCardForPayAsYouGo];
            
            [self loadViewController:payAsYouGoView fromLeft:([selectedView intValue] == 0)];
            
            break;
        }
            
        case 2: {
            historyView = [[TicketHistoryViewController alloc] initWithNibName:@"TicketHistoryViewController"
                                                                        bundle:[NSBundle baseResourcesBundle]];
            [historyView setManagedObjectContext:self.managedObjectContext];
            
            [self setCardForHistory];
            
            [self loadViewController:historyView fromLeft:YES];
            break;
        }
            
        default:
            break;
    }
    
    selectedView = [NSNumber numberWithInteger:selectedIndex];
}

- (void)setCardForTicketsViewController
{
    
    
    return;
    //if (ticketsView) {
    if ([cards count] == 0) {   // Will be zero if called from viewDidLoad
        cards = [[Utilities getCards:self.managedObjectContext] copy];
    }
    
    Card *card = [cards objectAtIndex:[self.carousel currentItemIndex]];
    
    [ticketsView setCardAccountId:card.accountId];
    
    [RuntimeData commitTicketSourceId:card.uuid];
    //}
}

- (void)setCardForPayAsYouGo
{
    if (payAsYouGoView) {
        if ([cards count] > 0) {
            Card *card = [cards objectAtIndex:[self.carousel currentItemIndex]];
            
            // PayAsYouGo is only used with cards right now, so no need to use ticketSourceId singleton just yet
            [payAsYouGoView setCardUuid:card.uuid];
            [payAsYouGoView setCardAccountId:(NSString *)card.accountId];
            [payAsYouGoView loadAccountData];
            [payAsYouGoView loadLoyaltyInfo];
        }
    }
}

- (void)setCardForHistory
{
    if (historyView) {
        if ([cards count] > 0) {
            Card *card = [cards objectAtIndex:[self.carousel currentItemIndex]];
            
            [historyView setTicketSourceId:card.uuid];
            
            [RuntimeData commitTicketSourceId:card.uuid];
            
            [historyView loadHistory];
        }
    }
}

- (void)loadTicketViewFromLeft:(BOOL)left
{
    
    [ticketsView setCreateCustomTicketsViewController:^BaseTicketsViewController *{
        return [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
    }];
    
    [self setCardForTicketsViewController];
    
    //[self loadViewController:ticketsView fromLeft:left];
}

- (void)showCardDetailsClicked:(int)index {

    
    CardDetailsViewController *cardDetailsView = [[CardDetailsViewController alloc] initWithNibName:@"CardDetailsViewController" bundle:[NSBundle mainBundle]];
    [cardDetailsView setManagedObjectContext:self.managedObjectContext];
    
    
    
    if ([cards count] > 0) {
        //  [cardDetailsView setCard:cardSelected];
    }
    
    [self.navigationController pushViewController:cardDetailsView animated:YES];
}

#pragma mark - Background service declaration and callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[GetCardsService class]]) {
        [self dismissProgressDialog];

        cards = [[Utilities getCards:self.managedObjectContext] copy];
        
        NSUInteger cardsCount = [cards count];
        
        if ([cards count] == 0) {
            [self loadWalletInstructions];
        } else {
            // If an unassigned card had just been added to the wallet just prior to navigating back to this screen,
            // the carousel index will be at Retrieve Cards. Calling setCardForTicketsViewController with this index
            // will result in a crash, so reset it to the index of the last actual card if necessary.
            if ([self.carousel currentItemIndex] == cardsCount) {
                NSLog(@"New card added, set card index back by one....");
                [self.carousel setCurrentItemIndex:cardsCount - 1];
            }
            
            [self setCardForTicketsViewController];
            
            [self.carousel reloadData];
        }
    }
    else if ([service isMemberOfClass:[ReleaseCardService class]]) {
        [self dismissProgressDialog];
        Card *card = [cards objectAtIndex:0];
        [self eraseStoredValue:card.uuid];
        settingsStore = [[SettingsStore alloc] initWithManagedObjectContext:self.managedObjectContext];
        
        // Stash account email
        NSString *email = [settingsStore objectForKey:@"email_preference"];
        
        // Get account
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        
        // Logout out of all accounts
        [CooCooAccountUtilities1 logoutAllAccounts:self.managedObjectContext];
        
        // Remove account
        [CooCooAccountUtilities1 deleteAccountIfIdExists:account.accountId managedObjectContext:self.managedObjectContext];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if([service isMemberOfClass:[GetStatusOfUserWallet class]]){
        [self updateUiBasedOnWalletState];
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    [self threadSuccessWithClass:service response:response];
}

- (void)eraseStoredValue:(NSString *)cardUuid
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_ACCOUNT_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"association LIKE[c] %@", cardUuid];
    //[fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *accounts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (StoredValueAccount *account in accounts) {
        [self.managedObjectContext deleteObject:account];
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error ! %@", error);
    }
}

#pragma mark - Other methods

- (void)loadViewController:(UIViewController *)viewController fromLeft:(BOOL)fromLeft
{
    [self addChildViewController:viewController];
    
    if (!currentViewController) {
        [self.view addSubview:viewController.view];
        
        [viewController.view setFrame:CGRectMake(0,
                                                 self.segmentedContainerView.frame.size.height,
                                                 self.view.frame.size.width,
                                                 self.view.frame.size.height - STATUS_BAR_HEIGHT - HELP_SLIDER_HEIGHT - 8)];
        
        currentViewController = viewController;
        
        return;
    }
    
    NSInteger direction = fromLeft ? 1 : -1;
    
    [viewController.view setFrame:CGRectMake(self.view.frame.size.width * direction,
                                             self.segmentedContainerView.frame.size.height,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height - STATUS_BAR_HEIGHT)];
    
    [self transitionFromViewController:currentViewController toViewController:viewController duration:0.3 options:0 animations:^{
        [viewController.view setFrame:CGRectMake(0,
                                                 self.segmentedContainerView.frame.size.height,
                                                 self.view.frame.size.width,
                                                 self.view.frame.size.height - STATUS_BAR_HEIGHT - HELP_SLIDER_HEIGHT - 8)];
        
        [currentViewController.view setFrame:CGRectMake(currentViewController.view.frame.size.width * direction * -1,
                                                        self.segmentedContainerView.frame.size.height,
                                                        self.view.frame.size.width,
                                                        self.view.frame.size.height - STATUS_BAR_HEIGHT)];
    } completion:^(BOOL finished) {
        [currentViewController removeFromParentViewController];
        
        currentViewController = viewController;
    }];
}

- (void)loadWalletInstructions
{
    [[Singleton sharedManager] logOutHandler];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //    WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:@"WalletInstructionsViewController"
    //                                                                                                                            bundle:[NSBundle mainBundle]];
    //    [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
    //
    //    // Replace the current view controller
    //    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
    //    [viewControllers removeLastObject];
    //    [viewControllers addObject:walletInstructionsViewController];
    //
    //    [[self navigationController] setViewControllers:viewControllers animated:YES];
}

@end
