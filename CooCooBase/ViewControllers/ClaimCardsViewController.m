//
//  ClaimCardsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 9/19/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "ClaimCardsViewController.h"
#import "CooCooAccountUtilities1.h"
#import "EligibleCardsViewController.h"
#import "Utilities.h"
#import "ForgotLoginViewController.h"

@interface ClaimCardsViewController ()

@end

@implementation ClaimCardsViewController
{
    NSArray *accounts;
    UIAlertController *alertController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:[Utilities stringResourceForId:@"claim_cards"]];
    
    accounts = [CooCooAccountUtilities1 allAccounts:self.managedObjectContext];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(goToForgotPassword:)];
    [self.forgotPassword addGestureRecognizer:tapGesture];
}

- (void)goToForgotPassword:(id)sender
{
    ForgotLoginViewController *forgotloginView = [[ForgotLoginViewController alloc] initWithNibName:@"ForgotLoginViewController" bundle:nil];
    
    [self.navigationController pushViewController:forgotloginView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.selectOrEnterEmail) {
        UIViewController *popUpViewController = [[UIViewController alloc] init];
        [popUpViewController.view setUserInteractionEnabled:YES];
        
        NSUInteger accountsCount = [accounts count];
        
        CGRect tableViewRect;
        
        if (accountsCount > 0) {
            CGRect tableViewRect;
            if (accountsCount < 4) {
                tableViewRect = CGRectMake(0.0f, 0.0f, 272.0f, 100.0f);
            } else if (accountsCount < 6) {
                tableViewRect = CGRectMake(0.0f, 0.0f, 272.0f, 150.0f);
            } else if (accountsCount < 8) {
                tableViewRect = CGRectMake(0.0f, 0.0f, 272.0f, 200.0f);
            } else {
                tableViewRect = CGRectMake(0.0f, 0.0f, 272.0f, 250.0f);
            }
            
            UITableView *alertTableView = [[UITableView alloc] initWithFrame:tableViewRect];
            [alertTableView setDelegate:self];
            [alertTableView setDataSource:self];
            [alertTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
            [alertTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            [alertTableView setUserInteractionEnabled:YES];
            [alertTableView setAllowsSelection:YES];
            
            [popUpViewController.view addSubview:alertTableView];
        } else {
            tableViewRect = CGRectMake(0.0f, 0.0f, 272.0f, 30.0f);
            
            UITextView *noAccounts = [[UITextView alloc] initWithFrame:tableViewRect];
            [noAccounts setBackgroundColor:[UIColor whiteColor]];
            [noAccounts setTextAlignment:NSTextAlignmentCenter];
            [noAccounts setText:[Utilities stringResourceForId:@"no_email_history"]];
            
            [popUpViewController.view addSubview:noAccounts];
        }
        
        UITextField *newEmail = [[UITextField alloc] initWithFrame:CGRectMake(8.0f,
                                                                              120.0f,
                                                                              256.0f,
                                                                              40.0f)];
        [newEmail setBackgroundColor:[UIColor whiteColor]];
        [newEmail setKeyboardType:UIKeyboardTypeEmailAddress];
        [newEmail setPlaceholder:[Utilities stringResourceForId:@"or_enter_new_email"]];
        
        [popUpViewController.view addSubview:newEmail];
        
        [popUpViewController setPreferredContentSize:CGSizeMake(272.0f,
                                                                newEmail.frame.origin.y + newEmail.frame.size.height)];
        
        
        alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:@"select_email"]
                                                              message:@""
                                                       preferredStyle:UIAlertControllerStyleAlert];
        [alertController setValue:popUpViewController forKey:@"contentViewController"];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"cancel"]
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action) {
                                                             }];
        [alertController addAction:cancelAction];
        
        UIAlertAction *useNewEmail = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"use_new_email"]
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                [self.selectOrEnterEmail setText:newEmail.text];
                                                            }];
        [alertController addAction:useNewEmail];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    return NO;
}

#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Account *account = [accounts objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:account.emailaddress];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Account *account = [accounts objectAtIndex:indexPath.row];
    
    [self.selectOrEnterEmail setText:account.emailaddress];
    
    [alertController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View controls

- (IBAction)viewCards:(id)sender {
    NSString *email = self.selectOrEnterEmail.text;
    NSString *password = self.password.text;
    
    if (([email length] > 0) && ([password length] > 0)) {
        [self showProgressDialog];
        
        LoginService *loginService = [[LoginService alloc] initWithListener:self username:email password:password managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId]];
        
        [loginService execute];
    }
}

#pragma mark - Background service callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[LoginService class]]) {
        EligibleCardsViewController *eligibleCardsViewController = [[EligibleCardsViewController alloc] initWithNibName:@"EligibleCardsViewController" bundle:[NSBundle baseResourcesBundle]];
        [eligibleCardsViewController setManagedObjectContext:self.managedObjectContext];
        
        [self.navigationController pushViewController:eligibleCardsViewController animated:YES];
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[LoginService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"login_error_title"]
                                                            message:[Utilities stringResourceForId:@"login_error_msg"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"ok"]
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end

