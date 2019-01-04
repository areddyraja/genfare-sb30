//
//  SMSValidationService.h
//  CDTATicketing
//
//  Created by Gaian Solutions on 5/8/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface SMSValidationService : BaseService
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext deviceid:(NSString*)uid;

@end
