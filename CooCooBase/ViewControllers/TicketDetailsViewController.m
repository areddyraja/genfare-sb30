//
//  TicketDetailsViewController.m
//  CooCooBase
//
//  Created by ibasemac3 on 12/14/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "TicketDetailsViewController.h"
#import "TicketCardSeletionViewController.h"
#import "CooCooBase.h"
@interface TicketDetailsViewController ()
{
    float totalAmount;
    NSMutableArray *selProductsArray;
}

@end

@implementation TicketDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Purchase" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
//    self.pageButton1.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
//    self.pageButton3.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
//    self.pageButton4Done.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
    selProductsArray = [NSMutableArray arrayWithArray:self.seletedProducts];
    totalAmount = 0;
    for (int j =0; j<  selProductsArray.count; j++) {
        totalAmount = totalAmount + [[[selProductsArray objectAtIndex:j]valueForKey:@"total_ticket_fare"]floatValue];
    }
    self.totalAmountLabel.text = [NSString stringWithFormat:@"You Will Be Charged :$ %.2f",totalAmount];
    // Do any additional setup after loading the view.
    self.title = @"Purchase Passes";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateContinueButtonBgColor];
}
-(void)updateContinueButtonBgColor{
    if (selProductsArray .count > 0) {
        [_continueButton setEnabled:YES];
        [_continueButton setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities continueButtonBgColor]]]];
    }else{
        [_continueButton setEnabled:NO];
        [_continueButton setBackgroundColor:[UIColor lightGrayColor]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)secondPageContinueClicked:(id)sender {
    
    
    TicketCardSeletionViewController *ticketview = [[TicketCardSeletionViewController alloc]initWithNibName:@"TicketCardSeletionViewController" bundle:nil];
    [ticketview setManagedObjectContext:self.managedObjectContext];
    
    NSMutableArray *productsListArray = [[NSMutableArray alloc]init];
    if (selProductsArray.count >0) {
        
//        NSMutableArray *filteredProdcutArray = [selProductsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@)", @"Period Pass"] ];
        NSMutableArray *filteredProdcutArray = [selProductsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription != %@)", @"Stored Value"] ];
        for (int i =0; i < filteredProdcutArray.count; i++) {
            NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
            // [dict setObject:[[selProductsArray objectAtIndex:i]valueForKey:@"productId"] forKey:@"ticketId"];
            [dict setObject:[[filteredProdcutArray objectAtIndex:i]valueForKey:@"offeringId"] forKey:@"offeringId"];
            [dict setObject:[[filteredProdcutArray objectAtIndex:i]valueForKey:@"ticket_count"] forKey:@"quantity"];
            
            [productsListArray addObject:dict];
            
        }
        
        NSArray *storedValueproducts = [selProductsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@) ",@"Stored Value"] ];
        
        for(NSDictionary *Dict in storedValueproducts){
            NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
            [newDict setValue:Dict[@"offeringId"]  forKey:@"offeringId"];
            [newDict setValue:[Dict objectForKey:@"total_ticket_fare"]  forKey:@"value"];
            [productsListArray addObject:newDict];
        }
        
        
        
        // [selProductsArray replaceObjectAtIndex:selProductsArray.count+1 withObject:newDict];
    }
    ticketview.ticketsArray = productsListArray;
    
    [self.navigationController pushViewController:ticketview animated:YES];
}

- (IBAction)onClickofAddMoreProducts:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (selProductsArray.count >0) {
        return selProductsArray.count;
    }else{
        return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
  //  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    
 //   if (cell == nil)
 //   {
         UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Identifier"];
   // }
    
    UILabel *storedlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, cell.frame.size.width-50,20)];
    storedlabel.text = [[selProductsArray objectAtIndex:indexPath.row]valueForKey:@"productDescription"];
    [storedlabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [storedlabel setNumberOfLines:0];
    [storedlabel setAdjustsFontSizeToFitWidth:YES];
    [storedlabel setMinimumScaleFactor:0.5];
    [cell.contentView addSubview:storedlabel];
    
    float f = [[[selProductsArray objectAtIndex:indexPath.row]valueForKey:@"total_ticket_fare"] floatValue];

    
    UILabel *storedlabel1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, cell.frame.size.width-50,20)];
    storedlabel1.text =[NSString stringWithFormat:@" $ %.2f",f];
    [storedlabel setNumberOfLines:0];
    [storedlabel setAdjustsFontSizeToFitWidth:YES];
    [storedlabel setMinimumScaleFactor:0.5];
    [cell.contentView addSubview:storedlabel1];
    


    UILabel *storedlabel2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, cell.frame.size.width-50,20)];
    NSString * ticketCountString = [[selProductsArray objectAtIndex:indexPath.row]valueForKey:@"ticket_count"];
    if ([ticketCountString isEqualToString:@"0"]) {
        NSString * naStr = @"NA";
        storedlabel2.text =[NSString stringWithFormat:@" Quantity :  %@",naStr];
    }else{
        storedlabel2.text =[NSString stringWithFormat:@" Quantity :  %@",[[selProductsArray objectAtIndex:indexPath.row]valueForKey:@"ticket_count"]];
    }
    [storedlabel setNumberOfLines:0];
    [storedlabel setAdjustsFontSizeToFitWidth:YES];
    [storedlabel setMinimumScaleFactor:0.5];
    [cell.contentView addSubview:storedlabel2];
    
    UIButton *cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 20, 20)];
    cancelButton.tag = indexPath.row +1 ;
    [cancelButton setBackgroundImage:[UIImage loadOverrideImageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onClickofCancel:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = cancelButton;
    
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
    
}
-(void)onClickofCancel:(UIButton *)sender{
    
    [selProductsArray removeObjectAtIndex:sender.tag -1];
    [_productsTableView reloadData];
    [self updateContinueButtonBgColor];
   // selProductsArray = [NSMutableArray arrayWithArray:self.seletedProducts];
    totalAmount = 0;
    for (int j =0; j<  selProductsArray.count; j++) {
        totalAmount = totalAmount + [[[selProductsArray objectAtIndex:j]valueForKey:@"total_ticket_fare"]floatValue];
    }
    self.totalAmountLabel.text = [NSString stringWithFormat:@"You Will Be Charged for %d rides :$ %.2f",selProductsArray.count,totalAmount];
    
}

@end
