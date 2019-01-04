//
//  StoredValueDuration.h
//  CDTATicketing
//
//  Created by CooCooTech on 10/20/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoredValueDuration : NSObject <NSCoding>

@property (nonatomic) NSUInteger duration;
@property (nonatomic) int offset;

@end
