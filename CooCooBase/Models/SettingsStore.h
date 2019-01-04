//
//  SettingsStore.h
//  CooCooBase
//
//  Created by CooCooTech on 7/21/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "IASKSettingsStore.h"
#import <CoreData/CoreData.h>

@interface SettingsStore : IASKAbstractSettingsStore

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
