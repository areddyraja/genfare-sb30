//
//  AppSettingsViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 7/21/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "BaseSettingsViewController.h"

@interface AppSettingsViewController : BaseSettingsViewController <UIAlertViewDelegate>

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
