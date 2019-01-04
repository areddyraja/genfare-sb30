//
//  HelpChangePasswordLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 26/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpChangePasswordLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"


@implementation HelpChangePasswordLabel

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setHelpChangePasswordText];
}
- (void)setHelpChangePasswordText{
    NSString * passwordText = [NSString stringWithFormat:@"%@HelpChangePassword",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:passwordText]];
    //    [self italicSubstring:@"New Customer"];
    //    [self italicSubstring:@"Mobile Wallet"];
    //    [self italicSubstring:@"Existing Customer"];
    //    [self italicSubstring:@"Add Fund"];
    //    [self italicSubstring:@"Activations"];
    //    [self italicSubstring:@"Payment Method"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}

@end
