//
//  CardOnboardingViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 3/31/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface CardOnboardingViewController : BaseViewController <UIPageViewControllerDelegate, ServiceListener>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet BorderedButton *cancelButton;
@property (weak, nonatomic) IBOutlet BorderedButton *actionButton;

- (IBAction)cancel:(id)sender;
- (IBAction)action:(id)sender;

@end
