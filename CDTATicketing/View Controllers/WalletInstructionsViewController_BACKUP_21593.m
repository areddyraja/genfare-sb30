//
//  WalletInstructionsViewController.m
//  CDTATicketing
//
//  Created by CooCooTech on 9/20/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "WalletInstructionsViewController.h"
#import "CDTATicketsViewController.h"
#import "FontAwesomeButton.h"
#import "NSString+FontAwesome.h"
#import "AppDelegate.h"
#import "Singleton.h"
#import "GetWalletsService.h"
#import "CDTA_AccountBasedViewController.h"

@interface WalletInstructionsViewController ()
@property (weak, nonatomic) IBOutlet UIView *viFullCardName;
@property (weak, nonatomic) IBOutlet UIView *viCardDescription;
@property (weak, nonatomic) IBOutlet FontAwesomeButton *btnDescription;
@property (weak, nonatomic) IBOutlet FontAwesomeButton *btnCardName;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCreateNewCard;

@end

@implementation WalletInstructionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Get Started"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
        
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Account *loggedInAccount = [CooCooAccountUtilities1 loggedInAccount:self.managedObjectContext];
    // Do any additional setup after loading the view from its nib.
    
    // TODO: As of Xcode 7.3, it looks like setting the background color in the .xib no longer overrides the setting from BaseViewController
    //       Manually set the background here for now
    
    
    [self.view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"table_bg"]]];
    [self applyUIChanges];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   // GetCardsService *cardsService = [[GetCardsService alloc] initWithListener:self
//                                                                   walletUuid:[Utilities walletId]
//                                                         managedObjectContext:self.managedObjectContext];
    //[cardsService execute];
  
//    AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self username:self.emailAddress.text password:self.password.text];
//    [tokenService execute];
   

}

-(void)applyUIChanges
{
    [self.btnCardName setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] andFontsize:20.0 andTitle:FACreditCard];
    [self.btnDescription setTitleColor:[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1] andFontsize:20.0 andTitle:FAFileTextO];
    
    self.viCardDescription.layer.cornerRadius = 8.0;
    self.viCardDescription.layer.borderWidth = 1.0;
    self.viCardDescription.layer.borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1].CGColor;
    self.viCardDescription.layer.masksToBounds = YES;
    
    self.viFullCardName.layer.cornerRadius = 8.0;
    self.viFullCardName.layer.borderWidth = 1.0;
    self.viFullCardName.layer.borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1].CGColor;
    self.viFullCardName.layer.masksToBounds = YES;
    
    self.btnCreateNewCard.layer.cornerRadius = 8.0;
    self.btnCreateNewCard.layer.masksToBounds = YES;
    
    // UIImage *userImage = [UIImage loadOverrideImageNamed:@"existing-and-newuser"];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View controls

- (IBAction)createNewCard:(id)sender {
    NSString *cardName;
    NSString *cardDescription;
    
    if(self.cardName.text.length > 0)
        cardName = self.cardName.text;
  
    
    if(self.cardDescription.text.length > 0)
        cardDescription = self.cardDescription.text;
   
    
    if (([cardName length] > 0) && ([cardDescription length] > 0)) {
        
//        RequestNewWalletService *newCardService = [[RequestNewWalletService alloc]initWithListener:self managedObjectContext:self.managedObjectContext];
//         [newCardService execute];
        [self showProgressDialog];
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        GetWalletsService * walletsService = [[GetWalletsService alloc] initWithListener:self nickname:cardName managedObjectContext:self.managedObjectContext uuid:[[[UIDevice currentDevice]identifierForVendor]UUIDString] personId:account.id];
        [walletsService execute];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"all_fields_required"]
                                                           delegate:nil
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)claimProvisionedCard:(id)sender {
    ClaimCardsViewController *claimCardsViewController = [[ClaimCardsViewController alloc] initWithNibName:@"ClaimCardsViewController"
                                                                                                    bundle:[NSBundle baseResourcesBundle]];
    [claimCardsViewController setManagedObjectContext:self.managedObjectContext];
    
    [self.navigationController pushViewController:claimCardsViewController animated:YES];
}

#pragma mark - Background service declaration and callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[RequestNewCardService class]]) {
        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]){
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
            CDTA_AccountBasedViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"accountbased"];
            accountBasedVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:accountBasedVC animated:true];
        }
        else{
        CDTATicketsViewController *ticketsViewController = [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
        [ticketsViewController setManagedObjectContext:self.managedObjectContext];
        
        //Replace the current view controller
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
        [viewControllers removeLastObject];
        [viewControllers addObject:ticketsViewController];
        
        [[self navigationController] setViewControllers:viewControllers animated:YES];
<<<<<<< HEAD
=======
        }
>>>>>>> e29d61d8953d3e5fd1d713d089b869a2b2352467
        
    } else if ([service isMemberOfClass:[GetCardsService class]]) {
        // If card was claimed and user returns to this screen, go straight to ticket wallet
        NSMutableArray *cards = [[NSMutableArray alloc] initWithArray:[Utilities getCards:self.managedObjectContext]];
        
        NSLog(@"SUCCESS cards count: %lu", (unsigned long)[cards count]);
        
        if ([cards count] > 0) {
            if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]){
                UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
                CDTA_AccountBasedViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"accountbased"];
                accountBasedVC.managedObjectContext=self.managedObjectContext;
                [self.navigationController pushViewController:accountBasedVC animated:true];
            }
            else{
            CDTATicketsViewController *ticketsViewController = [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
            [ticketsViewController setManagedObjectContext:self.managedObjectContext];
            
            // Replace the current view controller
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
            [viewControllers removeLastObject];
            [viewControllers addObject:ticketsViewController];
            
            [[self navigationController] setViewControllers:viewControllers animated:YES];
            }
        }
    }
    
    else if ([service isMemberOfClass:[AssignCardService class]]) {
        [self dismissProgressDialog];
        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]){
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
            CDTA_AccountBasedViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"accountbased"];
            accountBasedVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:accountBasedVC animated:true];
        }
        else{
        CDTATicketsViewController *ticketsViewController = [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
        [ticketsViewController setManagedObjectContext:self.managedObjectContext];
        
        //Replace the current view controller
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
        [viewControllers removeLastObject];
        [viewControllers addObject:ticketsViewController];
        
        [[self navigationController] setViewControllers:viewControllers animated:YES];
        }
        
        
       //  [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([service isMemberOfClass:[GetWalletsService class]]){
        [self dismissProgressDialog];
        if([[Singleton sharedManager] isProfileAccountBased:self.managedObjectContext]){
            UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AccountBased" bundle:[NSBundle mainBundle]];
            CDTA_AccountBasedViewController *accountBasedVC=[storyBoard instantiateViewControllerWithIdentifier:@"accountbased"];
            accountBasedVC.managedObjectContext=self.managedObjectContext;
            [self.navigationController pushViewController:accountBasedVC animated:true];
        }
        else{
        CDTATicketsViewController *ticketsViewController = [[CDTATicketsViewController alloc] initWithNibName:@"CDTATicketsViewController" bundle:[NSBundle mainBundle]];
        [ticketsViewController setManagedObjectContext:self.managedObjectContext];
        
        //Replace the current view controller
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
        [viewControllers removeLastObject];
        [viewControllers addObject:ticketsViewController];
        
        [[self navigationController] setViewControllers:viewControllers animated:YES];
        NSLog(@"GetWalletsService succeeded");
        }
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[RequestNewCardService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to add a new card to your device. Please try again later."
                                                           delegate:self
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
    }else if ([service isMemberOfClass:[GetWalletsService class]]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to get your wallet. Please try again later."
                                                           delegate:self
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
