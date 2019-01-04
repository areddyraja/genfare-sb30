//
//  UILabel+Italicfy.m
//  CDTATicketing
//
//  Created by omniwyse on 25/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "UILabel+Italicfy.h"
#import "Utilities.h"

@implementation UILabel (Italicfy)
- (void) italicRange: (NSRange) range{
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
//    [UIFont boldSystemFontOfSize:self.font.pointSize]
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Italic" size:self.font.pointSize]} range:range];
    
    self.attributedText = attributedText;
}

- (void) italicSubstring: (NSString*) substring{
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
        NSRange range = [self.text rangeOfString:substring];
        [self italicRange:range];
    }else if ([tenantId isEqualToString:@"CDTA"]){
        return;
    }else{
        return;
    }
    return;
}

@end
