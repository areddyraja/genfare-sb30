//
//  Tenant.h
//  CDTATicketing
//
//  Created by CooCooTech on 9/30/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tenant : NSObject <NSCoding>

@property (nonatomic) int tenantId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *shortName;
@property (copy, nonatomic) NSString *timeZone;

@end
