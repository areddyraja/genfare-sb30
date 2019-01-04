//
//  TicketPageViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 4/13/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BasePageViewController.h"
#import "BaseService.h"
#import "Ticket.h"
#import "WalletContents.h"
#import "Product.h"

FOUNDATION_EXPORT NSString *const POP_NOTIFICATION_NAME;
FOUNDATION_EXPORT int const TICKET_PADDING;
FOUNDATION_EXPORT float const TICKET_CORNER_RADIUS;
FOUNDATION_EXPORT int const TICKET_VIEW_PADDING;

@interface TicketPageViewController : BaseViewController <UIPageViewControllerDataSource, UIAlertViewDelegate, CLLocationManagerDelegate, ServiceListener, UIGestureRecognizerDelegate>

@property (nonatomic, copy) BasePageViewController *(^createCustomBarcodeViewController)();
@property (nonatomic, copy) BasePageViewController *(^createCustomSecurityViewController)();
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) NSString *ticketSourceId;
@property (strong, nonatomic) NSString *cardAccountId;
@property(strong,nonatomic) WalletContents *walletContent;
@property(strong,nonatomic) Product *product;

- (void)reloadForReplacedTicket;
- (void)checkForActiveTickets;
+ (UIView *)pageLabelWithTitle:(NSString *)title frameWidth:(CGFloat)frameWidth;

@end
