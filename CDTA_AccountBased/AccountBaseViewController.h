//
//  AccountBaseViewController.h
//  CDTATicketing Beta
//
//  Created by Gaian Solutions on 4/27/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpSliderView.h"
#import "CustomAlertAppUpdateController.h"
#import "BaseViewController.h"

//FOUNDATION_EXPORT float const STATUS_BAR_HEIGHT;
//FOUNDATION_EXPORT float const NAVIGATION_BAR_HEIGHT;
FOUNDATION_EXPORT float const HELP_SLIDER_PADDING;
FOUNDATION_EXPORT float const TOUCH_PADDING;

@interface AccountBaseViewController : UIViewController<CustomAlertAppUpdateControllerDelegate, ServiceListener>{
    IBOutlet UIImageView *cardlogoImgview;
}
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) HelpSliderView *helpSlider;
- (void)showProgressDialog;
- (void)dismissProgressDialog;
- (void) refreshView;

@end
