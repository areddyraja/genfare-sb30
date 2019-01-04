//
//  PaddedLabel.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "PaddedLabel.h"

@implementation PaddedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

#pragma mark - Class overrides

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {0, 10, 0, 10};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

#pragma mark - Other methods

- (void)resizeForMultiline
{
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize max = CGSizeMake(self.frame.size.width, FLT_MAX);
    CGSize suggestedSize = [self.text sizeWithFont:self.font constrainedToSize:max lineBreakMode:self.lineBreakMode];
    
    CGRect newFrame = self.frame;
    newFrame.size.height = suggestedSize.height;
    self.frame = newFrame;
}

@end
