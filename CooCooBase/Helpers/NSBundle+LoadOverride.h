//
//  NSBundle+LoadOverride.h
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (LoadOverride)

+ (NSArray *)loadOverrideNibNamed:(NSString *)nib owner:(id)owner options:(NSDictionary *)options;

@end
