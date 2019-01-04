//
//  UIImage+LoadOverride.m
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "UIImage+LoadOverride.h"
#import "NSBundle+BaseResourcesBundle.h"

@implementation UIImage (LoadOverride)

+ (UIImage *)loadOverrideImageNamed:(NSString *)name
{
   // return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", [[NSBundle mainBundle] resourcePath], name]];

    UIImage *imageFromMainBundle = [UIImage imageNamed:name];
    if (imageFromMainBundle) {
        return imageFromMainBundle;
    } else {
//       NSString *imagePath = [[NSBundle baseResourcesBundle] pathForResource:name ofType:@".png"];
        NSString *imagePath = [NSString stringWithFormat:@"%@/%@.png", [[NSBundle mainBundle] resourcePath], name];
       return [UIImage imageWithContentsOfFile:imagePath];
    }
 
}

@end
