//
//  EmailSettingsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 7/22/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "EmailSettingsViewController.h"
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

NSString *const PREFERENCE_EMAIL_PASSWORD = @"email_password_preference";
NSString *const PREFERENCE_NEW_EMAIL = @"new_email_preference";
NSString *const PREFERENCE_CONFIRM_EMAIL = @"confirm_email_preference";

@interface EmailSettingsViewController ()

@end

@implementation EmailSettingsViewController
{
    SettingsStore *settingsStore;
}

- (id)initWithFile:(NSString *)file specifier:(IASKSpecifier *)specifier {
    if (self = [super init]) {
        [self setTitle:[Utilities stringResourceForId:@"change_email"]];
        
        IASKSettingsReader *settingsReader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"EmailSettings" applicationBundle:[NSBundle baseResourcesBundle]];
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
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Change Email" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [settingsStore setObject:nil forKey:PREFERENCE_EMAIL_PASSWORD];
    [settingsStore setObject:nil forKey:PREFERENCE_NEW_EMAIL];
    [settingsStore setObject:nil forKey:PREFERENCE_CONFIRM_EMAIL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IASKSettingsDelegate methods

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier {
    if ([specifier.key isEqualToString:@"email_submit_button"]) {
        NSString *password = [settingsStore objectForKey:PREFERENCE_EMAIL_PASSWORD];
        NSString *newEmail = [settingsStore objectForKey:PREFERENCE_NEW_EMAIL];
        NSString *confirmEmail = [settingsStore objectForKey:PREFERENCE_CONFIRM_EMAIL];
        
        if (([password length] > 0) && ([newEmail length] > 0) && ([confirmEmail length] > 0)) {
            [self.view endEditing:YES];
            
            if ([newEmail isEqualToString:confirmEmail]) {
                [self showProgressDialog];
                
                Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
                
                ChangeEmailService *emailService = [[ChangeEmailService alloc] initWithListener:self accountid:newEmail password:password firstName:account.firstName lastName:account.lastName existingEmail:account.emailaddress managedObjectContext:self.managedObjectContext];
                
                [emailService execute];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:[Utilities stringResourceForId:@"error"]
                                          message:[Utilities stringResourceForId:@"email_no_match"]
                                          delegate:nil
                                          cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                          otherButtonTitles:nil];
                [alertView show];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                                message:[Utilities stringResourceForId:@"all_fields_required"]
                                                               delegate:nil
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

#pragma mark - View controls

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[ChangeEmailService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"success"]
                                                            message:[Utilities stringResourceForId:@"change_email_success"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    
    NSDictionary *json = (NSDictionary *)response;
    NSString *message = [json valueForKey:@"message"];
    
    if ([message length] > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[message stringByTrimmingCharactersInSet:
                                                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                           delegate:nil
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:[Utilities stringResourceForId:@"error"]
                                  message:[Utilities stringResourceForId:@"change_email_fail"]
                                  delegate:nil
                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end

