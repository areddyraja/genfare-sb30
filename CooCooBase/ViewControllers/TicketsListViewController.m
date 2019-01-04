//
//  TicketsListViewController.m
//  CooCooBase
//
//  Created by ibasemac3 on 12/14/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "TicketsListViewController.h"
#import "PurchaseTicketTableViewCell.h"
#import "TicketDetailsViewController.h"
#import "GetProductsService.h"
#import "Utilities.h"
#import "Product.h"
#import "CooCooAccountUtilities1.h"
#import "GetConfigApi.h"
#import "CooCooBase.h"
#import "ThemeView.h"


@interface TicketsListViewController ()<UITextFieldDelegate>
{
    NSArray *priceArray;
    NSArray *faresArray;
    NSArray *routesAray;
    
    NSMutableArray *productsListArray;
    NSMutableArray *productsListArrayPayasyouGo;
    int quantityValue;
    int alertamount;
    int totalAmount;
    NSArray *totalProdcutArray;
    NSError *error;
    NSManagedObjectContext *managedObjectContext;
    NSArray *accounts;
    NSString *payasyougo;
    int walletMax;
    int walletMin;
    UIAlertView *singleAlertView;
}
@property (strong, nonatomic) IBOutlet UILabel *payAsYouGoLbl;
@property (weak, nonatomic) IBOutlet UILabel *dollerSymbolLabel;

@end

@implementation TicketsListViewController
static NSString *cellIdentifier = @"PurchaseTicketTableViewCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Purchase Passes"];
        
    }
    //commit
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.pageButton2.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
//    self.pageButton3.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
//    self.pageButton4Done.backgroundColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
    
     self.continueButton.layer.cornerRadius = 5;
    [self.continueButton.layer setMasksToBounds:YES];
    
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Purchase" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];

 
    GetProductsService *productsService = [[GetProductsService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
    [productsService execute];

    [self fetchProducts];

    
      walletMax = [[[NSUserDefaults standardUserDefaults]valueForKey:@"Config_Max"] intValue];
      walletMin = [[[NSUserDefaults standardUserDefaults]valueForKey:@"Config_Min"] intValue];

     if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:@"connectivityAlertTitle"] message:[Utilities stringResourceForId:@"connectivityAlertMessage"] preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *close = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:[Utilities closeButtonTitle]] style:UIAlertViewStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [self.navigationController popViewControllerAnimated:YES];
            
        }];
        [alertController addAction:close];
        [self presentViewController:alertController animated:NO completion:nil];
        
    }
    
    NSLog(@" database file path%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject]);

     GetConfigApi *contents = [[GetConfigApi alloc]initWithListener:self];
    [contents execute];
    
   // NSManagedObjectContext *context = //Get it from AppDelegate
    
   
 
    _payasgoTextfield.layer.borderWidth = 1;
    _payasgoTextfield.layer.borderColor = [[UIColor blackColor]CGColor];
    [self targetMethod];
     if (error != nil) {
        
        //Deal with failure
    }
    else {
        
      
 
         //Deal with success
    }
     NSMutableArray *filteredProdcutArrayPayasyougofortext = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@) AND isActivationOnly == 0 ",@"Stored Value"] ];
    
    if(totalProdcutArray.count == 0 ){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:[Utilities purchaseProductTitle]] message:[Utilities stringResourceForId:[Utilities purchaseProductMessage]] preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *close = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:[Utilities closeButtonTitle]] style:UIAlertViewStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //[self.navigationController popViewControllerAnimated:YES];
            
        }];
        [alertController addAction:close];
        [self presentViewController:alertController animated:NO completion:nil];
    }
        
    for (int i =0; i < filteredProdcutArrayPayasyougofortext.count; i++) {
        
        
        self.payAsYouGoLbl.text =[[filteredProdcutArrayPayasyougofortext  objectAtIndex:i] valueForKey:@"productDescription"];
        
    }
    
    if (filteredProdcutArrayPayasyougofortext.count == 0) {
        self.payasgoTextfield.hidden = YES;
        self.dollerSymbolLabel.hidden = YES;
    }else{
        self.payasgoTextfield.hidden = NO;
        self.dollerSymbolLabel.hidden = NO;
    }

    self.continueButton.enabled = NO;
    self.continueButton.backgroundColor = [UIColor lightGrayColor];
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    _mailLabel.text = [NSString stringWithFormat:@"Welcome %@",account.emailaddress];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)threadSuccessWithClass:(id)service response:(id)response{
 
    if([service isMemberOfClass:[GetProductsService class]]){
        [self fetchProducts];
    }
//    walletMax = [[[NSUserDefaults standardUserDefaults]valueForKey:@"Config_Max"] intValue];
    [self dismissProgressDialog];
}


-(void)fetchProducts{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:PRODUCT_MODEL];
    
    NSError *error = nil;
    
    totalProdcutArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    if(totalProdcutArray.count == 0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:[Utilities purchaseProductTitle]] message:[Utilities stringResourceForId:[Utilities purchaseProductMessage]] preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *close = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:[Utilities closeButtonTitle]] style:UIAlertViewStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        [alertController addAction:close];
        [self presentViewController:alertController animated:NO completion:nil];
    }else{
        [self targetMethod];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    

}
-(void)targetMethod{
    
  //  totalProdcutArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"Product_List"];
    productsListArray = [[NSMutableArray alloc]init];
    if (totalProdcutArray.count >0) {
//         NSMutableArray *filteredProdcutArray = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@)", @"Period Pass"] ];
            NSMutableArray *filteredProdcutArray = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription != %@)", @"Stored Value"] ];
        for (int i =0; i < filteredProdcutArray.count; i++) {
            
            NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
            NSMutableString *payasyougo =  [[filteredProdcutArray  objectAtIndex:i]  valueForKey:@"ticketTypeDescription"];
            // if([payasyougo isEqualToString:@"Period Pass"]) {
            [dict setObject:[[filteredProdcutArray  objectAtIndex:i] valueForKey:@"productDescription"] forKey:@"productDescription"];
            [dict setObject:[[filteredProdcutArray  objectAtIndex:i] valueForKey:@"offeringId"] forKey:@"offeringId"];
                 [dict setObject:[[filteredProdcutArray  objectAtIndex:i] valueForKey:@"ticketId"] forKey:@"ticketId"];
            [dict setObject:[[filteredProdcutArray objectAtIndex:i] valueForKey:@"price"] forKey:@"price"];
            [dict setObject:[[filteredProdcutArray  objectAtIndex:i] valueForKey:@"ticketTypeDescription"] forKey:@"ticketTypeDescription"];
            [dict setObject:@"0" forKey:@"ticket_count"];
            [dict setObject:@"0" forKey:@"total_ticket_fare"];
            [productsListArray addObject:dict];
           //  }
        }
        [self.productsTableView reloadData];
    }
}
-(void)payasyougo{
    productsListArrayPayasyouGo = [[NSMutableArray alloc]init];
     if (totalProdcutArray.count >0) {
      NSMutableArray *filteredProdcutArrayPayasyougo = [totalProdcutArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(ticketTypeDescription == %@) AND isActivationOnly == 0 ",@"Stored Value"] ];
    for (int i =0; i < filteredProdcutArrayPayasyougo.count; i++) {
        if(self.payasgoTextfield.text.length>0){
        NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
             [dict setObject:[[filteredProdcutArrayPayasyougo  objectAtIndex:i] valueForKey:@"productDescription"] forKey:@"productDescription"];
            [dict setObject:[[filteredProdcutArrayPayasyougo  objectAtIndex:i] valueForKey:@"offeringId"] forKey:@"offeringId"];
            [dict setObject:[[filteredProdcutArrayPayasyougo  objectAtIndex:i] valueForKey:@"ticketId"] forKey:@"ticketId"];
            [dict setObject:[[filteredProdcutArrayPayasyougo objectAtIndex:i] valueForKey:@"price"] forKey:@"price"];
            [dict setObject:[[filteredProdcutArrayPayasyougo  objectAtIndex:i] valueForKey:@"ticketTypeDescription"] forKey:@"ticketTypeDescription"];
 
            [dict setObject:@"0" forKey:@"ticket_count"];
            [dict setObject:self.payasgoTextfield.text forKey:@"total_ticket_fare"];
            [productsListArrayPayasyouGo addObject:dict];
        
            [[NSUserDefaults standardUserDefaults]setObject:dict[@"offeringId"] forKey:@"offeringIdOfPayasyougo"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        }
    }
}
    -(void)dictForPayAsYouGo{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    payasyougo= [formatter numberFromString:_payasgoTextfield.text];
 _payasgoTextfield.delegate = self;
        
        [[NSUserDefaults standardUserDefaults]setObject:payasyougo forKey:@"payasyougoamount"];
        [[NSUserDefaults standardUserDefaults]synchronize];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (productsListArray.count >0) {
        return productsListArray.count;
    }else{
    return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    PurchaseTicketTableViewCell *cell = (PurchaseTicketTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
    if (cell == nil) {
        NSArray *nib = [[NSBundle baseResourcesBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [self setUpCell:cell atIndexPath:indexPath];
    
    
    return cell;
    // }
}

- (void)setUpCell:(PurchaseTicketTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *payasyougo = @"Stored Value";
   
    
    if (![[[productsListArray objectAtIndex:indexPath.row] valueForKey:@"productDescription"] isEqual:[NSNull null]]) {
        cell.riderName.text = [[productsListArray objectAtIndex:indexPath.row] valueForKey:@"productDescription"];

    }
   
    if (![[[productsListArray objectAtIndex:indexPath.row] valueForKey:@"price"] isEqual:[NSNull null]]) {
        cell.ticketAmonut.text = [NSString stringWithFormat:@"Fare $%0.2f",[[[productsListArray objectAtIndex:indexPath.row] valueForKey:@"price"] floatValue]];
    }
   
    if (![[[productsListArray objectAtIndex:indexPath.row] valueForKey:@"productDescription"] isEqual:[NSNull null]]) {
       
        cell.riderTypeDesc.text = [[productsListArray objectAtIndex:indexPath.row] valueForKey:@"productDescription"];
        
    }
   // if(indexPath.row==productsListArray.count-1){
        ThemeView *lineView = [[ThemeView alloc] initWithFrame:CGRectMake(0,
                                                                    cell.contentView.frame.size.height - 1.0,
                                                                    cell.contentView.frame.size.width, 1)];
        
//        lineView.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities buttonBGColor]]];
        [cell.contentView addSubview:lineView];
        
   // }
    cell.totalTicketsFare.text  = [NSString stringWithFormat:@"$%0.2f",[[[productsListArray objectAtIndex:indexPath.row] valueForKey:@"total_ticket_fare"]floatValue]];
    cell.ticketsCount.text = [[productsListArray objectAtIndex:indexPath.row] valueForKey:@"ticket_count"];
    [cell.plusButton addTarget:self action:@selector(increaseTicketClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.minusButton addTarget:self action:@selector(decreaseTicketClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)increaseTicketClicked:(UIButton*)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.productsTableView];
    NSIndexPath *selectedIndexPath = [self.productsTableView indexPathForRowAtPoint:buttonPosition];
    NSLog(@"Increment selectedIndexPath @%d",selectedIndexPath.row);

    quantityValue = [[[productsListArray objectAtIndex:selectedIndexPath.row]objectForKey:@"ticket_count"] intValue] + 1;
//    quantityValue = quantityValue + 1;
    
    PurchaseTicketTableViewCell *cell = (PurchaseTicketTableViewCell*)[self.productsTableView cellForRowAtIndexPath:selectedIndexPath];
    float totalfare = quantityValue * [[[productsListArray objectAtIndex:selectedIndexPath.row] valueForKey:@"price"] floatValue];
    alertamount = totalfare;

    NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
    NSDictionary *oldDict = (NSDictionary *)[productsListArray objectAtIndex:selectedIndexPath.row];
    [newDict addEntriesFromDictionary:oldDict];
    [newDict setObject:[NSString stringWithFormat:@"%d",quantityValue] forKey:@"ticket_count"];
    [newDict setObject:[NSString stringWithFormat:@"%f",totalfare] forKey:@"total_ticket_fare"];
    [productsListArray replaceObjectAtIndex:selectedIndexPath.row withObject:newDict];
    
     self.continueButton.enabled = YES;
     [self setUpCell:cell atIndexPath:selectedIndexPath];
     [self.productsTableView reloadData];
    self.continueButton.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities continueButtonBgColor]]];
    self.continueButton.layer.cornerRadius = 5;
    
    [self showTotalAmount];
    
}
-(void)decreaseTicketClicked:(UIButton*)sender{
    NSLog(@"Decrement");
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.productsTableView];
    NSIndexPath *selectedIndexPath = [self.productsTableView indexPathForRowAtPoint:buttonPosition];
    
        PurchaseTicketTableViewCell *cell = (PurchaseTicketTableViewCell*)[self.productsTableView cellForRowAtIndexPath:selectedIndexPath];
       quantityValue = [[[productsListArray objectAtIndex:selectedIndexPath.row]objectForKey:@"ticket_count"] intValue];
    
      if(quantityValue >=1){
          quantityValue = [[[productsListArray objectAtIndex:selectedIndexPath.row]objectForKey:@"ticket_count"] intValue] - 1;


        float totalfare = quantityValue * [[[productsListArray objectAtIndex:selectedIndexPath.row] valueForKey:@"price"] floatValue];
          NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
          NSDictionary *oldDict = (NSDictionary *)[productsListArray objectAtIndex:selectedIndexPath.row];
          [newDict addEntriesFromDictionary:oldDict];
          [newDict setObject:[NSString stringWithFormat:@"%d",quantityValue] forKey:@"ticket_count"];
          [newDict setObject:[NSString stringWithFormat:@"%f",totalfare] forKey:@"total_ticket_fare"];
          
          [productsListArray replaceObjectAtIndex:selectedIndexPath.row withObject:newDict];
        
           [self setUpCell:cell atIndexPath:selectedIndexPath];
          [self.productsTableView reloadData];
    }
    
    [self showTotalAmount];
}

-(void)showTotalAmount {
    float amount = 0;
    for (int i =0; i< productsListArray.count; i++) {
        if (![[[productsListArray objectAtIndex:i] valueForKey:@"ticket_count"] isEqualToString:@"0"]) {
            amount = amount + [[[productsListArray objectAtIndex:i]valueForKey:@"total_ticket_fare"]floatValue];
        }
    }
    float payAsYouGo = self.payasgoTextfield.text.floatValue;
    amount = amount + payAsYouGo;
    
    NSLog(@"Total amount = %f", amount);
    if (amount > 0) {
        NSString *formatString = [NSString stringWithFormat:@"Continue ($ %.2f)  >", amount];
        [self.continueButton setTitle:formatString forState:UIControlStateNormal];
    }else{
        self.continueButton.enabled = NO;
        self.continueButton.backgroundColor = [UIColor lightGrayColor];
    }
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}




- (IBAction)firstPageContinueClicked:(id)sender {
    
    [self payasyougo];

    [self dictForPayAsYouGo];
    
    TicketDetailsViewController *ticketview = [[TicketDetailsViewController alloc]initWithNibName:@"TicketDetailsViewController" bundle:nil];
    [ticketview setManagedObjectContext:self.managedObjectContext];
    NSMutableArray * seletedArray = [[NSMutableArray alloc]init];
    totalAmount = 0;
    for (int j =0; j< productsListArray.count; j++) {
        if (![[[productsListArray objectAtIndex:j] valueForKey:@"ticket_count"] isEqualToString:@"0"]) {
            [seletedArray addObject:[productsListArray objectAtIndex:j]];
            totalAmount = totalAmount + [[[productsListArray objectAtIndex:j]valueForKey:@"total_ticket_fare"]intValue];
        }
        }
    NSUserDefaults *payAsYouGoAmount = [NSUserDefaults standardUserDefaults];
    float payAsYouGoAmountValue = [payAsYouGoAmount floatForKey:@"payasyougoamount"];
    totalAmount = totalAmount + payAsYouGoAmountValue;
   
    
    NSMutableArray * seletedArraypayasyougo = [[NSMutableArray alloc]init];
    for (int j =0; j< productsListArrayPayasyouGo.count; j++) {
       
            [seletedArraypayasyougo addObject:[productsListArrayPayasyouGo objectAtIndex:j]];
    }
    NSArray *newArray=seletedArray?[seletedArray arrayByAddingObjectsFromArray:seletedArraypayasyougo]:[[NSArray alloc] initWithArray:seletedArraypayasyougo];
    ticketview.seletedProducts = newArray;
    
    if(totalAmount > walletMax){
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"Max_value"]
                                                     message:[NSString stringWithFormat:@"You can't add more than $%d to your cart.",walletMax]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                           otherButtonTitles:nil];
        [singleAlertView show];
        
    }else if (totalAmount < walletMin){
        singleAlertView = [[UIAlertView alloc] initWithTitle:[Utilities stringResourceForId:@"Min_value"]
                                                     message:[NSString stringWithFormat:@"You cannot add less than $%d to your cart.",walletMin]
                                                    delegate:self
                                           cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                           otherButtonTitles:nil];
        [singleAlertView show];
    }else{
        [self.navigationController pushViewController:ticketview animated:YES];
    }
   // ticketview.seletedProductsPayasyougo = seletedArraypayasyougo;
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
//    self.continueButton.enabled = YES;
    [self showTotalAmount];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([string length]==0){
        return YES;
    }
   
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.continueButton.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities continueButtonBgColor]]];
    self.continueButton.enabled = YES;
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self showTotalAmount];
}
 #pragma mark - Navigation
 /*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

