//
//  SplashScreenViewController.m
//  CDTATicketing
//
//  Created by CooCooTech on 6/17/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "GetAlertsService.h"
#import "GetRoutesService.h"
#import "UsageLoggingService.h"
#import "Utilities.h"
#import "UpgradeWalletService.h"
#import "GetOAuthService.h"
#import "GetProductsService.h"
#import "GetConfigApi.h"
#import "Singleton.h"

@interface SplashScreenViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *splashScreenImg;

@end

float const TIMEOUT = 5.0f;
float const TRANSITION_DURATION = 1.0f;

@implementation SplashScreenViewController
{
    NSTimer *timeoutTimer;
    CLLocationManager *locationManager;
    BOOL isLogged;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT
                                                        target:self
                                                      selector:@selector(goToHome)
                                                      userInfo:nil
                                                       repeats:NO];
        
        locationManager = [[CLLocationManager alloc] init];
        isLogged = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    GetOAuthService * getOAuthService = [[GetOAuthService alloc] initWithListener:self];
    [getOAuthService execute];
    
    
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];

    if(account){
        GetConfigApi *contents = [[GetConfigApi alloc]initWithListener:self];
        [contents execute];
    }
    
     
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(![userDefaults objectForKey:@"upgrade"]){
        [userDefaults setObject:@"true" forKey:@"upgrade"];
        [userDefaults synchronize];
    }

    
    [super viewDidLoad];
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSDictionary *uuidDict = [NSDictionary dictionaryWithObjectsAndKeys:[Utilities walletId],@"uuid", nil];
    NSMutableDictionary *mainDict = [[NSMutableDictionary alloc] init];
    [mainDict setObject:uuidDict forKey:@"device"];
    [mainDict setObject:device.name forKey:@"nickname"];
    [mainDict setObject:device.systemVersion forKey:@"description"];
    
    self.splashScreenImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@SplashScreen",[[Utilities tenantId] lowercaseString]]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (timeoutTimer) {
        [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
}

#pragma mark - Background services and callbacks

- (void)initialSetup
{
    
  
    
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [locationManager startUpdatingLocation];
    }
    
    
    
        GetRoutesService *routesService = [[GetRoutesService alloc] initWithListener:self
                                                                managedObjectContext:self.managedObjectContext];
        [routesService execute];
    
    
    
   
    
 }

- (void)threadSuccessWithClass:(id)service response:(id)response{
    
    if ([service isMemberOfClass:[GetOAuthService class]]) {
        [self initialSetup];
        
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        if(account){
            AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self username:account.emailaddress password:account.password];
            [tokenService execute];
        }
        
        
        NSLog(@"GetOAuthService Success");
        GetAlertsService *alertsService = [[GetAlertsService alloc] initWithListener:self];
        [alertsService execute];
    }else if ([service isMemberOfClass:[GetRoutesService class]]) {
        NSLog(@"GetRoutesService Success");
        
        GetAlertsService *alertsService = [[GetAlertsService alloc] initWithListener:self];
        [alertsService execute];
    }else if ([service isMemberOfClass:[GetAlertsService class]]) {
        NSLog(@"GetAlertsService Success");
        
        // Let the return from GetAlertsService wait for either UsageLoggingService to get a location or for timeoutTimer to finish
    }else if ([service isMemberOfClass:[GetAlertsService class]]) {
        NSLog(@"GetAlertsService Success");
        
        // Let the return from GetAlertsService wait for either UsageLoggingService to get a location or for timeoutTimer to finish
    }else if ([service isMemberOfClass:[RequestNewWalletService class]]) {
        NSLog(@"Request Wallet success");
        NSDictionary *resultDict = [response valueForKey:@"result"];
        NSError *error;
        
        NSDictionary *uuidDict = [NSDictionary dictionaryWithObjectsAndKeys:[[resultDict valueForKey:@"device"]valueForKey:@"uuid"],@"uuid", nil];
        NSMutableDictionary *mainDict = [[NSMutableDictionary alloc] init];
        [mainDict setObject:uuidDict forKey:@"device"];
        [mainDict setObject:[resultDict valueForKey:@"nickname"] forKey:@"nickname"];
        [mainDict setObject:[resultDict valueForKey:@"description"] forKey:@"description"];
    }
    else if ([service isMemberOfClass:[UpgradeWalletService class]]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"false" forKey:@"upgrade"];
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    if ([service isMemberOfClass:[GetRoutesService class]]) {
        NSLog(@"GetRoutesService Error");
        
        GetAlertsService *alertsService = [[GetAlertsService alloc] initWithListener:self];
        [alertsService execute];
    } else if ([service isMemberOfClass:[GetAlertsService class]]) {
        // Let the return from GetAlertsService wait for either UsageLoggingService to get a location or for timeoutTimer to finish
    } else if ([service isMemberOfClass:[RequestNewWalletService class]]) {
        NSLog(@"Request Wallet Error: %@", response);
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    isLogged = YES;
    
    UsageLoggingService *usageService = [[UsageLoggingService alloc] initWithEndpoint:@"appstart"
                                                                             viewName:nil
                                                                          viewDetails:nil
                                                                             latitude:newLocation.coordinate.latitude
                                                                            longitude:newLocation.coordinate.longitude];
    [usageService execute];
    
    [locationManager stopUpdatingLocation];
    
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    
    [self goToHome];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
    
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    
    [self goToHome];
}

#pragma mark - Other methods

- (void)goToHome
{
    if (!isLogged) {
        [locationManager stopUpdatingLocation];
        
        UsageLoggingService *usageService = [[UsageLoggingService alloc] initWithEndpoint:@"appstart"
                                                                                 viewName:nil
                                                                              viewDetails:nil
                                                                                 latitude:0
                                                                                longitude:0];
        [usageService execute];
    }
    
    dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void){
        [UIView transitionFromView:self.view
                            toView:self.navController.view
                          duration:TRANSITION_DURATION
                           options:UIViewAnimationOptionTransitionCurlUp
                        completion:^(BOOL finished)
        
        {
            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:self.navController];
        }
         ];
    });
    
}
@end
