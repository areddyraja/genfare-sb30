//
//  BaseViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpSliderView.h"
#import "NSBundle+BaseResourcesBundle.h"
#import "NSBundle+LoadOverride.h"
#import "UIImage+LoadOverride.h"
#import "AuthorizeTokenService.h"
#import "CustomAlertAppUpdateController.h"


//FOUNDATION_EXPORT float const STATUS_BAR_HEIGHT;
//FOUNDATION_EXPORT float const NAVIGATION_BAR_HEIGHT;
FOUNDATION_EXPORT float const HELP_SLIDER_PADDING;
FOUNDATION_EXPORT float const TOUCH_PADDING;

@interface BaseViewController : UIViewController <UIGestureRecognizerDelegate,CustomAlertAppUpdateControllerDelegate,ServiceListener>
 @property (nonatomic,readwrite)BOOL refactorView;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) HelpSliderView *helpSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void)showProgressDialog;
- (void)dismissProgressDialog;
- (IBAction)dismissController:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)showSideMenu:(UIButton *)sender;
- (void)showLoginScreen:(NSNotification *)notification;
- (void)addGesturesToHelpSlider;

- (UIAlertView *)offlineAlertViewWithDelegate:(nullable id)delegate tag:(NSInteger)tag;

@end
