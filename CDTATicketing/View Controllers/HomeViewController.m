//
//  HomeViewController.m
//  CDTATicketing
//
//  Created by CooCooTech on 6/17/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//
#import "CDTATicketsViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "CooCooAccountUtilities1.h"
#import "AlertsViewController.h"
#import "CardSelectionViewController.h"
#import "CDTARuntimeData.h"
#import "CDTATicketsViewController.h"
#import "HelpViewController.h"
#import "NewTicketPurchaseViewController.h"
#import "AccountSettingsViewController.h"
#import "RoutesViewController.h"
#import "StopsViewController.h"
#import "TripPlannerViewController.h"
#import "WalletInstructionsViewController.h"
#import "HomeCell.h"
#import "CardSelectionCell.h"
#import "SignInViewController.h"
#import "CustomImage.h"
#import "CheckWalletService.h"
#import "CDTA_AccountBasedViewController.h"
#import "Singleton.h"
#import "GetWalletActivity.h"
#import "WalletListAccountBaseViewController.h"
#import "GetProductsService.h"
#import "GetConfigApi.h"
#import "GetOAuthService.h"
#import "HomeViewController+CDTA.h"
#import "HomeViewController+COTA.h"
#import "GetAppUpdateService.h"
#import "WebViewController.h"
#import "GetWalletContents.h"
#import "AssignWalletApi.h"
#import "iRide-Swift.h"

@class UISideMenuNavigationController;
@class GFSideMenuItemsViewController;
@class Constants;

NSTimeInterval const ONE_DAY = 86400;   //One day in seconds = 24 * 60 * 60

@interface HomeViewController ()<UISideMenuNavigationControllerDelegate> {

}
@property (nonatomic, strong) IBOutlet UITableView *tableViewMain;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnImg1;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnImg2;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnImg3;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnImg4;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnImg5;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnImg6;
@property (weak, nonatomic) IBOutlet UIButton *sideMenuButton;
    

@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnRightImg1;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnRightImg2;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnRightImg3;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnRightImg4;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnRightImg5;
@property (nonatomic, weak) IBOutlet FontAwesomeButton *btnRightImg6;

@property (nonatomic, weak) IBOutlet CustomImage *imgDash1;
@property (nonatomic, weak) IBOutlet CustomImage *imgDash2;
@property (nonatomic, weak) IBOutlet CustomImage *imgDash3;
@property (nonatomic, weak) IBOutlet CustomImage *imgDash4;
@property (nonatomic, weak) IBOutlet CustomImage *imgDash5;
@property (nonatomic, weak) IBOutlet CustomImage *imgDash6;

@property (nonatomic, weak) IBOutlet UIView *viAlert;

@property (nonatomic, weak) IBOutlet UIScrollView *scrlMain;



@end

@implementation HomeViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
//        [self.navigationItem setTitleView:titleView];
//    }
//
//    return self;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat screenHeight = [Utilities currentDeviceHeight];
//    [self applyUIChanges];
//    [self prepareLandingViews];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
//    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
//        [self setEdgesForExtendedLayout:UIRectEdgeNone];
//    }
//    dashboardArray = [NSArray arrayWithObjects:@"My Connector",@"Alerts",@"Contact", nil];
//
//    imageArray = [NSArray arrayWithObjects:@".png",@".png", @".png", nil];
    
    // Change title of back button on next screen
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"home"]
//                                                                             style:UIBarButtonItemStyleBordered
//                                                                            target:nil
//                                                                            action:nil];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        CheckWalletService *isWalletExist  = [[CheckWalletService alloc] initWithListener:self emailid:account.emailaddress managedContext:self.managedObjectContext];
        [isWalletExist execute];
    }
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSideMenu:)];
    menuButton.tintColor = UIColor.whiteColor;
    [self.navigationItem setLeftBarButtonItem:menuButton];

}
    
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showProgressDialog];

//    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
//    if(account){
//        [self showProgressDialog];
//        GetConfigApi *contents = [[GetConfigApi alloc]initWithListener:self];
//        [contents execute];
//    }else{
//        [self showSignIn];
//        //TODO - Need to verify if anything further need to be done before returning the control
//        return;
//    }
//    [self performSelector:@selector(setAlertsCount) withObject:nil afterDelay:2.0];
//    [self setAlertsCount];
//
//    [_alertsButton setExclusiveTouch:YES];
//    [_routesButton setExclusiveTouch:YES];
//    [_contactButton setExclusiveTouch:YES];
    
    isCardsServiceRunning = YES;
    launchTicketWallet = NO;
    launchTicketPurchase = NO;
    
//    if([[account isLoggedIn] integerValue]== 1)
//        [self.navigationItem setRightBarButtonItem:accountsButton];
//    else
//        [self.navigationItem setRightBarButtonItem:nil];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    deviceStatusBar = [Utilities statusBarHeight];
    // Set the background for all screens that extend BaseViewController
    [self.view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities mainBgColor]]]];
    [self addHelperBottom];
    //Show side menu for the first time when the app is opened
    if (![[Singleton sharedManager] isAppOpened]) {
        Singleton *singleton = [Singleton sharedManager];
        singleton.isAppOpened = YES;
        [self showSideMenu:nil];
    }
}

-(void)addHelperBottom {
    return;
    //TODO - returning from here needs to be removed when help is needed
    CGRect applicationRect = [[UIScreen mainScreen] bounds];
    //    helpSliderOrigin = applicationRect.size.height + deviceStatusBar - HELP_SLIDER_HEIGHT;
    helpSliderOrigin = applicationRect.size.height - HELP_SLIDER_HEIGHT;
    self.helpSlider = [[HelpSliderView alloc] initWithFrame:CGRectMake(0,
                                                                       helpSliderOrigin,
                                                                       applicationRect.size.width,
                                                                       applicationRect.size.height - NAVIGATION_BAR_HEIGHT)
                                                    isLight:[Utilities isLightTheme]];
    [self.helpSlider initializeWithBarColor:[UIColor whiteColor]];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doubleTapAction:)];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setDelegate:self];
    [self.helpSlider addGestureRecognizer:doubleTap];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [mainWindow addSubview:self.helpSlider];
}

-(void)accountSettings
{
    AccountSettingsViewController *settingsView = [[AccountSettingsViewController alloc] initWithNibName:@"AccountSettingsViewController" bundle:nil];
    settingsView.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:settingsView animated:YES];
}

-(void)applyUIChanges
{
    [self.btnImg1 setTitleColor:[UIColor colorWithRed:15.0/255.0 green:43.0/255.0 blue:91.0/255.0 alpha:1] andFontsize:30.0 andTitle:FACalendar];
    
    [self.btnImg2 setTitleColor:[UIColor colorWithRed:15.0/255.0 green:43.0/255.0 blue:91.0/255.0 alpha:1] andFontsize:30.0 andTitle:FAClockO];
    [self.btnImg3 setTitleColor:[UIColor whiteColor] andFontsize:30.0 andTitle:FAbus];
    [self.btnImg4 setTitleColor:[UIColor whiteColor] andFontsize:30.0 andTitle:FAExclamationTriangle];
    [self.btnImg5 setTitleColor:[UIColor whiteColor] andFontsize:30.0 andTitle:FAUser];
    
    [self.btnRightImg1 setTitleColor:[UIColor colorWithRed:96.0/255.0 green:109.0/255.0 blue:135.0/255.0 alpha:1] andFontsize:15.0 andTitle:FAChevronRight];
    [self.btnRightImg2 setTitleColor:[UIColor colorWithRed:96.0/255.0 green:109.0/255.0 blue:135.0/255.0 alpha:1] andFontsize:15.0 andTitle:FAChevronRight];
    [self.btnRightImg3 setTitleColor:[UIColor colorWithRed:96.0/255.0 green:109.0/255.0 blue:135.0/255.0 alpha:1] andFontsize:15.0 andTitle:FAChevronRight];
    [self.btnRightImg4 setTitleColor:[UIColor colorWithRed:96.0/255.0 green:109.0/255.0 blue:135.0/255.0 alpha:1] andFontsize:15.0 andTitle:FAChevronRight];
    [self.btnRightImg5 setTitleColor:[UIColor colorWithRed:96.0/255.0 green:109.0/255.0 blue:135.0/255.0 alpha:1] andFontsize:15.0 andTitle:FAChevronRight];
    [self.btnRightImg6 setTitleColor:[UIColor colorWithRed:96.0/255.0 green:109.0/255.0 blue:135.0/255.0 alpha:1] andFontsize:15.0 andTitle:FAChevronRight];
    
    
    [self.imgDash1 setCornerRadiusWithRadius:8.0];
    [self.imgDash2 setCornerRadiusWithRadius:8.0];
    [self.imgDash3 setCornerRadiusWithRadius:8.0];
    [self.imgDash4 setCornerRadiusWithRadius:8.0];
    [self.imgDash5 setCornerRadiusWithRadius:8.0];
    [self.imgDash6 setCornerRadiusWithRadius:8.0];
    
    if(IS_IPHONE_6S || IS_IPHONE_6PS)
        [self.scrlMain setScrollEnabled:NO];
    else
        [self.scrlMain setScrollEnabled:YES];
}

-(void)setCornerRadiusWithImage:(UIImageView *)imgView
{
    [imgView.layer setCornerRadius:5.0];
    [imgView.layer setMasksToBounds:YES];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [alertsBadge removeFromSuperview];
}

#pragma mark - View controls

- (void)accounts{
    AccountsViewController *accountsViewController = [[AccountsViewController alloc] initWithNibName:@"AccountsViewController" bundle:[NSBundle baseResourcesBundle]];
    [accountsViewController setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:accountsViewController animated:YES];
}
    
- (IBAction)myTickets:(id)sender{
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        GetProductsService *prodecutservice=[[GetProductsService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
        [prodecutservice execute];
    }
    if (!isCardsServiceRunning) {
        launchTicketWallet = NO;
        [self launchTicketWallet];
    } else {
        launchTicketWallet = YES;
        [self launchTicketWallet];
    }
}
- (IBAction)tripPlanner:(id)sender{
    TripPlannerViewController *tripPlannerView = [[TripPlannerViewController alloc] initWithNibName:@"TripPlannerViewController" bundle:[NSBundle mainBundle]];
    [tripPlannerView setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:tripPlannerView animated:YES];
}
- (IBAction)purchaseTickets:(id)sender{
    if (!isCardsServiceRunning) {
        launchTicketPurchase = NO;
        [self launchTicketPurchase];
    } else {
        launchTicketPurchase = YES;
    }
}
- (IBAction)stops:(id)sender{
    StopsViewController *stopsView = [[StopsViewController alloc] initWithNibName:@"StopsViewController" bundle:[NSBundle mainBundle]];
    [stopsView setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:stopsView animated:YES];
}
- (IBAction)routes:(id)sender{
    RoutesViewController *routesView = [[RoutesViewController alloc] initWithNibName:@"RoutesViewController" bundle:[NSBundle mainBundle]];
    [routesView setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:routesView animated:YES];
}
- (IBAction)contact:(id)sender{
    NSString * nibName = [Utilities HelpViewController];
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
    [helpViewController setManagedObjectContext:self.managedObjectContext];
    [self.navigationController pushViewController:helpViewController animated:NO];
}
#pragma mark - Background service callbacks
- (void)threadSuccessWithClass:(id)service response:(id)response{
     [super threadSuccessWithClass:service response:response];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if([service isMemberOfClass:[GetAppUpdateService class]]){
        
    }    isCardsServiceRunning = NO;
    if ([service isMemberOfClass:[GetCardsService class]]) {
        if (launchTicketWallet) {
            launchTicketWallet = NO;
            launchTicketPurchase = NO;
            [self launchTicketWallet];
        } else if (launchTicketPurchase) {
            launchTicketWallet = NO;
            launchTicketPurchase = NO;
            [self launchTicketPurchase];
        }
    }if ([service isMemberOfClass:[GetConfigApi class]]) {
        CheckWalletService *walletService = [[CheckWalletService alloc] initWithListener:self emailid:account.emailaddress managedContext:self.managedObjectContext];
        [walletService execute];
    }
    if ([service isMemberOfClass:[CheckWalletService class]]){
        NSUserDefaults *deviceid = [NSUserDefaults standardUserDefaults];
        id deviceidNumber = [deviceid stringForKey:@"DEVICE_ID"];
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSMutableArray *walletlist =[[NSMutableArray alloc] initWithArray: [json objectForKey:@"result"]];
        
        Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
        Singleton *Sclass = [Singleton sharedManager];
        //    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
        //                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@' && self.status=='Active'", loggedInAccount.accountId,[Utilities deviceId]]];
        NSPredicate *userpreda = [NSPredicate predicateWithFormat:
                                  [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@'", loggedInAccount.accountId,[Utilities deviceId]]];
        NSArray *usersWalletList = [walletlist filteredArrayUsingPredicate:userpreda];

        if (usersWalletList.count > 0) {
            [self accountBasedSignin:walletlist];
        }else if([deviceidNumber isEqualToString:@"NoDevice"]){
            [[Singleton sharedManager] logOutHandler];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            [self launchTicketWallet];
        }
    }else if ([service isMemberOfClass:[AssignWalletApi class]]){
        [self showProgressDialog];
        GetWalletContents *contents = [[GetWalletContents alloc]initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
        [contents execute];
    }
    if ([service isMemberOfClass:[GetWalletContents class]]){
        GetProductsService *productsService = [[GetProductsService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
        [productsService execute];
    }
    if([service isMemberOfClass:[GetProductsService class]]){
        NSUserDefaults *deviceid = [NSUserDefaults standardUserDefaults];
        id deviceidNumber = [deviceid stringForKey:@"DEVICE_ID"];
        if([deviceidNumber isEqualToString:@"NoDevice"]){
            [[Singleton sharedManager] logOutHandler];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            [self launchTicketWallet];
        }
    }
    if([service isMemberOfClass:[GetOAuthService class]]){
        [self dismissProgressDialog];
    }
    if([service isMemberOfClass:[AuthorizeTokenService class]]){
        [self dismissProgressDialog];
    }
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    if([service isMemberOfClass:[GetAppUpdateService class]]){
        NSLog(@"GetAppUpdateService Failure");
    }
    //    [self threadSuccessWithClass:service response:response];
    
    if([service isMemberOfClass:[GetOAuthService class]]){
        [self dismissProgressDialog];
    }
    if([service isMemberOfClass:[AuthorizeTokenService class]]){
        [self dismissProgressDialog];
    }
    if([service isMemberOfClass:[CheckWalletService class]]){
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        NSString *message = [json valueForKey:@"message"];
        if([message isEqualToString:@"UnAuthorized to get devicewallets"] || [message isEqualToString:@"Not authorized to access resource"]){
            NSString * nibName = [Utilities walletInstructionsViewController];
            WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
            [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
            [self presentViewController:walletInstructionsViewController animated:YES completion:nil];
        }
    }
}

-(BOOL)hasPayAsYouGoProducts {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    
    NSError *error = nil;
    NSArray *totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSArray *filteredProdcutArray = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@)", @"Stored Value"] ];

    if(filteredProdcutArray.count > 0){
        return true;
    }
    
    return false;
}

#pragma mark - Other methods
- (void)launchTicketWallet
{
    //  NSMutableArray *cards = [[NSMutableArray alloc] initWithArray:[Utilities getCards:self.managedObjectContext]];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
//    NSString * walletId = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
//    if(!walletId){
//        //There is no wallet, Delete the account details...
//        [[Singleton sharedManager] logOutHandler];
//        account = nil;
//    }
    if (account) {
        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext] && [self hasPayAsYouGoProducts]){
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
            CDTA_AccountBasedViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"accountbased"];
            accountBasedVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:accountBasedVC animated:NO];
        }else{
            CDTATicketsViewController *ticketsView = [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
            [ticketsView setManagedObjectContext:self.managedObjectContext];
            [self.navigationController pushViewController:ticketsView animated:NO];
        }
    }else{
        [self showSignIn];
//        AddAccountViewController *addAccountViewController = [[AddAccountViewController alloc]initWithNibName:@"AddAccountViewController" bundle:[NSBundle mainBundle]];
//        // signInViewController.title = @"Existing Customer";
//        [addAccountViewController setManagedObjectContext:self.managedObjectContext];
//        [self.navigationController pushViewController:addAccountViewController animated:YES];
    }
}

- (void)showSignIn {
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    NSAssert(NO,@"Trying to show user login");
    
    SignInViewController *signInController = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:[NSBundle mainBundle]];
    [signInController setManagedObjectContext:self.managedObjectContext];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signInController];
    [self presentViewController:navController animated:YES completion:Nil];
    //[self.navigationController pushViewController:signInController animated:YES];
}

- (void)launchTicketPurchase
{
    NSMutableArray *cards = [[NSMutableArray alloc] initWithArray:[Utilities getCards:self.managedObjectContext]];
    
    if ([cards count] > 0) {
        CardSelectionViewController *cardSelectionView = [[CardSelectionViewController alloc] initWithNibName:@"CardSelectionViewController" bundle:[NSBundle mainBundle]];
        [cardSelectionView setManagedObjectContext:self.managedObjectContext];
        
        [self.navigationController pushViewController:cardSelectionView animated:YES];
    } else {
        NSString * nibName = [Utilities walletInstructionsViewController];
        WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName
                                                                                                                                bundle:[NSBundle mainBundle]];
        [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
        [self.navigationController pushViewController:walletInstructionsViewController animated:YES];
    }
}

-(void)accountBasedSignin:(NSArray*)walletList{
    Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
    Singleton *Sclass = [Singleton sharedManager];
    //    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
    //                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@' && self.status=='Active'", loggedInAccount.accountId,[Utilities deviceId]]];
    NSPredicate *userpreda = [NSPredicate predicateWithFormat:
                              [NSString stringWithFormat:@"self.personId == %@ && self.deviceUUID == '%@'", loggedInAccount.accountId,[Utilities deviceId]]];
    NSArray *usersWalletList = [walletList filteredArrayUsingPredicate:userpreda];
    if(usersWalletList.count>0){
        NSDictionary * walletDict = usersWalletList.firstObject;
        [[NSUserDefaults standardUserDefaults]setObject:walletDict[@"walletId"] forKey:@"WALLET_ID"];
        [[NSUserDefaults standardUserDefaults]setObject:Sclass.userwallet.cardType forKey:@"WALLETCARDTYPE"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        WalletContent *Wcontent=[[WalletContent alloc]initWithDictionary:walletDict];
        [Sclass setUserWalletFromApi:Wcontent];
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        account.walletname=Wcontent.nickname;
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        }
        BOOL walletAssigned = NO;
        for (NSDictionary *dict in walletList) {
            NSString * deviceId = [dict valueForKey:@"deviceId"];
            if (deviceId != nil && ![deviceId isKindOfClass:[NSNull class]] && deviceId.length > 0 && [[Utilities deviceId] isEqualToString:deviceId]) {
                NSLog(@"Wallet Assigned to Current Device");
                walletAssigned = YES;
                break;
            }else{
                walletAssigned = NO;
            }
        }
        if (walletAssigned == YES) {
            [self showProgressDialog];
            GetWalletContents *contents = [[GetWalletContents alloc]initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
            [contents execute];
        }else{
            [self showProgressDialog];
            AssignWalletApi *assignWalletApi = [[AssignWalletApi alloc]  initWithListener:self managedObjectContext:self.managedObjectContext accoundUuid:[Utilities deviceId]];
            [assignWalletApi execute];
        }
    }else{
        NSMutableArray *usersWalletList = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in walletList) {
            NSString* value = dict[@"deviceUUID"];
            NSString *status = dict[@"status"];
            if (([value isKindOfClass:[NSNull class]]||value.length==0)&&[status isEqualToString:@"Active"]) {
                [usersWalletList addObject:dict];
            }
        }
        if(usersWalletList.count>0){
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
            WalletListAccountBaseViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"wallet"];
            accountBasedVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:accountBasedVC animated:true];
        }else{
            NSString * nibName = [Utilities walletInstructionsViewController];
            WalletInstructionsViewController *walletInstructionsViewController = [[WalletInstructionsViewController alloc] initWithNibName:nibName bundle:[NSBundle mainBundle]];
            [walletInstructionsViewController setManagedObjectContext:self.managedObjectContext];
            [self.navigationController pushViewController:walletInstructionsViewController animated:NO];
        }
    }
}

#pragma mark - UITableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dashboardArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    CardSelectionCell *cell = (CardSelectionCell *)[tableView dequeueReusableCellWithIdentifier:CARD_SELECTION_CELL];
    //
    //    if (cell == nil) {
    //        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:CARD_SELECTION_CELL owner:self options:nil];
    //        cell = [nib objectAtIndex:0];
    //    }
    //
    //
    //    [cell.nicknameLabel setText:@"cellLabel"];
    
    HomeCell *cell = (HomeCell *)[tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HomeCell"];
    }
    
    
    [cell.lblName setText:[dashboardArray objectAtIndex:indexPath.row]];
    
    
    return [UITableViewCell new];
}


@end
