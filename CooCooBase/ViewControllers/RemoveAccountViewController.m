//
//  RemoveAccountViewController.m
//  CooCooBase
//

#import "RemoveAccountViewController.h"
#import "CooCooAccountUtilities1.h"
#import "AppConstants.h"
#import "AppSettingsViewController.h"
#import "IASKSettingsReader.h"
#import "IASKSettingsStoreUserDefaults.h"
#import "NSBundle+BaseResourcesBundle.h"
#import "RuntimeData.h"
#import "SettingsStore.h"
#import "StoredData.h"
#import "Utilities.h"
//#import "AccountsViewController.h"


NSString *const PREFERENCE_EMAIL = @"email_preference";

@interface RemoveAccountViewController ()

@end

@implementation RemoveAccountViewController
{
    SettingsStore *settingsStore;
}

- (id)initWithFile:(NSString *)file specifier:(IASKSpecifier *)specifier {
    if (self = [super init]) {
        [self setTitle:[Utilities stringResourceForId:@"remove_account"]];
        
        IASKSettingsReader *settingsReader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"RemoveAccount" applicationBundle:[NSBundle baseResourcesBundle]];
        [settingsReader setShowPrivacySettings:NO];
        
        [self setSettingsReader:settingsReader];
        
        // TODO: TEMPORARY WORKAROUND for passing managedObjectContext between screens from within AppSettingsViewController
        self.managedObjectContext = [[RuntimeData instance] managedObjectContext];
        
        settingsStore = [[SettingsStore alloc] initWithManagedObjectContext:self.managedObjectContext];
        [self setSettingsStore:settingsStore];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Remove Account" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//     [settingsStore setObject:nil forKey:PREFERENCE_EMAIL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IASKSettingsDelegate methods

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier {
    
    if ([specifier.key isEqualToString:@"yes_button"]) {
        
        // Stash account email
        NSString *email = [settingsStore objectForKey:PREFERENCE_EMAIL];

        // Get account
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        
        // Logout out of all accounts
        [CooCooAccountUtilities1 logoutAllAccounts:self.managedObjectContext];
        
        // Remove account
        [CooCooAccountUtilities1 deleteAccountIfIdExists:account.accountId managedObjectContext:self.managedObjectContext];
        
        // Go back to accounts view controller
//        for (AccountsViewController *vc in [self.navigationController viewControllers]) {
//            if ([vc isKindOfClass: [AccountsViewController class]]){
//                // vc.itemselected = head;
//                [[self navigationController] popToViewController:vc animated:YES];
//            }
//        }

    } else {   // "No" button, go back
            
        [self.navigationController popViewControllerAnimated:YES];
            
    }
    
}


@end
