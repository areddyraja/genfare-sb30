//
//  AccountsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 9/20/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "AccountsViewController.h"
#import "Account.h"
//#import "AddAccountViewController.h"
#import "AppSettingsViewController.h"
#import "CooCooAccountUtilities1.h"
#import "Utilities.h"

@interface AccountsViewController ()

@end

@implementation AccountsViewController
{
    NSArray *accounts;
    UILabel *emptyLabel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"accounts"]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Accounts" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadTableData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View controls

- (IBAction)addAccount:(id)sender {
//    AddAccountViewController *addAccountViewController = [[AddAccountViewController alloc] initWithNibName:@"AddAccountViewController"
//                                                                                                    bundle:[NSBundle baseResourcesBundle]];
//    [addAccountViewController setManagedObjectContext:self.managedObjectContext];
//    
//    [self.navigationController pushViewController:addAccountViewController animated:YES];
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
    
    [CooCooAccountUtilities1 setCurrentAccount:account.accountId managedObjectContext:self.managedObjectContext];
    
    AppSettingsViewController *appSettingsViewController = [[AppSettingsViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    [self.navigationController pushViewController:appSettingsViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Other methods

- (void)loadTableData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ACCOUNT_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    accounts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([accounts count] > 0) {
        [self.tableView setHidden:NO];
        
        if (emptyLabel != nil) {
            [emptyLabel setHidden:YES];
        }
    } else {
        [self.tableView setHidden:YES];
        
        if (emptyLabel != nil) {
            [emptyLabel setHidden:NO];
        } else {
            CGRect applicationFrame = [[UIScreen mainScreen] bounds];
            
            emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, applicationFrame.size.width - 16.0f, 0.0f)];
            [emptyLabel setText:[NSString stringWithFormat:@"%@\n\n%@",
                                 [Utilities stringResourceForId:@"no_accounts_1"],
                                 [Utilities stringResourceForId:@"no_accounts_2"]]];
            [emptyLabel setTextAlignment:NSTextAlignmentCenter];
            [emptyLabel setFont:[UIFont systemFontOfSize:16]];
            [emptyLabel setNumberOfLines:0];
            [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [emptyLabel sizeToFit];
            [emptyLabel setFrame:CGRectMake(8.0f,
                                            8.0f,
                                            emptyLabel.frame.size.width,
                                            emptyLabel.frame.size.height)];
            [emptyLabel setHidden:NO];
            
            [self.view addSubview:emptyLabel];
        }
    }
    
    [self.tableView reloadData];
}

@end
