//
//  PurchaseTicketTableViewCell.m
//  CooCooBase
//
//  Created by ibasemac3 on 12/14/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "PurchaseTicketTableViewCell.h"
#import "CooCooBase.h"

@implementation PurchaseTicketTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.plusButton.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]] ;
    self.minusButton.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]] ;
}
-(void)prepareForReuse{
    [super prepareForReuse];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
