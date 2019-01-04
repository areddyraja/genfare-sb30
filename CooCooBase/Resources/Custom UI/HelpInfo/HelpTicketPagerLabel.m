//
//  HelpTicketPagerLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 10/07/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpTicketPagerLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"

@implementation HelpTicketPagerLabel

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setHelpTicketPagerText];
}
- (void)setHelpTicketPagerText{
    NSString * helpTicketPagerText = [NSString stringWithFormat:@"%@HelpTicketPager",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:helpTicketPagerText]];
    [self italicSubstring:@"Information"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
