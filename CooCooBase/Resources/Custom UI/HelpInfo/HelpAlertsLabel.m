//
//  HelpAlertsLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 26/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpAlertsLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"


@implementation HelpAlertsLabel

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setHelpAlertsText];
}
- (void)setHelpAlertsText{
    NSString * alertsText = [NSString stringWithFormat:@"%@HelpAlerts",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:alertsText]];
        [self italicSubstring:@"Alerts"];
        [self italicSubstring:@"Home"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}

@end
