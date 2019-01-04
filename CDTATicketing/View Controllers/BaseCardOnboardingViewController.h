//
//  BaseCardOnboardingViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 3/31/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCardOnboardingViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) int pageIndex;

@end
