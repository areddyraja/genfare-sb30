//
//  TicketCardSeletionViewController.h
//  CooCooBase
//
//  Created by ibasemac3 on 12/15/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "BaseViewController.h"

@interface TicketCardSeletionViewController : BaseViewController
{
    IBOutlet UIButton *btnImgCard;
    IBOutlet UIButton *btnContinue;
    NSIndexPath *selectedIndexPath;
    
}
@property(copy,nonatomic)NSArray *ticketsArray;
@property (weak, nonatomic) IBOutlet UILabel *pageButton1;
@property (weak, nonatomic) IBOutlet UILabel *pageButton2;
@property (weak, nonatomic) IBOutlet UILabel *pageButton3;
@property (weak, nonatomic) IBOutlet UILabel *pageButton4Done;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
-(IBAction)btnImgCardTapped:(id)sender;

@end
