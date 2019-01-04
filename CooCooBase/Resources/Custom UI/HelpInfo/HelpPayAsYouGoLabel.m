//
//  HelpPayAsYouGoLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 26/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpPayAsYouGoLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"


@implementation HelpPayAsYouGoLabel

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setHelpPayAsYouGoText];
}
- (void)setHelpPayAsYouGoText{
    NSString * payAsYouGoText = [NSString stringWithFormat:@"%@HelpPayAsYouGo",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:payAsYouGoText]];
    //    [self italicSubstring:@"New Customer"];
    //    [self italicSubstring:@"Mobile Wallet"];
    //    [self italicSubstring:@"Existing Customer"];
    //    [self italicSubstring:@"Add Fund"];
    //    [self italicSubstring:@"Activations"];
    //    [self italicSubstring:@"Payment Method"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}

@end
