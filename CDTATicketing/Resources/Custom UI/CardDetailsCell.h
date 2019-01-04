//
//  CardDetailsCell.h
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 3/28/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CooCooBase.h"

@interface CardDetailsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (weak, nonatomic) IBOutlet UIView *viTitle;
@property (weak, nonatomic) IBOutlet UIView *viDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnAssign;

@end
