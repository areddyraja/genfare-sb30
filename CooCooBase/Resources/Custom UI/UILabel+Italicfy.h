//
//  UILabel+Italicfy.h
//  CDTATicketing
//
//  Created by omniwyse on 25/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Italicfy)
- (void) italicSubstring: (NSString*) substring;
- (void) italicRange: (NSRange) range;
@end
