//
//  TileButton.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TileButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation TileButton
{
    UILabel *buttonLabel;
    UIImage *iconImage;
    UIImageView *iconImageView;
    CAGradientLayer *shineLayer;
    CALayer *highlightLayer;
}

#pragma mark - Overrides

- (id)initWithFrame:(CGRect)frame
               text:(NSString *)buttonText
               font:(UIFont *)font
               icon:(UIImage *)iconImage
     roundedCorners:(UIRectCorner)roundedCorners
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setTitle:buttonText forState:UIControlStateNormal];
        
        int padding = 5;
        float radiusWidth = 10.0;
        float radiusHeight = 10.0;
        
        UIEdgeInsets edges = UIEdgeInsetsMake(padding, padding, padding, padding);
        [self setContentEdgeInsets:edges];
        
        self.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:font];
        [self setExclusiveTouch:YES];
        
        // Create the path with specified rounded corner
        UIBezierPath *maskPath = [UIBezierPath
                                  bezierPathWithRoundedRect:self.bounds
                                  byRoundingCorners:roundedCorners
                                  cornerRadii:CGSizeMake(radiusWidth, radiusHeight)];
        
        // Create the shape layer and set its path
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        
        // Set the newly created shape layer as the mask for the view's layer
        self.layer.mask = maskLayer;
        
        [self initLayers];
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
    [self addShineLayer];
    [self addHighlightLayer];
}

- (void)addShineLayer
{
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

- (void)addHighlightLayer
{
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
