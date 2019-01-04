//
//  GFSaveAddressViewController.m
//  CDTATicketing
//
//  Created by vishnu on 28/11/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

#import "GFSaveAddressViewController.h"
#import "GFAddressTableViewCell.h"
#import "Utilities.h"
#import <MapKit/MapKit.h>

@interface GFSaveAddressViewController ()<MKLocalSearchCompleterDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *addressInputFld;
@property (weak, nonatomic) IBOutlet UITextField *currentLocationFld;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) MKLocalSearchCompleter *searchCompleter;
@property (nonatomic) NSArray *results;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic) NSString *currentAddress;
@property (nonatomic) CLLocationCoordinate2D latlong;

@property (nonatomic) BOOL addressSelected;

@end

@implementation GFSaveAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.searchCompleter = [[MKLocalSearchCompleter alloc] init];
    self.searchCompleter.delegate = self;
    self.addressInputFld.delegate = self;
    self.currentLocationFld.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.results = [[NSArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"GFAddressTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ADDRESSCELL"];
    
    [self setUpNavigationBar];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.addressInputFld becomeFirstResponder];
    self.addressSelected = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)setUpNavigationBar {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    backButton.tintColor = UIColor.whiteColor;
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveAddress)];
    saveButton.tintColor = UIColor.whiteColor;
    [self.navigationItem setRightBarButtonItem:saveButton];
    
    if ([self.addressFor isEqualToString:KEY_SAVED_ADDRESS_HOME]) {
        self.title = @"Home Address";
    }else if([self.addressFor isEqualToString:KEY_SAVED_ADDRESS_SCHOOL]){
        self.title = @"School Address";
    }else if ([self.addressFor isEqualToString:KEY_SAVED_ADDRESS_WORK]){
        self.title = @"Work Address";
    }
}

-(void)saveAddress {
    if (!self.addressSelected) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:@"Please select an address from the list."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [Utilities saveAddress:self.currentAddress
                       lat:[NSString stringWithFormat:@"%f",self.latlong.latitude]
                      long:[NSString stringWithFormat:@"%f",self.latlong.longitude]
                       for:self.addressFor];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showSuggessions:(NSString *)letter {
    NSString *query = [NSString stringWithFormat:@"%@%@",self.addressInputFld.text,letter];
    [self.searchCompleter setQueryFragment:query];
}

#pragma mark - UITextField Delegate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.currentLocationFld) {
        NSLog(@"Use current Location");
        [self getUserCurrentLocation];
        [self.view endEditing:YES];
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    [self showSuggessions:@""];
    self.addressSelected = NO;
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self showSuggessions:string];
    return YES;
}

#pragma mark - UITableView DataSource methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFAddressTableViewCell *cell = (GFAddressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ADDRESSCELL"];
    MKLocalSearchCompletion *cellData = self.results[indexPath.row];
    cell.titleLabel.text = cellData.title;
    cell.descriptionLabel.text = cellData.subtitle;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

#pragma mark - UITableView Delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] initWithCompletion:self.results[indexPath.row]];
    MKLocalSearchCompletion *complete = self.results[indexPath.row];
    [self showProgressDialog];
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            for (MKMapItem *mapItem in [response mapItems]) {
                NSLog(@"%@",mapItem);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.addressInputFld.text = [NSString stringWithFormat:@"%@, %@",complete.title,complete.subtitle];
                    self.currentAddress = self.addressInputFld.text;
                    self.latlong = mapItem.placemark.coordinate;
                });
                self.addressSelected = YES;
            }
        }else{
            NSLog(@"Search request Error - %@",[error localizedDescription]);
        }
        [self dismissProgressDialog];
    }];
}

#pragma mark - Address complete delegate
-(void)completerDidUpdateResults:(MKLocalSearchCompleter *)completer {
    self.results = [completer.results copy];
    [self.tableView reloadData];
}

-(void)completer:(MKLocalSearchCompleter *)completer didFailWithError:(NSError *)error {
    NSLog(@"Handle places Error cases");
}

#pragma mark - Location based services

-(void)getUserCurrentLocation {
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        //[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways
        ) {
        // Will open an confirm dialog to get user's approval
        [_locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];
    } else {
        [_locationManager startUpdatingLocation]; //Will update location immediately
    }
    [self showProgressDialog];
}

-(void)updateLocationAddressWithLocation:(CLLocation *)location {
    //TODO - update address in
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [self showProgressDialog];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        [self updateAddressToGFLocation:placemarks.firstObject];
        [self dismissProgressDialog];
    }];
}

-(void)updateAddressToGFLocation:(CLPlacemark *)placeMark {
    NSString *address = [NSString stringWithFormat:@"%@, %@, %@, %@, %@",
                         placeMark.name,
                         placeMark.subThoroughfare,
                         placeMark.thoroughfare,
                         placeMark.locality,
                         placeMark.ISOcountryCode];
    self.addressInputFld.text = address;
    self.currentAddress = self.addressInputFld.text;
    self.latlong = placeMark.location.coordinate;
    self.addressSelected = YES;
}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"Location Permission is not granted yet");
        } break;
        case kCLAuthorizationStatusDenied: {
            NSLog(@"Denied Location Access");
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [_locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    NSLog(@"lat%f - lon%f", location.coordinate.latitude, location.coordinate.longitude);
    [self updateLocationAddressWithLocation:location];
    [_locationManager stopUpdatingLocation];
    [self dismissProgressDialog];
}

@end
