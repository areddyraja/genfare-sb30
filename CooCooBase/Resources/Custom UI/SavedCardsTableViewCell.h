//
//  SavedCardsTableViewCell.h
//  CooCooBase
//
//  Created by Gaian Solutions on 4/17/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedCards.h"

@interface SavedCardsTableViewCell : UITableViewCell
@property (nonatomic,weak)IBOutlet UIButton *deleteButton;
@property (nonatomic,weak)IBOutlet UIImageView *Cardimage;
@property (nonatomic,weak)IBOutlet UILabel *canrdNumberLabel;
@property (nonatomic,weak)IBOutlet UIView *CardBgview;
@property (nonatomic,retain)SavedCards *card;
@end
