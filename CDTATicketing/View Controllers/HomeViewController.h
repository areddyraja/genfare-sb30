//
//  HomeViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 6/17/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "CooCooBase.h"
#import "AddAccountViewController.h"
#import "CustomBadge.h"
#import "NSString+FontAwesome.h"
#import "UIImage+FontAwesome.h"
#import "FontAwesomeButton.h"
#import "CustomAlertAppUpdateController.h"


@interface HomeViewController : BaseViewController <ServiceListener,UITableViewDelegate,UITableViewDataSource>{
    CustomBadge *alertsBadge;
    BOOL isCardsServiceRunning;
    BOOL launchTicketWallet;
    BOOL launchTicketPurchase;
    NSArray *dashboardArray;
    NSArray *imageArray;
    CGFloat helpSliderOrigin;
    float deviceStatusBar;
    UIAlertView *singleAlertView;
    CGFloat screenHeight;

}

@property (weak, nonatomic) IBOutlet UIButton *alertsButton;
@property (weak, nonatomic) IBOutlet UIButton *routesButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet HomeButton *myTicketsButton;

- (IBAction)myTickets:(id)sender;
- (IBAction)tripPlanner:(id)sender;
- (IBAction)purchaseTickets:(id)sender;
- (IBAction)stops:(id)sender;
- (IBAction)routes:(id)sender;
- (IBAction)alerts:(id)sender;
- (IBAction)contact:(id)sender;

@end
