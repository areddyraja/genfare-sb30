//
//  RegisteredDeviceCell.h
//  CooCooBase
//
//  Created by John Scuteri on 9/12/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisteredDeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *registeredDate;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *registeredDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImage;

@end
