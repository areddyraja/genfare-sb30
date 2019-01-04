//
//  NearbyStopCell.h
//  CDTA
//
//  Created by CooCooTech on 10/2/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ShowArrivalsCallback)();
typedef void(^SelectCellCallback)();

FOUNDATION_EXPORT int const SHOW_ARRIVALS_TAG;

@interface NearbyStopCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stopName;
@property (weak, nonatomic) IBOutlet UILabel *showArrivalsLabel;
@property (copy, nonatomic) ShowArrivalsCallback showArrivalsCallback;
@property (copy, nonatomic) SelectCellCallback selectCellCallback;
@property (strong, nonatomic) UIView *arrivalsView;

@end
