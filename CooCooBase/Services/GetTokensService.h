//
//  GetTokensService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface GetTokensService : NSObject

@property (nonatomic, getter = isGetTokenOfDay) BOOL getTokenOfDay;

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (void)execute;

@end