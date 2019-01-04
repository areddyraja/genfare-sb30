//
//  CardDetailsViewController.h
//  CDTATicketing
//
//  Created by Andrey Kasatkin on 3/23/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "Card.h"
#import "AssignCardService.h"
#import "UnassignCardService.h"
#import "ReleaseCardService.h"

@interface CardDetailsViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, ServiceListener>{
    NSArray *walletarray;
}

@property (nonatomic, weak) Card *card;
@property (weak, nonatomic) IBOutlet UIImageView *cardImage;
@property (weak, nonatomic) IBOutlet UITableView *cardTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnTransfer;

- (IBAction)transferCard:(id)sender;

@end
