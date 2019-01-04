//
//  StoredValueRange.h
//  CDTATicketing
//
//  Created by CooCooTech on 9/29/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoredValueRange : NSObject <NSCoding>

@property (nonatomic) float maximum;
@property (nonatomic) float minimum;
@property (nonatomic) float step;
@property (copy, nonatomic) NSString *order;
@property (nonatomic) BOOL isNegated;

@end
