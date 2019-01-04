//
//  ThemeView.m
//  CDTATicketing
//
//  Created by omniwyse on 18/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "ThemeView.h"

@implementation ThemeView

- (void)awakeFromNib{
    // Initialization code
    [super awakeFromNib];
    [self setViewBackgroundColour];
}
- (void)setViewBackgroundColour{
    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
