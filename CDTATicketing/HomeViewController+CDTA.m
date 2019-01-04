//
//  HomeViewController+CDTA.m
//  CDTATicketing
//
//  Created by omniwyse on 29/06/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "HomeViewController+CDTA.h"
#import "HomeViewController.h"
#import "CDTARuntimeData.h"
#import "AppDelegate.h"
#import "CustomBadge.h"
@implementation HomeViewController (CDTA)

-(void)setAlertsCount{
    NSUInteger alertsCount = [[[CDTARuntimeData instance] alerts] count];
    int alertBtnYposition = 0;
    int row;
    int totalRowCount = 6;
    for (row = 0; row < totalRowCount; row++) {
        float  deviceStatusBar = [Utilities statusBarHeight];
        float remainingheight = SCREEN_HEIGHT - (NAVIGATION_BAR_HEIGHT + deviceStatusBar + HELP_SLIDER_HEIGHT);
        remainingheight = remainingheight-5;
        float viewHeight = remainingheight/totalRowCount;
        if (row == 4) {
            alertBtnYposition = 5 + viewHeight*row;
        }
    }
    if (alertsCount > 0) {
        alertsBadge = [CustomBadge customBadgeIOS7WithString:[NSString stringWithFormat:@"%lu", (unsigned long)alertsCount] withScale:1.0f];
        [alertsBadge setFrame:CGRectMake(SCREEN_WIDTH/3.2,
                                         alertBtnYposition,
                                         35,
                                         35)];
        [alertsBadge setBadgeInsetColor:[UIColor colorWithHexString:@"#D9D9D9"]];
        [alertsBadge setBadgeTextColor:[UIColor colorWithHexString:@"#ff4c41"]];
        //[alertsBadge setBackgroundColor:[UIColor colorWithHexString@""]];
        alertsBadge.layer.cornerRadius = alertsBadge.frame.size.width/2;
        [self.view addSubview:alertsBadge];
    }
}
-(void)prepareLandingViews
{
    SEL myNavigator = @selector(myTickets:);
    SEL tripPlanner = @selector(tripPlanner:);
    SEL realTimeArrivals = @selector(stops:);
    SEL routes = @selector(routes:);
    SEL alerts = @selector(alerts:);
    SEL contact = @selector(contact:);
    
    NSArray *actionsArray = [NSArray arrayWithObjects:[NSValue valueWithPointer:myNavigator],[NSValue valueWithPointer:tripPlanner],[NSValue valueWithPointer:realTimeArrivals],[NSValue valueWithPointer:routes],[NSValue valueWithPointer:alerts],[NSValue valueWithPointer:contact], nil];
    
    NSArray *iconsArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:FACalendar],[NSNumber numberWithInt:FACalendar],[NSNumber numberWithInt:FAClockO],[NSNumber numberWithInt:FAbus],[NSNumber numberWithInt:FAExclamationTriangle],[NSNumber numberWithInt:FAUser], nil];
    
    NSArray *backgroundColor = [NSArray arrayWithObjects:@"#D9D9D9",@"#D9D9D9",@"#D9D9D9",@"#669934",@"#FE4C40",@"#ECA900", nil];
    
    NSArray *iconColorArray = [NSArray arrayWithObjects:@"#0F2B5B",@"#0F2B5B",@"#0F2B5B",@"#ffffff",@"#ffffff",@"#ffffff", nil];
    
    NSArray *landingNamesArray = [NSArray arrayWithObjects:@"My Navigator",@"Trip Planner",@"Real Time Arrivals",@"Routes",@"Alerts",@"Contact", nil];
    
    float iconSizeFont;
    float iconCornerRadius;
    float landingTitleFont;
    
    if(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS){
        iconSizeFont = 27.0;
        iconCornerRadius = 5.0;
        landingTitleFont = 15.0;
        
    }
    else if (IS_IPHONE_6){
        iconSizeFont = 35.0;
        iconCornerRadius = 7.0;
        landingTitleFont = 17.0;
    }
    else{
        iconSizeFont = 37.0;
        iconCornerRadius = 9.0;
        landingTitleFont = 18.0;
    }
    
    int row;
    int totalRowCount = 6;
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
        [landingView setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities bGColor]]]];
        [self.view addSubview:landingView];
        
        // Icon View
        FontAwesomeButton *iconView = [[FontAwesomeButton alloc] init];
        float iconHeight = viewHeight - 5 - 20;
        CGRect iconFrame = CGRectMake(10, 10, landingView.frame.size.width/3, iconHeight);
        iconView.frame = iconFrame;
        [iconView setBackgroundColor:[AppDelegate colorFromHexString:[backgroundColor objectAtIndex:row]]];
        
        iconView.layer.cornerRadius = iconCornerRadius;
        iconView.layer.masksToBounds = YES;
        [landingView addSubview:iconView];
        
        NSLog(@"%ld",(long)[[iconsArray objectAtIndex:row] integerValue]);
        if(row != 0){
            [iconView setTitleColor:[AppDelegate colorFromHexString:[iconColorArray objectAtIndex:row]] andFontsize:iconSizeFont andTitle:(long)[[iconsArray objectAtIndex:row] integerValue]];
        }
        else
        {
            UIImageView *imgCard = [[UIImageView alloc] initWithFrame:iconFrame];
            [imgCard setImage:[UIImage imageNamed:@"card.png"]];
            imgCard.layer.cornerRadius = 1.0;
            imgCard.layer.masksToBounds = YES;
            [imgCard setBackgroundColor:[UIColor clearColor]];
            [iconView setBackgroundColor:[UIColor clearColor]];
            [landingView addSubview:imgCard];
        }
        
        // UILabel view name
        UILabel *lblLandingNames = [[UILabel alloc] init];
        CGRect labelFrame = CGRectMake(10 + SCREEN_WIDTH/3 + 10, 10, SCREEN_WIDTH/2, iconHeight);
        lblLandingNames.frame = labelFrame;
        lblLandingNames.text = [landingNamesArray objectAtIndex:row];
        [lblLandingNames setTextColor:[UIColor whiteColor]];
        lblLandingNames.font = [UIFont fontWithName:@"Montserrat" size:landingTitleFont];
        [landingView addSubview:lblLandingNames];
        
        // Right Arrow icon
        // Right Arrow icon
        FontAwesomeButton *btnRightArrow = [[FontAwesomeButton alloc] initWithFrame:CGRectMake(landingView.frame.size.width - 30, 20, 20, viewHeight - 45)];
        [btnRightArrow setTitleColor:[UIColor colorWithRed:96.0/255.0 green:109.0/255.0 blue:135.0/255.0 alpha:1] andFontsize:15.0 andTitle:FAChevronRight];
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
