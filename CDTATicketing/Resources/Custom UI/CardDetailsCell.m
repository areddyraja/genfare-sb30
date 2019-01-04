//
//  CardDetailsCell.m
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 3/28/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CardDetailsCell.h"

@implementation CardDetailsCell

- (void)awakeFromNib {
    [super awakeFromNib];
     //Initialization code
    self.viTitle.layer.borderColor = [UIColor colorWithRed:231/255.0 green:233/255.0 blue:238/255.0 alpha:1].CGColor;
    self.viTitle.layer.borderWidth = 1.0;
    self.viTitle.layer.masksToBounds = YES;
    
    self.viDescription.layer.borderColor = [UIColor colorWithRed:231/255.0 green:233/255.0 blue:238/255.0 alpha:1].CGColor;
    self.viDescription.layer.borderWidth = 1.0;
    self.viDescription.layer.masksToBounds = YES;
    
//    [self.btnAssign setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
