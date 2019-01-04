//
//  TripHistoryCell.h
//  CDTA
//
//  Created by CooCooTech on 3/26/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deleteImage;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@end
