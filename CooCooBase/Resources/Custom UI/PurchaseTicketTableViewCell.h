//
//  PurchaseTicketTableViewCell.h
//  CooCooBase
//
//  Created by ibasemac3 on 12/14/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseTicketTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *riderName;

@property (weak, nonatomic) IBOutlet UILabel *ticketAmonut;
@property (weak, nonatomic) IBOutlet UILabel *riderTypeDesc;
@property (weak, nonatomic) IBOutlet UILabel *fareZoneCodeDesc;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UILabel *ticketsCount;
@property (weak, nonatomic) IBOutlet UILabel *totalTicketsFare;
@end
