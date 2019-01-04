//
//  Tenant.m
//  CDTATicketing
//
//  Created by CooCooTech on 9/30/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "Tenant.h"

@implementation Tenant

NSString *const KEY_ID = @"id";
NSString *const KEY_TENANT_NAME = @"tenantName";
NSString *const KEY_TENANT_SHORT_NAME = @"tenantShortName";
NSString *const KEY_TIME_ZONE = @"timeZone";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.tenantId = [decoder decodeIntForKey:KEY_ID];
        self.name = [decoder decodeObjectForKey:KEY_TENANT_NAME];
        self.shortName = [decoder decodeObjectForKey:KEY_TENANT_SHORT_NAME];
        self.timeZone = [decoder decodeObjectForKey:KEY_TIME_ZONE];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.tenantId forKey:KEY_ID];
    [encoder encodeObject:self.name forKey:KEY_TENANT_NAME];
    [encoder encodeObject:self.shortName forKey:KEY_TENANT_SHORT_NAME];
    [encoder encodeObject:self.timeZone forKey:KEY_TIME_ZONE];
}

@end
