//
//  GradientButton.m
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GradientButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation GradientButton
{
    CAGradientLayer *shineLayer;
    CALayer *highlightLayer;
}

#pragma mark - Overrides

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initLayers];
        [self setExclusiveTouch:YES];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initLayers];
}

- (void)setHighlighted:(BOOL)highlight {
    highlightLayer.hidden = !highlight;
    [super setHighlighted:highlight];
}

#pragma mark - View Customization

- (void)initLayers
{
    [self initBorder];
    [self addShineLayer];
    [self addHighlightLayer];
}

- (void)initBorder
{
    CALayer *layer = self.layer;
    layer.cornerRadius = 10.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
}

- (void)addShineLayer {
    shineLayer = [CAGradientLayer layer];
    shineLayer.frame = self.layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [self.layer addSublayer:shineLayer];
}

- (void)addHighlightLayer {
    highlightLayer = [CALayer layer];
    highlightLayer.backgroundColor = [UIColor
                                      colorWithRed:26/255.0f
                                      green:79/255.0f
                                      blue:149/255.0f
                                      alpha:1.0f].CGColor;
    highlightLayer.frame = self.layer.bounds;
    highlightLayer.hidden = YES;
    [self.layer insertSublayer:highlightLayer below:shineLayer];
}

@end
