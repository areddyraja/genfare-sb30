//
//  SavedTrip.h
//  CDTA
//
//  Created by CooCooTech on 9/26/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedTrip : NSObject

@property (copy, nonatomic) NSString *departingStop;
@property (copy, nonatomic) NSString *arrivingStop;
@property (copy, nonatomic) NSString *duration;
@property (copy, nonatomic) NSString *price;

@end
