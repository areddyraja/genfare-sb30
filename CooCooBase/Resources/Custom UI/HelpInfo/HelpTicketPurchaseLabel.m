//
//  HelpTicketPurchaseLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 26/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpTicketPurchaseLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"

@implementation HelpTicketPurchaseLabel

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setHelpTicketPurchaseText];
}
- (void)setHelpTicketPurchaseText{
    NSString * purchaseText = [NSString stringWithFormat:@"%@HelpTicketPurchase",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:purchaseText]];
        [self italicSubstring:@"Add Fund"];
        [self italicSubstring:@"My Connector"];
        [self italicSubstring:@"Account Balance"];
//        [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}

@end
