//
//  CardOnboardingViewController.m
//  CDTATicketing
//
//  Created by CooCooTech on 3/31/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CardOnboardingViewController.h"
#import "CardOnboardingAddViewController.h"
#import "CardOnboardingIntroViewController.h"
#import "CardOnboardingPurchaseViewController.h"
#import "CardOnboardingRegisterViewController.h"
#import "CardSelectionViewController.h"

NSString *const ONBOARDING_TITLE = @"Quick Start";

@interface CardOnboardingViewController ()

@end

@implementation CardOnboardingViewController
{
    NSArray *viewControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:ONBOARDING_TITLE];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    
    CardOnboardingIntroViewController *introViewController = [[CardOnboardingIntroViewController alloc] initWithNibName:@"CardOnboardingIntroViewController" bundle:[NSBundle mainBundle]];
    [introViewController setPageIndex:0];
    
    [controllers addObject:introViewController];
    
    CardOnboardingAddViewController *addCardViewController = [[CardOnboardingAddViewController alloc] initWithNibName:@"CardOnboardingAddViewController" bundle:[NSBundle mainBundle]];
    [addCardViewController setPageIndex:1];
    [addCardViewController setManagedObjectContext:self.managedObjectContext];
    
    [controllers addObject:addCardViewController];
    
    CardOnboardingRegisterViewController *registerViewController = [[CardOnboardingRegisterViewController alloc] initWithNibName:@"CardOnboardingRegisterViewController" bundle:[NSBundle mainBundle]];
    [registerViewController setPageIndex:2];
    
    [controllers addObject:registerViewController];
    
    CardOnboardingPurchaseViewController *purchaseFaresViewController = [[CardOnboardingPurchaseViewController alloc] initWithNibName:@"CardOnboardingPurchaseViewController" bundle:[NSBundle mainBundle]];
    [purchaseFaresViewController setPageIndex:3];
    [purchaseFaresViewController setManagedObjectContext:self.managedObjectContext];
    
    [controllers addObject:purchaseFaresViewController];
    
    viewControllers = [[NSArray alloc] initWithArray:[controllers copy]];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    [self.pageViewController.view setFrame:[self.contentView bounds]];
    
    [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageViewController];
    
    [self.contentView addSubview:[self.pageViewController view]];
    
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [view setScrollEnabled:NO];
        }
    }
    
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Disable iOS7+ swipe back gesture
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.interactivePopGestureRecognizer setDelegate:self];
        [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isEqual:self.navigationController.interactivePopGestureRecognizer]) {
        return NO;
    } else {
        return YES;
    }
}
// End Disable iOS7+ swipe back gesture

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)action:(id)sender {
    if (self.pageControl.currentPage == 0) {
        __weak typeof(self) weakSelf = self;
        
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES
                                         completion:^(BOOL finished) {
                                             [weakSelf.pageControl setCurrentPage:1];
                                             [weakSelf.actionButton setTitle:@"Add This Card" forState:UIControlStateNormal];
                                         }];
    } else if (self.pageControl.currentPage == 1) {
        [self showProgressDialog];
        
        if ([[Utilities walletId] length] > 0) {
            CardOnboardingAddViewController *addCardViewController = [viewControllers objectAtIndex:1];
            
            if (addCardViewController) {
                NSString *nickname = addCardViewController.nicknameText.text;
                NSString *description = addCardViewController.descriptionText.text;
                
//                RequestNewCardService *newCardService = [[RequestNewCardService alloc] initWithListener:self nickname:nickname description:description managedObjectContext:self.managedObjectContext];
//                [newCardService execute];
                
                RequestNewCardService *newCardService = [[RequestNewCardService alloc] initWithListener:self nickname:nickname description:description managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId] personId:[StoredData userData].accountId];
                //        [[RequestNewCardService alloc] initWithListener:self nickname:cardName description:cardDescription managedObjectContext:self.managedObjectContext];
                [newCardService execute];
                
            }
        } else {
            RequestNewWalletService *walletsService = [[RequestNewWalletService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
            [walletsService execute];
        }
    } else if (self.pageControl.currentPage == 2) {
        __weak typeof(self) weakSelf = self;
        
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:3]] direction:UIPageViewControllerNavigationDirectionForward animated:YES
                                         completion:^(BOOL finished) {
                                             [weakSelf.pageControl setCurrentPage:3];
                                             [weakSelf.actionButton setTitle:@"Purchase" forState:UIControlStateNormal];
                                         }];
    } else {
        //Got rid of this to prevent going to the home screen where services calls create card concurrency issues
        //[self.navigationController popViewControllerAnimated:YES];
        
        CardSelectionViewController *cardSelectionView = [[CardSelectionViewController alloc] initWithNibName:@"CardSelectionViewController" bundle:[NSBundle mainBundle]];
        [cardSelectionView setManagedObjectContext:self.managedObjectContext];
        [self.navigationController pushViewController:cardSelectionView animated:YES];
    }
}

#pragma mark - Background service declaration and callbacks

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    if ([service isMemberOfClass:[RequestNewCardService class]]) {
        GetCardsService *getCardsService = [[GetCardsService alloc] initWithListener:self
                                                                          walletUuid:[Utilities walletId]
                                                                managedObjectContext:self.managedObjectContext];
        [getCardsService execute];
        
        __weak typeof(self) weakSelf = self;
        
        [self.pageViewController setViewControllers:[NSArray arrayWithObject:[viewControllers objectAtIndex:2]] direction:UIPageViewControllerNavigationDirectionForward animated:YES
                                         completion:^(BOOL finished) {
                                             [weakSelf.pageControl setCurrentPage:2];
                                             [weakSelf.actionButton setTitle:@"Continue" forState:UIControlStateNormal];
                                         }];
    } else if ([service isMemberOfClass:[RequestNewWalletService class]]) {
        CardOnboardingAddViewController *addCardViewController = [viewControllers objectAtIndex:1];
        
        if (addCardViewController) {
            NSString *nickname = addCardViewController.nicknameText.text;
            NSString *description = addCardViewController.descriptionText.text;
            
//            RequestNewCardService *newCardService = [[RequestNewCardService alloc] initWithListener:self nickname:nickname description:description managedObjectContext:self.managedObjectContext];
//            [newCardService execute];
            
            RequestNewCardService *newCardService = [[RequestNewCardService alloc] initWithListener:self nickname:nickname description:description managedObjectContext:self.managedObjectContext uuid:[Utilities deviceId] personId:[StoredData userData].accountId];
            //        [[RequestNewCardService alloc] initWithListener:self nickname:cardName description:cardDescription managedObjectContext:self.managedObjectContext];
            [newCardService execute];
        }
    }
    
    [self dismissProgressDialog];
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];

    if ([service isMemberOfClass:[GetCardsService class]]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"error"]
                                                            message:[Utilities stringResourceForId:@"createwalletFailureMessage"]
                                                           delegate:self
                                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                                  otherButtonTitles:nil, nil];
        
        [alertView show];
    }
}

@end
