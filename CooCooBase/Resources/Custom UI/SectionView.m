//
//  SectionView.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "SectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "UIColor+HexString.h"

float const CORNER_RADIUS = 4.0f;

@implementation SectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    self.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities tableBgColor]]];
    
    CALayer *layer = self.layer;
    [layer setCornerRadius:CORNER_RADIUS];
    [layer setBorderColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities tableBgColor]]].CGColor];
    [layer setBorderWidth:2.0f];
}

@end
