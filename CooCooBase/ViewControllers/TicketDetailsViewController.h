//
//  TicketDetailsViewController.h
//  CooCooBase
//
//  Created by ibasemac3 on 12/14/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "BaseViewController.h"

@interface TicketDetailsViewController : BaseViewController
@property(copy,nonatomic)NSArray *seletedProducts;
@property(copy,nonatomic)NSArray *seletedProductsPayasyougo;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageButton1;
@property (weak, nonatomic) IBOutlet UILabel *pageButton2;
@property (weak, nonatomic) IBOutlet UILabel *pageButton3;
@property (weak, nonatomic) IBOutlet UILabel *pageButton4Done;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITableView *productsTableView;

@end
