//
//  ThemeButton.m
//  CDTATicketing
//
//  Created by omniwyse on 18/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "ThemeButton.h"

@implementation ThemeButton
/*
- (void)awakeFromNib{
    // Initialization code
    [super awakeFromNib];
    [self setButtonBackgroundColour];
}
- (void)setButtonBackgroundColour{
    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
*/
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
    

//    UIColor * borderColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]];
    
//    [self.layer setBorderWidth:1.0f];
    [self.layer setCornerRadius:4.0f];
    [self.layer setMasksToBounds:YES];
//    [self.layer setBorderColor:borderColor.CGColor];
    [self.layer setBackgroundColor:[UIColor clearColor].CGColor];
    
    [self.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [self.titleLabel setTextColor:borderColor];
    [self setExclusiveTouch:YES];
//    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]]];
    
    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
    

    
}



@end
