//
//  TicketCell.h
//  CooCooBase
//
//  Created by CooCooTech on 8/19/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iRide-Swift.h"

@interface TicketCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *activationsLabel;
@property (weak, nonatomic) IBOutlet GFMenuButton *activeBtn;
@property (weak, nonatomic) IBOutlet GFMenuButton *inActiveBtn;
@property (weak, nonatomic) IBOutlet GFMenuButton *activeRideBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel;

@end
