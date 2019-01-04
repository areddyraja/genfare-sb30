//
//  PayAsYouGoCell.h
//  CDTATicketing
//
//  Created by CooCooTech on 8/26/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CooCooBase.h"

@interface PayAsYouGoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ticketTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalFareLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *activationsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activationsLabelWidthConstraint;
@property (nonatomic,retain) Product *prod;
-(void)startTimer;
@end
