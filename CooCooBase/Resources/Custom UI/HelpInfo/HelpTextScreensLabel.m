//
//  HelpTextScreensLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 09/07/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpTextScreensLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"

@implementation HelpTextScreensLabel
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setHelpTextScreensInfoText];
}
- (void)setHelpTextScreensInfoText{
    NSString * helpTextScreensInfoText = [NSString stringWithFormat:@"%@HelpTextScreensInfo",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:helpTextScreensInfoText]];
        [self italicSubstring:@"Add Fund"];
        [self italicSubstring:@"Pay As You Go"];
        [self italicSubstring:@"Activate"];
        [self italicSubstring:@"Passes"];
        [self italicSubstring:@"Activities"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
