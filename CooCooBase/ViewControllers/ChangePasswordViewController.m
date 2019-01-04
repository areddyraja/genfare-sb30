//
//  ChangePasswordViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "ForgotLoginViewController.h"
#import "StoredData.h"
#import "Utilities.h"
#import "Account.h"
#import "CooCooAccountUtilities1.h"
#import "LoginService.h"
#import "CooCooAccountUtilities1.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"change_password"]];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Change Password" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(goToForgotPassword:)];
    [self.forgotPasswordLabel addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setPasswordText:nil];
    [self setConfirmPasswordText:nil];
    [self setForgotPasswordLabel:nil];
    [super viewDidUnload];
}

#pragma mark - View controls

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)changePassword:(id)sender {
     Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    NSString *password = account.password;
    
    NSString *newPassword = self.passwordText.text;
    NSString *confirmPassword = self.confirmPasswordText.text;
    NSString *oldpassword = self.currentPasswordText.text;
    if (newPassword.length > 0 && confirmPassword.length > 0 && oldpassword.length >0) {
        if (([newPassword length] > 0) && ([confirmPassword length] > 0)) {
            [self.view endEditing:YES];
            if ([newPassword isEqualToString:confirmPassword] && [password isEqualToString:oldpassword]) {
                [self showProgressDialog];
                ChangeEmailService *emailService = [[ChangeEmailService alloc] initWithListener:self accountid:account.emailaddress password:newPassword firstName:account.firstName lastName:account.lastName existingEmail:account.emailaddress managedObjectContext:self.managedObjectContext];
                [emailService execute];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                                    message:[Utilities stringResourceForId:@"password_no_match"]
                                                                   delegate:nil
                                                          cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"all_fields_required"]
                                                           delegate:nil
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
}
- (void)goToForgotPassword:(id)sender{
    ForgotLoginViewController *forgotloginView = [[ForgotLoginViewController alloc] initWithNibName:@"ForgotLoginViewController" bundle:nil];
    [self.navigationController pushViewController:forgotloginView animated:YES];
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[LoginService class]]) {
        NSString *newPassword = self.passwordText.text;
        NSString *confirmPassword = self.confirmPasswordText.text;
        NSData *nsdata = [newPassword
                          dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        if (([newPassword length] > 0) && ([confirmPassword length] > 0)) {
            [self.view endEditing:YES];
            if ([newPassword isEqualToString:confirmPassword]) {
                [self showProgressDialog];
                
//                ChangePasswordService *passwordService = [[ChangePasswordService alloc] initWithListener:self
//                                                                                               authToken:account.authToken
//                                                                                               accountid:account.accountId
//                                                                                                   email:account.emailaddress
//                                                                                                password:newPassword];
//                [passwordService execute];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                                    message:[Utilities stringResourceForId:@"password_no_match"]
                                                                   delegate:nil
                                                          cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
    
    if ([service isMemberOfClass:[ChangeEmailService class]]) {
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        [account setPassword:self.passwordText.text];
    AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self username:account.emailaddress password:self.passwordText.text];
        [tokenService execute];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"success"]
                                                            message:[Utilities stringResourceForId:@"change_password_success"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response{
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[ChangeEmailService class]]) {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[Utilities stringResourceForId:@"error"]
                              message:[Utilities stringResourceForId:@"change_password_fail"]
                              delegate:nil
                              cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                              otherButtonTitles:nil];
    [alertView show];
    }
}

#pragma mark - Other methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

