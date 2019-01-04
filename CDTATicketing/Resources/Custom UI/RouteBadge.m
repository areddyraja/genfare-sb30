//
//  RouteBadge.m
//  CDTA
//
//  Created by CooCooTech on 10/29/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RouteBadge.h"

float const ROUTE_BADGE_RADIUS = 30.0f;
float const ROUTE_BADGE_RADIUS_SMALL = 23.0f;

@implementation RouteBadge
{
    UIColor *badgeColor;
    UIFont *font;
    UIColor *textColor;
    NSString *text;
}

- (id)initWithFrame:(CGRect)frame badgeColor:(UIColor *)bColor textColor:(UIColor *)tColor text:(NSString *)txt
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        badgeColor = bColor;
        textColor = tColor;
        text = txt;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
         badgeColor:(UIColor *)bColor
               font:(UIFont *)fnt
          textColor:(UIColor *)tColor
               text:(NSString *)txt
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        badgeColor = bColor;
        font = fnt;
        textColor = tColor;
        text = txt;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColor(context, CGColorGetComponents([badgeColor CGColor]));
    CGContextFillPath(context);
    
    UILabel *routeIdLabel = [[UILabel alloc] init];
    [routeIdLabel setBackgroundColor:[UIColor clearColor]];
    [routeIdLabel setTextColor:textColor];
    [routeIdLabel setText:text];
    
    if (font) {
        [routeIdLabel setFont:font];
    } else {
        [routeIdLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    }
    
    CGRect labelRect;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        labelRect = [routeIdLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:routeIdLabel.font}
                                                    context:nil];
    } else {
        CGSize size = [routeIdLabel.text sizeWithFont:routeIdLabel.font
                                    constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
        labelRect.size = size;
    }
    
    [routeIdLabel setFrame:CGRectMake((self.frame.size.width / 2) - (labelRect.size.width / 2),
                                      (self.frame.size.height / 2) - (labelRect.size.height / 2),
                                      labelRect.size.width,
                                      labelRect.size.height)];
    
    [self addSubview:routeIdLabel];
}

- (UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end
