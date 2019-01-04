
//
//  AppSettingsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 7/21/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "IASKSettingsReader.h"
#import "NSBundle+BaseResourcesBundle.h"
#import "RuntimeData.h"
#import "SettingsStore.h"
#import "StoredData.h"
#import "Utilities.h"

@interface AppSettingsViewController ()

@end

@implementation AppSettingsViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    self = [super init];
    
    if (self) {
        // TODO: TEMPORARY WORKAROUND for passing managedObjectContext between screens from within AppSettingsViewController
        [[RuntimeData instance] setManagedObjectContext:managedObjectContext];
        
        [self setTitle:[Utilities stringResourceForId:@"account_settings"]];
        
        IASKSettingsReader *settingsReader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root" applicationBundle:[NSBundle mainBundle]];
        
        if (!settingsReader) {
            settingsReader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"Root" applicationBundle:[NSBundle baseResourcesBundle]];
        }
        
        [settingsReader setShowPrivacySettings:NO];
        
        [self setSettingsReader:settingsReader];
        
        [self setSettingsStore:[[SettingsStore alloc] initWithManagedObjectContext:managedObjectContext]];
        
        /*UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"logout_title"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(logout)];
        [self.navigationItem setRightBarButtonItem:logoutButton];*/
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Change title of back button on next screen
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"back"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    self.delegate = self;
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Account Settings" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set dummy hiddenKeys to force IASKAppSettingsViewController's tableView to reload (in case Account data such as email has changed)
    [self setHiddenKeys:[NSSet setWithObjects:@"dummy_to_call_reload_table", nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*#pragma mark - View controls

- (void)logout
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"logout_title"]
                                                        message:[Utilities stringResourceForId:@"logout_msg"]
                                                       delegate:self
                                              cancelButtonTitle:[Utilities stringResourceForId:@"no"]
                                              otherButtonTitles:[Utilities stringResourceForId:@"yes"], nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [StoredData removeUserData];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}*/

@end
