//
//  TripMapViewController.h
//  CDTA
//
//  Created by CooCooTech on 10/15/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDTABaseViewController.h"
#import "DirectionRoute.h"
#import "Stop.h"

@interface TripMapViewController : CDTABaseViewController

@property (strong, nonatomic) DirectionRoute *directionRoute;
@property (strong, nonatomic) NSArray *routeIds;
@property (strong, nonatomic) NSString *originName;
@property (nonatomic) int originId;
@property (strong, nonatomic) NSString *destinationName;
@property (nonatomic) int destinationId;
@property (weak, nonatomic) IBOutlet UIView *mapContainerView;
@property (weak, nonatomic) IBOutlet UIView *placeHolderView;
@property (weak, nonatomic) IBOutlet UILabel *previousStepLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextStepLabel;

@end
