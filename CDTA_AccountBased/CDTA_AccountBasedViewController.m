//
//  CDTA_AccountBasedViewController.m
//  CDTATicketing
//
//  Created by Omniwyse on 4/4/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "CDTA_AccountBasedViewController.h"
#import "CDTA_AB_PassesViewController.h"
#import "CDTA_AB_PayAsYouGoViewController.h"
#import "CDTA_AB_HistoryViewController.h"
#import "TicketHistoryViewController.h"
#import "CAPSPageMenu.h"
#import "AppDelegate.h"
#import "CustomAlertViewController.h"
#import "AccountBalance.h"
#import "TicketsListViewController.h"
#import "Singleton.h"
#import "CardDetailsViewController.h"
#import "PurchasePassesViewController.h"
#import  "GetProductsService.h"
#import "AppConstants.h"
#import "iRide-Swift.h"
#import "GetStatusOfUserWallet.h"

@interface CDTA_AccountBasedViewController ()<CAPSPageMenuDelegate,CustomAlertViewControllerDelegate>{
}
@property CAPSPageMenu *pagemenu;
@property (weak, nonatomic) IBOutlet UIView *pageMenuHolder;
@property (weak, nonatomic) IBOutlet UILabel *walletTitleLabel;

@end

@implementation CDTA_AccountBasedViewController



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}


-(void)setupPagemenu{
    [self setTitle:[Utilities stringResourceForId:@"my_tickets"]];

    CDTA_AB_PassesViewController *passesVC=[self.storyboard instantiateViewControllerWithIdentifier:@"passes"];
    CDTA_AB_PayAsYouGoViewController *payasyougoVC=[self.storyboard instantiateViewControllerWithIdentifier:@"payasyougo"];
    CDTA_AB_HistoryViewController *historyVC=[self.storyboard instantiateViewControllerWithIdentifier:@"history"];
    
    
    payasyougoVC.managedObjectContext=self.managedObjectContext;
    passesVC.managedObjectContext=self.managedObjectContext;
    historyVC.managedObjectContext=self.managedObjectContext;
  
    
    passesVC.title=@"Passes";
    payasyougoVC.title=@"Pay As You Go";
    historyVC.title= [Utilities stringResourceForId:[Utilities historyTitle]];

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
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor grayColor],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"Montserrat" size:15.0],
                                 CAPSPageMenuOptionMenuHeight: @(50.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(SCREEN_WIDTH/pageMenuWidth),
                                 CAPSPageMenuOptionCenterMenuItems: @(NO),
                                 };
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    
    CGFloat pageMenuY = 240.0;
    
    self.pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:@[passesVC,payasyougoVC,historyVC] frame:CGRectMake(0.0, pageMenuY,screenWidth, screenHeight - pageMenuY ) options:parameters];
    
    self.pagemenu.delegate = self;
    self.pagemenu.view.layer.cornerRadius = 0;
    self.pagemenu.view.layer.borderWidth = 2;
    self.pagemenu.view.layer.borderColor = [AppDelegate colorFromHexString:@"#f5f5f5"].CGColor;
    self.pagemenu.view.layer.shadowColor = [[UIColor clearColor] CGColor];
    self.pagemenu.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.pagemenu.view.layer.shadowOpacity = 0.5f;
    
    [self.view addSubview:self.pagemenu.view];
    
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    NSString * walletId = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",walletId]];
    NSError *error = nil;
    walletarray = [self.managedObjectContext executeFetchRequest:request error:&error];
//    Wallet * wallet = (Wallet *)[walletarray lastObject];
    WalletContent *walletContent  = (WalletContent *)[walletarray lastObject];
     self.walletTitleLabel.text=walletContent.nickname.length==0?@"Stored Value":[NSString stringWithFormat:@"%@ - %@",walletContent.nickname,walletContent.status];
//    cardnameLabel.text=wallet.nickname.length==0?@"Stored Value":wallet.nickname;

 
}

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
      [self dismissProgressDialog];
    if([service isMemberOfClass:[AccountBalance class]]){
        NSString *accbalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountbalance"];
         [self updateBalanceViewColor:accbalance];
        fundsLabel.text=[NSString stringWithFormat:@"$%.2f",accbalance.floatValue];
    }else if([service isMemberOfClass:[GetStatusOfUserWallet class]]){
        [self updateUiBasedOnWalletState];
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [super threadErrorWithClass:service response:response];
      [self dismissProgressDialog];
}

-(void)sideMenuWillAppearWithMenu:(UISideMenuNavigationController *)menu animated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUISideMenuIsVisible" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        GetProductsService *prodecutservice=[[GetProductsService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
        [prodecutservice execute];
    }
    
    [[Singleton sharedManager] setRef_AccountBasedViewController:self];

    [addFundsButton addTarget:self action:@selector(addFunds) forControlEvents:UIControlEventTouchUpInside];
    cardManagementButton.layer.cornerRadius = 5.0;
    [cardManagementButton.layer setMasksToBounds:YES];
//    [cardManagementButton setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]]];
    
    addFundsButton.layer.cornerRadius = 5.0;
    [addFundsButton.layer setMasksToBounds:YES];
//    [addFundsButton setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]]];
    [cardManagementButton addTarget:self action:@selector(goToCardsDetail) forControlEvents:UIControlEventTouchUpInside];

    
    
    NSString *accbalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountbalance"];
    [self updateBalanceViewColor:accbalance];
    fundsLabel.text=[NSString stringWithFormat:@"Account Balance : $%.2f",accbalance.floatValue];
    
    
//    UIBarButtonItem *btnHome = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"] style:UIBarButtonItemStylePlain target:self action:@selector(homeBtnHandler)];
//    self.navigationItem.leftBarButtonItem = btnHome;
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
//
//    UIBarButtonItem *btnLogOut = [[UIBarButtonItem alloc] initWithTitle:@"LOGOUT"
//                                                                  style:UIBarButtonItemStyleBordered
//                                                                 target:self
//                                                                 action:@selector(logOutCheck)];
////    UIBarButtonItem *btnLogOut = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout.png"] style:UIBarButtonItemStylePlain target:self action:@selector(logOutCheck)];
//
//    self.navigationItem.rightBarButtonItem = btnLogOut;
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
//    self.navigationItem.leftBarButtonItem = btnHome;
   
    
    [self setupPagemenu];

    // Do any additional setup after loading the view.
}
-(void)homeBtnHandler
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)updateBalanceViewColor : (NSString *)accbalance{
    if ([accbalance floatValue] < 5.0f) {
        [addFundsView setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"balance_red"]]];
    }else {
        [addFundsView setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"balance_green"]]];
    }
}

-(void)logOutCheck
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:[Utilities confirmLogoutTitle]] message:[Utilities stringResourceForId:[Utilities confirmLogoutMessage]] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *logOutAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:[Utilities logoutButtonTitle]] style:UIAlertViewStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[Singleton sharedManager] logOutHandler];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:[Utilities cancelButtonTitle]] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Do nothing
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:logOutAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)goToCardsDetail  {
     CardDetailsViewController *cardDetailsView = [[CardDetailsViewController alloc] initWithNibName:@"CardDetailsViewController" bundle:[NSBundle mainBundle]];
    [cardDetailsView setManagedObjectContext:self.managedObjectContext];
    
    
    
    [self.navigationController pushViewController:cardDetailsView animated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Text Screens" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    [[Singleton sharedManager] setCurrentNVC:self.navigationController];
    AccountBalance *balance=[[AccountBalance alloc] initWithListener:self];
    [balance execute];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if(account){
        GetStatusOfUserWallet *getStatusOfUserWallet = [[GetStatusOfUserWallet alloc] initWithListener:self managedObjectContext:self.managedObjectContext withwalletid:[[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"]];
        [getStatusOfUserWallet execute];
    }
    
    NSString *cardtypevalue = [[NSUserDefaults standardUserDefaults] objectForKey:@"WALLETCARDTYPE"];
    if(![cardtypevalue.lowercaseString containsString:@"full"]){
        cardlogoImgview.image=[UIImage imageNamed:@"pass.png"];
    }
    else{
//             cardlogoImgview.image=[UIImage imageNamed:@"splash_logo.png"];
        cardlogoImgview.image=[UIImage imageNamed:@"pass.png"];

     }
    
    NSString *accbalance = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountbalance"];
    [self updateBalanceViewColor:accbalance];
    fundsLabel.text=[NSString stringWithFormat:@"$%.2f",accbalance.floatValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTickets" object:nil];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    NSString * walletId = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",walletId]];
    [self updateUiBasedOnWalletState];
    self.view.backgroundColor = UIColor.blackColor;
    
    [self updateNavBarUI];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AccountBaseViewController *controller = self.pagemenu.childViewControllers.firstObject;
    if ([controller respondsToSelector:@selector(refreshView)] ){
        [controller refreshView];
    }
}

-(void)updateNavBarUI {
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Hamburger"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSideMenu:)];
    menuButton.tintColor = UIColor.whiteColor;
    [self.navigationItem setLeftBarButtonItem:menuButton];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@NavBarLogo",[[Utilities tenantId] lowercaseString]]]];
}

-(void)updateUiBasedOnWalletState{
    walletStatusId = [Utilities getCurrentWalletState:self.managedObjectContext];
    if (walletStatusId == WALLET_STATUS_DEACTIVATED) {
        [addFundsButton setUserInteractionEnabled:NO];
        [addFundsButton setBackgroundColor:[UIColor lightGrayColor]];
    }else if (walletStatusId == WALLET_STATUS_ACTIVE || walletStatusId == WALLET_STATUS_EXPIRED){
        [addFundsButton setUserInteractionEnabled:YES];
        [addFundsButton setBackgroundColor:[UIColor colorWithHexString:@"#6aa826"] ];
    }else{
        [addFundsButton setBackgroundColor:[UIColor lightGrayColor]];
    }
}

-(void)addFunds{
    if (walletStatusId == WALLET_STATUS_ACTIVE) {
        CustomAlertViewController *popup=[self.storyboard instantiateViewControllerWithIdentifier:@"popup"];
        popup.delegate=self;
        popup.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        popup.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        [self presentViewController:popup animated:YES completion:^{
        }];
    }else{
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"walletStatus_title"]
                                                     message:[Utilities stringResourceForId:@"walletStatus_msg"]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                           otherButtonTitles:nil];
        [singleAlertView show];
    }
 }

-(void)selectedOption:(NSInteger)selectedIndex{
    switch (selectedIndex) {
        case 1:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountBased" bundle:nil];
            PurchasePassesViewController *newView = [storyboard instantiateViewControllerWithIdentifier:@"PassesViewContoller"];
            [self.navigationController pushViewController:newView animated:YES];
        }
            break;
        case 0:
        {
            TicketsListViewController *ticketview = [[TicketsListViewController alloc]initWithNibName:@"TicketsListViewController" bundle:nil];
            [ticketview setManagedObjectContext:self.managedObjectContext];
            
            [self.navigationController pushViewController:ticketview animated:YES];
        }
            break;
            
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}


- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    
}

- (void)setNeedsFocusUpdate {
    
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return true;
}

- (void)updateFocusIfNeeded {
    
}

@end
