//
//  RegisteredDeviceCell.m
//  CooCooBase
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "CardManagementCell.h"

@interface CardManagementCell()

@property (weak, nonatomic) id assignTarget;
@property (nonatomic) SEL assignSelector;
@property (copy, nonatomic) NSString *cardUuid;

@end

@implementation CardManagementCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addTargetForAssignButton:(id)target action:(SEL)action cardUuid:(NSString *)cardUuid;
{
    self.assignTarget = target;
    self.assignSelector = action;
    self.cardUuid = cardUuid;
}

- (IBAction)assign:(id)sender {
    if (self.assignTarget) {
        [self.assignTarget performSelector:self.assignSelector withObject:self.cardUuid afterDelay:0];
    }
}

@end
