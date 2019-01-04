//
//  SavedTripCell.h
//  CDTA
//
//  Created by CooCooTech on 9/26/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedTripCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *departLabel;
@property (weak, nonatomic) IBOutlet UILabel *arriveLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationAndPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) UIView *detailsView;

@end
