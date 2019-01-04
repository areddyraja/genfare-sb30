//
//  CreateMobileCardLabel.m
//  CDTATicketing
//
//  Created by omniwyse on 27/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "CreateMobileCardLabel.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"

@implementation CreateMobileCardLabel
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setCreateMobileCardText];
}
- (void)setCreateMobileCardText{
    NSString * createMobileCardText = [NSString stringWithFormat:@"%@CreateMobileCard",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:createMobileCardText]];
    //    [self italicSubstring:@"New Customer"];
    //    [self italicSubstring:@"Mobile Wallet"];
    //    [self italicSubstring:@"Existing Customer"];
    //    [self italicSubstring:@"Add Fund"];
    //    [self italicSubstring:@"Activations"];
    //    [self italicSubstring:@"Payment Method"];
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
