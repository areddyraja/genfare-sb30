//
//  CDTATicketsViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 8/25/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//


#import "CooCooBase.h"
#import "iCarousel.h"
#import "GetCardsService.h"
#import "CAPSPageMenu.h"

@class CAPSPageMenu;
@interface CDTATicketsViewController : BaseTicketsViewController <iCarouselDataSource, iCarouselDelegate, ServiceListener, CAPSPageMenuDelegate>


@property (weak, nonatomic) IBOutlet UIView *segmentedContainerView;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *btnCardDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblNickname;
@property (weak, nonatomic) IBOutlet UILabel *lblShadow;

- (IBAction)segmentValueChanged:(id)sender;

@end
