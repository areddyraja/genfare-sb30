//
//  CardManagementCell.h
//  CooCooBase

//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardManagementCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cardImage;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fareLabel;
@property (weak, nonatomic) IBOutlet UILabel *huuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIButton *assignButton;

- (void)addTargetForAssignButton:(id)target action:(SEL)action cardUuid:(NSString *)cardUuid;

- (IBAction)assign:(id)sender;

@end
