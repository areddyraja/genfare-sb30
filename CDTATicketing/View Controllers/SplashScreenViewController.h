//
//  SplashScreenViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 6/17/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CooCooBase.h"
#import <CoreLocation/CoreLocation.h>
#import "CDTAAppConstants.h"

@interface SplashScreenViewController : UIViewController <CLLocationManagerDelegate, ServiceListener>

@property (weak, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
