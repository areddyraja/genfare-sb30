//
//  OnboardingViewController.h
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 3/22/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "RequestNewCardService.h"
#import "BaseViewController.h"

@interface OnboardingViewController : BaseViewController <iCarouselDataSource, iCarouselDelegate, UIScrollViewDelegate, ServiceListener>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *addCardButton;
@property (weak, nonatomic) IBOutlet UIView *middleView;

@property NSManagedObjectContext *managedObjectContext;
@property (copy) NSArray *cards;

@end
