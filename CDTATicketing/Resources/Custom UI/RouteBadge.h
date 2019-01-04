//
//  RouteBadge.h
//  CDTA
//
//  Created by CooCooTech on 10/29/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteBadge : UIView

FOUNDATION_EXPORT float const ROUTE_BADGE_RADIUS;
FOUNDATION_EXPORT float const ROUTE_BADGE_RADIUS_SMALL;

- (id)initWithFrame:(CGRect)frame badgeColor:(UIColor *)badgeColor textColor:(UIColor *)textColor text:(NSString *)text;
- (id)initWithFrame:(CGRect)frame
         badgeColor:(UIColor *)badgeColor
               font:(UIFont *)font
          textColor:(UIColor *)textColor
               text:(NSString *)text;
- (UIImage *)image;

@end
