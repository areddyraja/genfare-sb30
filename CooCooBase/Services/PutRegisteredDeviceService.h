//
//  PutRegisteredDevice.h
//  Pods
//
//  Created by Andrey Kasatkin on 1/4/16.
//
//

#import "BaseService.h"
#import "RegisteredDevice.h"

@interface PutRegisteredDeviceService : BaseService

- (id)initWithListener:(id)listener
             mappingId:(NSString *)mapId
               newName:(NSString *)newN
      registeredDevice:(RegisteredDevice *)regDev;

@end
