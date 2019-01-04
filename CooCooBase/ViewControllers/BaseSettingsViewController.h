//
//  BaseSettingsViewController.h
//  Pods
//
//  Created by CooCooTech on 7/23/15.
//
//

#import "IASKAppSettingsViewController.h"
#import "BaseViewController.h"
#import "BaseService.h"

@interface BaseSettingsViewController : IASKAppSettingsViewController <IASKSettingsDelegate, UIGestureRecognizerDelegate, ServiceListener>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) HelpSliderView *helpSlider;

- (void)showProgressDialog;
- (void)dismissProgressDialog;

@end
