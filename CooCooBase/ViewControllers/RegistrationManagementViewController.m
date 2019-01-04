//
//  RegistrationManagementViewController.m
//  CooCooBase
//
//  Created by John Scuteri on 9/11/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "RegistrationManagementViewController.h"
#import "DeleteRegisteredDeviceService.h"
#import "GetDeviceRegistrationStatusService.h"
#import "IASKSettingsReader.h"
#import "PutRegisteredDeviceService.h"
#import "RegisterDeviceService.h"
#import "RegisteredDevice.h"
#import "RegisteredDeviceCell.h"
#import "RuntimeData.h"
#import "SettingsStore.h"
#import "StoredData.h"
#import "Utilities.h"

@interface RegistrationManagementViewController ()

@end

@implementation RegistrationManagementViewController
{
    UILabel *emptyLabel;
    NSMutableArray *devices;
    RegisteredDevice *currentDevice;
    UITextField *newNameField;
    UIActivityIndicatorView *spinner;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"device_management"]];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    
    return self;
}
- (id)initWithFile:(NSString *)file specifier:(IASKSpecifier *)specifier {
    if (self = [super init]) {
      [self setTitle:[Utilities stringResourceForId:@"device_management"]];
        
        /*IASKSettingsReader *settingsReader = [[IASKSettingsReader alloc] initWithSettingsFileNamed:@"PasswordSettings" applicationBundle:[NSBundle baseResourcesBundle]];
        [settingsReader setShowPrivacySettings:NO];*/
        
       /* [self setSettingsReader:settingsReader];
        
        settingsStore = [[SettingsStore alloc] init];
        [self setSettingsStore:settingsStore];*/
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Device Management" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    devices = [[NSMutableArray alloc] init];
    
    [self callGetDeviceRegistrationStatus];
    
    // Change title of back button on next screen
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[Utilities stringResourceForId:@"back"]
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
}

- (void)callGetDeviceRegistrationStatus
{
    UserData *userData = [StoredData userData];
    GetDeviceRegistrationStatusService *deviceRegistrationStatusService = [[GetDeviceRegistrationStatusService alloc] initWithListener:self accountId:userData.accountId];
    [deviceRegistrationStatusService execute];
}

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];

    if ([service isMemberOfClass:[GetDeviceRegistrationStatusService class]]) {
        [spinner stopAnimating];
        
        BOOL registeredFlag = NO;
        
        [devices removeAllObjects];
        [devices addObjectsFromArray:[[RuntimeData instance]registeredDevices]];
        
        if ([devices count] == 0) {
            if (emptyLabel == nil) {
                CGRect applicationFrame = [[UIScreen mainScreen] bounds];
                
                emptyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width - 20, 0)];
                [emptyLabel setText:[Utilities stringResourceForId:@"no_registered_devices"]];
                [emptyLabel setTextAlignment:NSTextAlignmentCenter];
                [emptyLabel setFont:[UIFont systemFontOfSize:16]];
                [emptyLabel setNumberOfLines:0];
                [emptyLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [emptyLabel sizeToFit];
                [emptyLabel setCenter:CGPointMake(applicationFrame.size.width / 2,
                                                  self.deviceTableView.frame.origin.y
                                                  + (self.deviceTableView.frame.size.height / 2)
                                                  - HELP_SLIDER_HEIGHT)];
                [emptyLabel setHidden:NO];
                
                [self.view addSubview:emptyLabel];
            } else {
                [emptyLabel setHidden:NO];
            }
        } else {
            for (RegisteredDevice *device in devices) {
                if ([device.deviceUuid isEqualToString:[Utilities deviceId]]) {
                    registeredFlag = YES;
                    currentDevice = device;
                }
            }
            
            if (emptyLabel != nil) {
                [emptyLabel setHidden:YES];
            }
        }
        
        if (registeredFlag) {
            [self deviceRegistered];
        } else {
            [self deviceNotRegistered];
        }
    } else if ([service isMemberOfClass:[RegisterDeviceService class]]) {
        [self deviceRegistered];
        
        [self callGetDeviceRegistrationStatus];
    } else if ([service isMemberOfClass:[PutRegisteredDeviceService class]]) {
        [self callGetDeviceRegistrationStatus];
    } else if ([service isMemberOfClass:[DeleteRegisteredDeviceService class]]) {
        [self callGetDeviceRegistrationStatus];
    }
    
    [self.deviceTableView reloadData];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    NSLog(@"threadError class: %@", [service description]);
    [self dismissProgressDialog];

    if ([service isMemberOfClass:[GetDeviceRegistrationStatusService class]]) {
        [spinner stopAnimating];
    } else if ([service isMemberOfClass:[RegisterDeviceService class]]) {
        NSLog(@"Registration Failled for Device ID# %@", [Utilities deviceId]);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"unableToRegisterDeviceMessage"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else if ([service isMemberOfClass:[DeleteRegisteredDeviceService class]]){
        NSLog(@"can't delete an item");
    }
}


- (IBAction)registerThisDevice:(id)sender {
    NSLog(@"\n\nRegister this device\n\n");
    RegisterDeviceService *registerDevice = [[RegisterDeviceService alloc] initWithListener:self
                                                                                 customName:self.phoneNameTextField.text];
    [registerDevice execute];
}

- (void)deviceRegistered
{
    [self.registerThisDeviceButtonProperties setTitle:[Utilities stringResourceForId:@"device_is_registered"] forState:UIControlStateNormal];
    //disable register button
    self.registerThisDeviceButtonProperties.alpha = 0.4;
    self.registerThisDeviceButtonProperties.enabled = NO;
    //update displayed names
    self.phoneNameTextField.text = currentDevice.name;
    self.phoneNameTextField.enabled = NO;
}

- (void)deviceNotRegistered
{
    [self.registerThisDeviceButtonProperties setTitle:[Utilities stringResourceForId:@"register_this_device"] forState:UIControlStateNormal];
    //disable register button
    self.registerThisDeviceButtonProperties.alpha = 1.0;
    self.registerThisDeviceButtonProperties.enabled = YES;
    //update displayed names
    self.phoneNameTextField.text = [UIDevice currentDevice].name;
    self.phoneNameTextField.enabled = YES;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Registered Devices";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RegisteredDeviceCell";
    RegisteredDeviceCell *cell = (RegisteredDeviceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    RegisteredDevice *device = [devices objectAtIndex:(indexPath.row)];
    
    NSDate *lastUpdatedDate = device.created;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yy hh:mm aa"];
    
    [cell.deviceNameLabel setText:[Utilities stringResourceForId:@"device_name"]];
    [cell.registeredDateLabel setText:[Utilities stringResourceForId:@"registration_date"]];
    
    [cell.deviceName setText:device.name];
    [cell.registeredDate setText:[format stringFromDate:lastUpdatedDate]];
    
    //update phone image
    if ([device.os isEqualToString:@"iOS"]){
         [cell.deviceImage setImage:[UIImage loadOverrideImageNamed:@"iphone_icon"]];
    } else {
        if ([device.os isEqualToString:@"Android"]){
             [cell.deviceImage setImage:[UIImage loadOverrideImageNamed:@"android_icon"]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RegisteredDevice *selectedDevice = devices[indexPath.row];
    NSString *title = [NSString stringWithFormat:@"Manage Device: %@", selectedDevice.name];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@"All available actions are displayed below. If you don't want to change anything at this time click Cancel."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* changeNameAction = [UIAlertAction actionWithTitle:@"Change Name" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 if (![alert.textFields.firstObject.text isEqualToString:@""]) {
                                                                     /*  PatchRegisteredDevice *patchService = [[PatchRegisteredDevice alloc] initWithListener:self
                                                                      withMappingId:[selectedDevice.mappingId stringValue]
                                                                      withNewName:alert.textFields.firstObject.text];
                                                                      [patchService execute];*/
                                                                     PutRegisteredDeviceService *putService = [[PutRegisteredDeviceService alloc] initWithListener:self
                                                                                                                                                         mappingId:[selectedDevice.mappingId stringValue]
                                                                                                                                                           newName:alert.textFields.firstObject.text
                                                                                                                                                  registeredDevice:selectedDevice];
                                                                     [putService execute];
                                                                 }
                                                             }];
    
    UIAlertAction* unregisterDeviceAction = [UIAlertAction actionWithTitle:@"Unregister Device" style:UIAlertActionStyleDestructive
                                                                   handler:^(UIAlertAction * action) {
                                                                       NSLog(@"you are deleting %@", selectedDevice.name);
                                                                       DeleteRegisteredDeviceService *deleteService = [[DeleteRegisteredDeviceService alloc] initWithListener:self mappingId:selectedDevice.mappingId];
                                                                       [deleteService execute];
                                                                   }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    
    [alert addAction:changeNameAction];
    [alert addAction:unregisterDeviceAction];
    [alert addAction:cancelAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *alertTextField) {
        alertTextField.placeholder = @"Device Name";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 151;
}

@end
