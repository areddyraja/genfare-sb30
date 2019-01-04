//
//  PasswordSettingsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 7/23/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "PasswordSettingsViewController.h"
#import "CooCooAccountUtilities1.h"
#import "ForgotLoginViewController.h"
#import "IASKSettingsReader.h"
#import "RuntimeData.h"
#import "SettingsStore.h"
#import "StoredData.h"
#import "Utilities.h"

NSString *const PREFERENCE_CURRENT_PASSWORD = @"current_password_preference";
NSString *const PREFERENCE_NEW_PASSWORD = @"new_password_preference";
NSString *const PREFERENCE_CONFIRM_PASSWORD = @"confirm_password_preference";

@interface PasswordSettingsViewController ()

@end

@implementation PasswordSettingsViewController
{
    SettingsStore *settingsStore;
    NSString *newPassword;
}

- (id)initWithFile:(NSString *)file specifier:(IASKSpecifier *)specifier {
    if (self = [super init]) {
        [self setTitle:[Utilities stringResourceForId:@"change_password"]];
        
        IASKSettingsReader *settingsReader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"PasswordSettings" applicationBundle:[NSBundle baseResourcesBundle]];
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
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Change Password" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [settingsStore setObject:nil forKey:PREFERENCE_CURRENT_PASSWORD];
    [settingsStore setObject:nil forKey:PREFERENCE_NEW_PASSWORD];
    [settingsStore setObject:nil forKey:PREFERENCE_CONFIRM_PASSWORD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IASKSettingsDelegate methods

- (void)settingsViewController:(IASKAppSettingsViewController *)sender buttonTappedForSpecifier:(IASKSpecifier *)specifier {
    if ([specifier.key isEqualToString:@"password_submit_button"]) {
        NSString *currentPassword = [settingsStore objectForKey:PREFERENCE_CURRENT_PASSWORD];
        newPassword = [settingsStore objectForKey:PREFERENCE_NEW_PASSWORD];
        NSString *confirmPassword = [settingsStore objectForKey:PREFERENCE_CONFIRM_PASSWORD];
        
        if (([currentPassword length] > 0) && ([newPassword length] > 0) && ([confirmPassword length] > 0)) {
            [self.view endEditing:YES];
            
            if ([newPassword isEqualToString:confirmPassword]) {
                [self showProgressDialog];
                
                Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
                
                LoginService *loginService = [[LoginService alloc] initWithListener:self username:account.emailaddress password:currentPassword managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
                
                [loginService execute];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                                    message:[Utilities stringResourceForId:@"password_no_match"]
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
    } else if ([specifier.key isEqualToString:@"forgot_password_button"]) {
        ForgotLoginViewController *forgotloginView = [[ForgotLoginViewController alloc] initWithNibName:@"ForgotLoginViewController" bundle:nil];
        [forgotloginView setDefaultEmail:[StoredData userData].email];
        
        [self.navigationController pushViewController:forgotloginView animated:YES];
    }
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    if ([service isMemberOfClass:[LoginService class]]) {
        NSString *currentPassword = [settingsStore objectForKey:PREFERENCE_CURRENT_PASSWORD];
        if ([currentPassword length] > 0) {
            //   UserData *userData = [StoredData userData];
            
            Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
            
            
//            ChangePasswordService *passwordService = [[ChangePasswordService alloc] initWithListener:self
//                                                                                           authToken:account.authToken      // authToken:userData.authToken
//                                                                                           accountid:account.accountId     //  accountid:userData.accountId
//                                                                                               email:account.emailaddress         //    email:userData.email
//                                                                                            password:newPassword];
         //   [passwordService execute];
        }
    } else if ([service isMemberOfClass:[ChangePasswordService class]]) {
        [self dismissProgressDialog];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"success"]
                                                            message:[Utilities stringResourceForId:@"change_password_success"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    [self dismissProgressDialog];

}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[LoginService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"incorrect_password"]
                                                           delegate:nil
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    } else if ([service isMemberOfClass:[ChangePasswordService class]]) {
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
                                      message:[Utilities stringResourceForId:@"change_password_fail"]
                                      delegate:nil
                                      cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

#pragma mark - Other methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

