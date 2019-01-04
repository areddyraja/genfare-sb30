//
//  HelpContactsTextView.m
//  CDTATicketing
//
//  Created by omniwyse on 19/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HelpContactsTextView.h"
#import "Utilities.h"
#import "UIColor+HexString.h"
#import "UILabel+Italicfy.h"

@implementation HelpContactsTextView
- (void)awakeFromNib{
    // Initialization code
    [super awakeFromNib];
    [self setHelpContactsText];
}
- (void)setHelpContactsText{
    NSString * helpContactsText = [NSString stringWithFormat:@"%@ContactsHelpText",[[Utilities tenantId] lowercaseString]];
    [self setText:[Utilities stringResourceForId:helpContactsText]];
    
////    UIFont *font1 = [UIFont fontWithName:kMyriadProSemiBold size:15];
//    UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Italic" size:16];
//
//    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
//    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"New Customer:" attributes: arialDict];
//
//
////    UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
//    UIFont *font2 = [UIFont fontWithName:@"Helvetica" size:16];
//
//    NSDictionary *arialDict2 = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
//    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" Use this option to setup an account. After an account is setup, you will be prompted to create and name your" attributes: arialDict2];
//
//
//    [aAttrString1 appendAttributedString:aAttrString2];
////    myProfileLabel.attributedText = aAttrString1;
//
//
//
//
//    [self setAttributedText:aAttrString1];
    
//    [self setText:[Utilities stringResourceForId:@"cotaAddAccountsHelpText"]];

    
    //    [self setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities themeColor]]]];
}
@end
