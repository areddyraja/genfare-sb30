//
//  HelpInstructionsLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 25/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpInstructionsLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"

@implementation HelpInstructionsLabel
- (void)awakeFromNib{
    // Initialization code
    [super awakeFromNib];
    [self setHelpInstructionsText];
}
- (void)setHelpInstructionsText{
    
//        myLabel.text = @"Updated: 2012/10/14 21:59 PM";
//        [myLabel boldSubstring: @"Updated:"];
//        [myLabel boldSubstring: @"21:59 PM"];
    
//    NSString * helpText = [NSString stringWithFormat:@"%@ContactsHelpText",[[Utilities tenantId] lowercaseString]];
//    [self setText:[Utilities stringResourceForId:helpText]];
//    [self boldSubstring:@"For"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
