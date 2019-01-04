//
//  HelpStopsLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 26/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpStopsLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"

@implementation HelpStopsLabel
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setHelpStopsText];
}
- (void)setHelpStopsText{
    NSString * helpStopsText = [NSString stringWithFormat:@"%@HelpStops",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:helpStopsText]];
    //    [self italicSubstring:@"New Customer"];
    //    [self italicSubstring:@"Mobile Wallet"];
    //    [self italicSubstring:@"Existing Customer"];
    //    [self italicSubstring:@"Add Fund"];
    //    [self italicSubstring:@"Activations"];
    //    [self italicSubstring:@"Payment Method"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
