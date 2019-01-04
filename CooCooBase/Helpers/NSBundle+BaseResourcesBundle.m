//
//  NSBundle+BaseResourcesBundle.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "NSBundle+BaseResourcesBundle.h"

@implementation NSBundle (BaseResourcesBundle)

+ (NSBundle *)baseResourcesBundle
{
    static NSBundle *frameworkBundle = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        NSString *mainBundlePath = [[NSBundle mainBundle] resourcePath];
        frameworkBundle = [NSBundle mainBundle];
//        [NSBundle bundleWithPath:[mainBundlePath stringByAppendingPathComponent:@"CooCooBase.bundle"]];
    });
    
    return frameworkBundle;
}

@end
