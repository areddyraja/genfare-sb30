//
//  ChangeEmailViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "ChangeEmailViewController.h"
#import "StoredData.h"
#import "Utilities.h"
#import "Account.h"
#import "CooCooAccountUtilities1.h"


@interface ChangeEmailViewController ()

@end

@implementation ChangeEmailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"change_email"]];
    }
    return self;
}
#pragma mark - View lifecycle
- (void)viewDidLoad{
    [super viewDidLoad];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Change Email" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setPasswordText:nil];
    [self setEmailText:nil];
    [super viewDidUnload];
}
#pragma mark - View controls
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)changeEmail:(id)sender{
     Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    NSString *testpassword = account.password;
    NSString *password = self.passwordText.text;
    NSString *newEmail = self.emailText.text;
    if(testpassword.length >0 && password.length > 0){
    if ((password.length > 0) && ([newEmail length] > 0) && [testpassword isEqualToString:password]) {
        [self.view endEditing:YES];
        [self showProgressDialog];
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        ChangeEmailService *emailService = [[ChangeEmailService alloc] initWithListener:self accountid:newEmail password:password firstName:account.firstName lastName:account.lastName existingEmail:account.emailaddress managedObjectContext:self.managedObjectContext];
        [emailService execute];
    } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                                message:(@"Incorrect Password")
                                                               delegate:nil
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                      otherButtonTitles:nil];
            [alertView show];
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Background service callbacks
- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
      Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    if ([service isMemberOfClass:[ChangeEmailService class]]) {
        [account setEmailaddress:self.emailText.text];
        AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self username:account.emailaddress password:self.passwordText.text];
        [tokenService execute];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"success"]
                                                            message:[Utilities stringResourceForId:@"change_email_success"]
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
                              message:[Utilities stringResourceForId:@"change_email_fail"]
                              delegate:nil
                              cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                              otherButtonTitles:nil];
    [alertView show];
     }
}
@end
