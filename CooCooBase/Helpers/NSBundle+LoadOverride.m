//
//  NSBundle+LoadOverride.m
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSBundle+BaseResourcesBundle.h"
#import "NSBundle+LoadOverride.h"

@implementation NSBundle (LoadOverride)

+ (NSArray *)loadOverrideNibNamed:(NSString *)nib owner:(id)owner options:(NSDictionary *)options
{
    if ([[NSBundle mainBundle] pathForResource:nib ofType:@"nib"] != nil) {
        return [[NSBundle mainBundle] loadNibNamed:nib owner:owner options:options];
    } else {
        return [[NSBundle baseResourcesBundle] loadNibNamed:nib owner:owner options:options];
    }
}

@end
