//
//  HomeButton.m
//  CooCooBase
//
//  Created by CooCooTech on 4/29/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "HomeButton.h"

@implementation HomeButton
{
    UIColor *bgColor;
}

- (id)initWithFrame:(CGRect)frame
    backgroundColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    
    if (self) {
        bgColor = color;
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    [self.layer setCornerRadius:4.0f];
    [self.layer setMasksToBounds:YES];
    [self.layer setBackgroundColor:bgColor.CGColor];
    
    [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self setExclusiveTouch:YES];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        [self.titleLabel setTextColor:bgColor];
    } else {
        [self.titleLabel setTextColor:[UIColor whiteColor]];
    }
}

@end
