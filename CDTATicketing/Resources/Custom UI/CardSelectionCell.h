//
//  CardSelectionCell.h
//  CDTATicketing
//
//  Created by CooCooTech on 4/6/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardSelectionCell : UITableViewCell

FOUNDATION_EXPORT NSString *const CARD_SELECTION_CELL;

@property (weak, nonatomic) IBOutlet UIImageView *cardImage;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end
