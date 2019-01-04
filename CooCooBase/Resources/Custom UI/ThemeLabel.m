//
//  ThemeLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 18/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "ThemeLabel.h"

@implementation ThemeLabel

- (void)awakeFromNib{
    // Initialization code
    [super awakeFromNib];
    [self setLabelBackgroundColour];
}
- (void)setLabelBackgroundColour{
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByWordWrapping];
    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
