//
//  HelpSliderView.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "HelpSliderView.h"
#import "Utilities.h"
#import "AppConstants.h"
#import "NSBundle+LoadOverride.h"
#import "UIColor+HexString.h"
#import "UIImage+LoadOverride.h"
#import "iRide-Swift.h"

#define VERSION_LBL_TAG 9876

int const HELP_TEXT_PADDING = 8;

@implementation HelpSliderView
{
    BOOL isLight;
    UINavigationBar *topBar;
    UIScrollView *scrollView;
    UILabel *swipeLabel;
    UIImage *upImage;
    UIImageView *upImageView;
    //UILabel *swipeLabel2;
    float deviceStatusBar;
}

- (id)initWithFrame:(CGRect)frame isLight:(BOOL)light;
{
    self = [super initWithFrame:frame];
    if (self) {
        isLight = light;
        topBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HELP_SLIDER_HEIGHT)];
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 32, self.frame.size.width, self.frame.size.height - 52)];
        swipeLabel = [[UILabel alloc] init];
        //swipeLabel2 = [[UILabel alloc] init];
        
        //if (isLight) {
        //    upImage = [UIImage loadOverrideImageNamed:@"ic_up_light"];
        //} else {
        //    upImage = [UIImage loadOverrideImageNamed:@"ic_up"];
        //}
        
        upImageView = [[UIImageView alloc] init];
    }
    
    return self;
}

#pragma mark - View controls

- (void)initializeWithBarColor:(UIColor *)barColor
{
    [self setBackgroundColor:barColor];
    
    // Top Bar
    swipeLabel = [self createBarLabelWithText:[Utilities stringResourceForId:@"help_bar_label"]];
    [swipeLabel setCenter:CGPointMake((swipeLabel.frame.size.width / 2) + 4, topBar.frame.size.height / 2)];
    
    [topBar addSubview:swipeLabel];
    
    /*
     upImageView = [[UIImageView alloc] initWithImage:upImage];
     [upImageView setFrame:CGRectMake(swipeLabel1.frame.origin.x + swipeLabel1.frame.size.width + 2,
     (topBar.frame.size.height / 2) - (upImageView.frame.size.height / 4),
     upImageView.frame.size.width / 2,
     upImageView.frame.size.height / 2)];
     
     [topBar addSubview:upImageView];
     
     swipeLabel2 = [self createBarLabelWithText:@"for help"];
     [swipeLabel2 setCenter:CGPointMake((swipeLabel2.frame.size.width / 2) + upImageView.frame.origin.x + upImageView.frame.size.width + 2,
     topBar.frame.size.height / 2)];
     
     [topBar addSubview:swipeLabel2];
     */
    
    /*UIImage *coocooLogo = nil;
     if (isLight) {
     coocooLogo = [UIImage loadOverrideImageNamed:@"coocoo_power_light"];
     } else {
     coocooLogo = [UIImage loadOverrideImageNamed:@"coocoo_power"];
     }*/
    UIImage *logo = [UIImage loadOverrideImageNamed:@"company_logo"];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logo];
    [logoImageView setFrame:CGRectMake(topBar.frame.size.width - (logoImageView.frame.size.width / 1.5) - 4,
                                       (topBar.frame.size.height / 2) - (logoImageView.frame.size.height / 3),
                                       logoImageView.frame.size.width / 1.5,
                                       logoImageView.frame.size.height / 1.5)];
    
    [topBar addSubview:logoImageView];
    
    [self addSubview:topBar];
    
    /* ScrollView */
    
    // Contact Info
    UILabel *contactTitle = [self createLabelWithTitle:@"Contact" offsetY:HELP_TEXT_PADDING];
    
    //    [scrollView addSubview:contactTitle];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Slider Text" owner:self options:nil] objectAtIndex:0];
    [helpText setFrame:CGRectMake(0,
                                  contactTitle.frame.origin.y + contactTitle.frame.size.height + HELP_TEXT_PADDING,
                                  topBar.frame.size.width,//gets width of the whole screen //helpText.frame.size.width,
                                  helpText.frame.size.height)];
    
    [scrollView addSubview:helpText];
    
    [self addSubview:scrollView];
    
    deviceStatusBar = [Utilities statusBarHeight];

    // App version
//    NSString *apiEnvironment = ([Utilities apiEnvironment]) ? [NSString stringWithFormat:@" (%@)",[Utilities apiEnvironment]] : @"";
    NSString *apiEnvironment = @"";
    //Above to prevent production versions from having a null
    UILabel *versionLabel = [self createBarLabelWithText:[NSString stringWithFormat:@"%@ v%@%@",
                                                          [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"],
                                                          [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],
                                                          apiEnvironment]];
    [versionLabel setTextColor:[UIColor darkTextColor]];
    [versionLabel setFrame:CGRectMake(self.frame.size.width - versionLabel.frame.size.width - 4,
                                      [UIScreen mainScreen].bounds.size.height - versionLabel.frame.size.height - deviceStatusBar - 4,
                                      versionLabel.frame.size.width,
                                      versionLabel.frame.size.height)];
    
    [self addSubview:versionLabel];
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)insertHelpView:(UIView *)helpView title:(NSString *)title
{
    //    UILabel *titleLabel = [self createLabelWithTitle:title offsetY:HELP_TEXT_PADDING];
    
    //    [helpView setFrame:CGRectMake(0,
    //                                  titleLabel.frame.origin.y + titleLabel.frame.size.height + HELP_TEXT_PADDING,
    //                                  scrollView.frame.size.width,
    //                                  helpView.frame.size.height)];
    
    if ([[self topViewController] isKindOfClass:[GFMapsHomeViewController class]]) {
        [self removeFromSuperview];
        return;
    }

    if(previousView){
        [previousView removeFromSuperview];
    }
    [helpView setFrame:CGRectMake(0,
                                  HELP_TEXT_PADDING,
                                  [UIScreen mainScreen].bounds.size.width,
                                  [UIScreen mainScreen].bounds.size.height - (66 + 40 + 20))];
    
    //    helpView.frame.size.height
    
    
    //    CGFloat maxHeight = 0;
    //    for (UIView *view in scrollView.subviews) {
    //        [view setFrame:CGRectMake(view.frame.origin.x,
    //                                  view.frame.origin.y + titleLabel.frame.origin.y + titleLabel.frame.size.height + helpView.frame.origin.y + helpView.frame.size.height - HELP_TEXT_PADDING,
    //                                  view.frame.size.width,
    //                                  view.frame.size.height)];
    //
    //        CGFloat viewHeight = view.frame.origin.y + view.frame.size.height;
    //        if (maxHeight < viewHeight) {
    //            maxHeight = viewHeight;
    //        }
    //    }
    
    //    [scrollView addSubview:titleLabel];
    [scrollView addSubview:helpView];
    previousView=helpView;
    //    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, maxHeight)];
}

- (void)onExpandOld
{
    [upImageView removeFromSuperview];
    
    //UIImage *flippedImage = [UIImage imageWithCGImage:upImage.CGImage scale:1.0f orientation:UIImageOrientationDown];
    
    //upImageView = [[UIImageView alloc] initWithImage:flippedImage];
    [upImageView setFrame:CGRectMake(swipeLabel.frame.origin.x + swipeLabel.frame.size.width + 2,
                                     (topBar.frame.size.height / 2) - (upImageView.frame.size.height / 4),
                                     upImageView.frame.size.width / 2,
                                     upImageView.frame.size.height / 2)];
    
    //[topBar addSubview:upImageView];
    
    //[swipeLabel2 removeFromSuperview];
    [swipeLabel setText:[Utilities stringResourceForId:@"help_bar_label_close"]];
    [swipeLabel sizeToFit];
    //swipeLabel2 = [self createBarLabelWithText:@"to close"];
    //[swipeLabel2 setCenter:CGPointMake((swipeLabel2.frame.size.width / 2) + upImageView.frame.origin.x + upImageView.frame.size.width + 2,
    //                                   topBar.frame.size.height / 2)];
    
    //[topBar addSubview:swipeLabel2];
    
    [self setIsExpanded:YES];
}
- (void)onExpand
{
    [upImageView removeFromSuperview];
    
    //UIImage *flippedImage = [UIImage imageWithCGImage:upImage.CGImage scale:1.0f orientation:UIImageOrientationDown];
    
    //upImageView = [[UIImageView alloc] initWithImage:flippedImage];
    [upImageView setFrame:CGRectMake(swipeLabel.frame.origin.x + swipeLabel.frame.size.width + 2,
                                     (topBar.frame.size.height / 2) - (upImageView.frame.size.height / 4),
                                     upImageView.frame.size.width / 2,
                                     upImageView.frame.size.height / 2)];
    
    //[topBar addSubview:upImageView];
    
    //[swipeLabel2 removeFromSuperview];
    [swipeLabel setText:[Utilities stringResourceForId:@"help_bar_label_close"]];
    [swipeLabel sizeToFit];
    //swipeLabel2 = [self createBarLabelWithText:@"to close"];
    //[swipeLabel2 setCenter:CGPointMake((swipeLabel2.frame.size.width / 2) + upImageView.frame.origin.x + upImageView.frame.size.width + 2,
    //                                   topBar.frame.size.height / 2)];
    
    //[topBar addSubview:swipeLabel2];
    
    CGRect frame = self.frame;
    frame.origin.y = deviceStatusBar;
    if(IS_IPHONE_X){
        frame.origin.y = 40.0f;
    }
    frame.size.height += 30.0f;
    self.frame = frame;
    
    
    id objVersionLbl = [self viewWithTag:VERSION_LBL_TAG];
    UILabel *versionLbl;
    if([objVersionLbl isKindOfClass:[UILabel class]]){
        versionLbl = (UILabel *)objVersionLbl;
        CGRect versionLblFrame = versionLbl.frame;
        if(IS_IPHONE_X){
            //            versionLblFrame.origin.x -= 11;
            versionLblFrame.origin.y = [[UIScreen mainScreen] bounds].size.height -  (versionLbl.frame.size.height + 20 + 25); //Here 20 Status bar height and 5 is padding.
            
        }else{
            versionLblFrame.origin.y = [[UIScreen mainScreen] bounds].size.height -  (versionLbl.frame.size.height + 20 + 5); //Here 20 Status bar height and 5 is padding.
        }
        versionLbl.frame = versionLblFrame;
    }
    
//    CGRect scrollViewFrame = scrollView.frame;
//    scrollViewFrame.size.height += versionLbl.frame.origin.y - (scrollView.frame.size.height + 35);//Here 25 Contact lbl y offset.
//    scrollView.frame = scrollViewFrame;
    
    [self setIsExpanded:YES];
}

- (void)onCollapse
{
    [upImageView removeFromSuperview];
    
    upImageView = [[UIImageView alloc] initWithImage:upImage];
    [upImageView setFrame:CGRectMake(swipeLabel.frame.origin.x + swipeLabel.frame.size.width + 2,
                                     (topBar.frame.size.height / 2) - (upImageView.frame.size.height / 4),
                                     upImageView.frame.size.width / 2,
                                     upImageView.frame.size.height / 2)];
    
    [topBar addSubview:upImageView];
    
    //[swipeLabel2 removeFromSuperview];
    [swipeLabel setText:[Utilities stringResourceForId:@"help_bar_label"]];
    //swipeLabel2 = [self createBarLabelWithText:@"for help"];
    //[swipeLabel2 setCenter:CGPointMake((swipeLabel2.frame.size.width / 2) + upImageView.frame.origin.x + upImageView.frame.size.width + 2,
    //                                   topBar.frame.size.height / 2)];
    
    //[topBar addSubview:swipeLabel2];
    
    [self setIsExpanded:NO];
}

#pragma mark - Other methods

- (UILabel *)createBarLabelWithText:(NSString *)text
{
    UILabel *barLabel = [[UILabel alloc] init];
    [barLabel setText:text];
    [barLabel setBackgroundColor:[UIColor clearColor]];
    [barLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
    [barLabel sizeToFit];
    
    if (isLight) {
        [barLabel setTextColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities textDarkColor]]]];
    } else {
        [barLabel setTextColor:[UIColor whiteColor]];
    }
    
    return barLabel;
}

- (UILabel *)createLabelWithTitle:(NSString *)title offsetY:(CGFloat)offsetY
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, offsetY, 0, 0)];
    [label setText:title];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    [label sizeToFit];
    
    return label;
}
@end
