//
//  HomeViewController+COTA.m
//  COTATicketing Staging
//
//  Created by omniwyse on 29/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HomeViewController+COTA.h"
#import "HomeViewController.h"
#import "CDTARuntimeData.h"
#import "AppDelegate.h"
#import "CustomBadge.h"

@implementation HomeViewController (COTA)
-(void)setAlertsCount{
    NSUInteger alertsCount = [[[CDTARuntimeData instance] alerts] count];
    int alertBtnYposition = 0;
    int row;
    int totalRowCount = 3;
    for (row = 0; row < totalRowCount; row++) {
        float  deviceStatusBar = [Utilities statusBarHeight];
        float remainingheight = SCREEN_HEIGHT - (NAVIGATION_BAR_HEIGHT + deviceStatusBar + HELP_SLIDER_HEIGHT);
        remainingheight = remainingheight-5;
        float viewHeight = remainingheight/totalRowCount;
        if (row == 1) {
            alertBtnYposition = 5 + viewHeight*row;
            alertBtnYposition = alertBtnYposition + viewHeight/4;
        }
    }
    if (alertsCount > 0) {
        alertsBadge = [CustomBadge customBadgeIOS7WithString:[NSString stringWithFormat:@"%lu", (unsigned long)alertsCount] withScale:1.0f];
        [alertsBadge setFrame:CGRectMake(SCREEN_WIDTH/2.3,
                                         alertBtnYposition,
                                         60,
                                         60)];
        [alertsBadge setBadgeInsetColor:[UIColor colorWithHexString:@"#D9D9D9"]];
        [alertsBadge setBadgeTextColor:[UIColor colorWithHexString:@"#ff4c41"]];
        //[alertsBadge setBackgroundColor:[UIColor colorWithHexString@""]];
        alertsBadge.layer.cornerRadius = alertsBadge.frame.size.width/2;
        [self.view addSubview:alertsBadge];
    }
}
-(void)prepareLandingViews{
    SEL myNavigator = @selector(myTickets:);
    SEL tripPlanner = @selector(tripPlanner:);
    SEL realTimeArrivals = @selector(stops:);
    SEL routes = @selector(routes:);
    SEL alerts = @selector(alerts:);
    SEL contact = @selector(contact:);
    NSArray *actionsArray = [NSArray arrayWithObjects:[NSValue valueWithPointer:myNavigator],[NSValue valueWithPointer:alerts],[NSValue valueWithPointer:contact], nil];
    NSArray *iconsArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:FAbus],[NSNumber numberWithInt:FAExclamationTriangle],[NSNumber numberWithInt:FAUser], nil];
    NSArray *backgroundColor = [NSArray arrayWithObjects:@"#D9D9D9",@"#FE4C40",@"#ECA900", nil];
    NSArray *iconColorArray = [NSArray arrayWithObjects:@"#ffffff",@"#ffffff",@"#ffffff", nil];
    NSArray *landingNamesArray = [NSArray arrayWithObjects:@"My Connector",@"Alerts",@"Contact", nil];
    float iconSizeFont;
    float iconCornerRadius;
    float landingTitleFont;
    if(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS){
        iconSizeFont = 37.0;
        iconCornerRadius = 5.0;
        landingTitleFont = 17.0;
    }
    else if (IS_IPHONE_6){
        iconSizeFont = 42.0;
        iconCornerRadius = 7.0;
        landingTitleFont = 19.0;
    }
    else{
        iconSizeFont = 62.0;
        iconCornerRadius = 9.0;
        landingTitleFont = 22.0;
    }
    int row;
    int totalRowCount = 3;
    for (row = 0; row < totalRowCount; row++) {
        // Landing View
        float  deviceStatusBar = [Utilities statusBarHeight];
//        CGFloat screenHeight = [Utilities currentDeviceHeight];
        float remainingheight = SCREEN_HEIGHT - (NAVIGATION_BAR_HEIGHT + deviceStatusBar + HELP_SLIDER_HEIGHT);
        remainingheight = remainingheight-5;
        float viewHeight = remainingheight/totalRowCount;
        
        UIView *landingView = [[UIView alloc] init];
        CGRect landingFrame = CGRectMake(5,5 + viewHeight*row, SCREEN_WIDTH - 10, viewHeight - 5);
        landingView.frame = landingFrame;
        [landingView setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"cotaBGColor"]]];
        [self.view addSubview:landingView];
        
        // Icon View
        FontAwesomeButton *iconView = [[FontAwesomeButton alloc] init];
        float iconHeight = viewHeight/2;
        CGRect iconFrame = CGRectMake(20, viewHeight/4, iconHeight , iconHeight);
        iconView.frame = iconFrame;
        [landingView addSubview:iconView];
        NSLog(@"%d",(int)[[iconsArray objectAtIndex:row] integerValue]);
        if(row != 0){
            [iconView setTitleColor:[AppDelegate colorFromHexString:[iconColorArray objectAtIndex:row]] andFontsize:iconSizeFont andTitle:(int)[[iconsArray objectAtIndex:row] integerValue]];
        }else{
            UIImageView *imgCard = [[UIImageView alloc]init];
            float width = iconView.frame.size.width/2;
            float height = iconView.frame.size.height/2;
            float x = width-width/2;
            float y = height-height/2;
            imgCard.frame = CGRectMake(x, y, width, height);
            [imgCard setImage:[UIImage imageNamed:@"bus"]];
            [imgCard setContentMode:UIViewContentModeScaleAspectFit];
            imgCard.layer.cornerRadius = 8.0;
            imgCard.layer.masksToBounds = YES;
            [imgCard setBackgroundColor:[UIColor clearColor]];
            [iconView setBackgroundColor:[UIColor clearColor]];
            [iconView addSubview:imgCard];
            [landingView addSubview:iconView];
        }
        // UILabel view name
        UILabel *lblLandingNames = [[UILabel alloc] init];
        CGRect labelFrame = CGRectMake(iconFrame.size.width + 20, viewHeight/4, SCREEN_WIDTH - (iconView.frame.origin.x + iconView.frame.size.width + 40), iconHeight);
        lblLandingNames.frame = labelFrame;
        lblLandingNames.text = [landingNamesArray objectAtIndex:row];
        [lblLandingNames setTextColor:[UIColor whiteColor]];
        lblLandingNames.font = [UIFont fontWithName:@"Montserrat" size:landingTitleFont];
        [landingView addSubview:lblLandingNames];
        
        // Right Arrow icon
        FontAwesomeButton *btnRightArrow = [[FontAwesomeButton alloc] initWithFrame:CGRectMake(lblLandingNames.frame.origin.x +lblLandingNames.frame.size.width, viewHeight/8*3, viewHeight/8, viewHeight/4)];
        [btnRightArrow setTitleColor:[UIColor whiteColor] andFontsize:20.0 andTitle:FAChevronRight];
        [landingView addSubview:btnRightArrow];
        
        // button action
        UIButton *btnLanding = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLanding.frame = landingFrame;
        SEL selector = [[actionsArray objectAtIndex:row] pointerValue];
        [btnLanding addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnLanding];
    }
}
@end
