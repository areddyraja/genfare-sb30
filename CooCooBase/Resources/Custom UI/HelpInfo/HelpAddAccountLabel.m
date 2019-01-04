//
//  HelpAddAccountLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 26/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpAddAccountLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"

@implementation HelpAddAccountLabel
- (void)awakeFromNib{
    // Initialization code
    [super awakeFromNib];
    [self setHelpInstructionsText];
}
- (void)setHelpInstructionsText{
    //        myLabel.text = @"Updated: 2012/10/14 21:59 PM";
    //        [myLabel boldSubstring: @"Updated:"];
    //        [myLabel boldSubstring: @"21:59 PM"];
//    [self setText:[Utilities stringResourceForId:@"cotaAddAccountsHelpText"]];
    NSString * addAccountsHelpText = [NSString stringWithFormat:@"%@AddAccountsHelpText",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:addAccountsHelpText]];
    [self italicSubstring:@"New Customer"];
    [self italicSubstring:@"Mobile Wallet"];
    [self italicSubstring:@"Existing Customer"];
    [self italicSubstring:@"Add Fund"];
    [self italicSubstring:@"Activations"];
    [self italicSubstring:@"Payment Method"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
