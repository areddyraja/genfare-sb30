//
//  BorderedButton.m
//  CDTA
//
//  Created by CooCooTech on 12/3/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BorderedButton.h"
#import "UIColor+HexString.h"
#import "Utilities.h"

@implementation BorderedButton
{
    UIColor *borderColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    borderColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]];
    
    [self.layer setBorderWidth:1.0f];
    [self.layer setCornerRadius:4.0f];
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderColor:borderColor.CGColor];
    [self.layer setBackgroundColor:[UIColor clearColor].CGColor];
    
    [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setTextColor:borderColor];
    [self setExclusiveTouch:YES];

}

//- (void)setHighlighted:(BOOL)highlighted
//{
//    if (highlighted) {
//        [self.layer setBackgroundColor:borderColor.CGColor];
//        [self.titleLabel setTextColor:[UIColor whiteColor]];
//    } else {
//        [self.layer setBackgroundColor:[UIColor clearColor].CGColor];
//        [self.titleLabel setTextColor:borderColor];
//    }
//}

@end
