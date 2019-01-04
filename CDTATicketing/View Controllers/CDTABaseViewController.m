//
//  CDTABaseViewController.m
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "CDTARuntimeData.h"
#import "UsageLoggingService.h"

@interface CDTABaseViewController ()

@end

@implementation CDTABaseViewController
{
    Reachability *hostReachability;
    UIView *spinnerView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isReachable:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the background for all screens that extend BaseViewController
    [self.view setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities mainBgColor]]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self isReachable:nil]) {
        if ([self.viewName length] > 0) {
            UsageLoggingService *usageService = [[UsageLoggingService alloc] initWithEndpoint:@"appusage"
                                                                                     viewName:self.viewName
                                                                                  viewDetails:self.viewDetails
                                                                                     latitude:0
                                                                                    longitude:0];
            [usageService execute];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isReachable:(id)sender
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    if ([reachability currentReachabilityStatus] == NotReachable) {
        if (![[CDTARuntimeData instance] isAlertShowing]) {
            [[CDTARuntimeData instance] setIsAlertShowing:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"connectivityAlertTitle"]
                                                                message:[Utilities stringResourceForId:@"connectivityAlertMessage"]
                                                               delegate:self
                                                      cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        return NO;
    } else {
        return YES;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[CDTARuntimeData instance] setIsAlertShowing:NO];
}

@end
