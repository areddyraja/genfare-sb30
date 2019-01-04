//
//  HelpSliderView.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpSliderView : UIView
{
    UIView *previousView;
}


@property (nonatomic) BOOL isExpanded;

- (id)initWithFrame:(CGRect)frame isLight:(BOOL)isLight;
- (void)initializeWithBarColor:(UIColor *)barColor;
- (void)insertHelpView:(UIView *)helpView title:(NSString *)title;
- (void)onExpand;
- (void)onCollapse;

@end
