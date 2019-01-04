//
//  TicketCardSeletionViewController.m
//  CooCooBase
//
//  Created by ibasemac3 on 12/15/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "TicketCardSeletionViewController.h"
#import "CreateOrderService.h"
#import "PurchaseWebViewController.h"
#import "CooCooAccountUtilities1.h"
#import "Utilities.h"
#import "TicketDetailsViewController.h"
#import "NewTicketPurchaseViewController.h"
#import "GetSavedCard.h"
#import "SavedCards.h"
#import "SavedCardsTableViewCell.h"
#import "CardSaveforFuture.h"
#import "DeleteCardApi.h"
#import "CustomTableview.h"
#import "CooCooBase.h"
@interface TicketCardSeletionViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UIImageView *imgCard;
    __weak IBOutlet UILabel *emailLabel;
    __weak IBOutlet UIButton *saveCardButton;
    __weak IBOutlet UILabel *saveCardLabel;
    NSMutableArray *savedCardsArray;
    IBOutlet NSLayoutConstraint *savedcardsViewHeight;
    IBOutlet CustomTableview *savedCardsTableview;
    IBOutlet UIView *savedCardsview;
    SavedCards *selCard;
    BOOL isSelectedBtnImageCard;
}

@end


@implementation TicketCardSeletionViewController

static NSString *cellIdentifier = @"SavedCardsTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Ticket Purchase" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    NSLog(@"%@",_ticketsArray);
    selectedIndexPath=nil;
    [imgCard setImage:[UIImage imageNamed:@"img_card"]];
    
    [saveCardButton setImage:[UIImage imageNamed:@"ic_uncheckedbox"] forState:UIControlStateNormal];
    [saveCardButton addTarget:self action:@selector(onSaveCardButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"IS_CHECKED"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    GetSavedCard *getSavedCard = [[GetSavedCard alloc]  initWithListener:self];
    [getSavedCard execute];
    
    savedCardsArray=[[NSMutableArray alloc]init];
    
    savedCardsTableview.backgroundColor=[UIColor whiteColor];
    //  savedCardsTableview.tableHeaderView=savedCardsview;
    
    [savedCardsTableview registerClass:[SavedCardsTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    [emailLabel setText:account.emailaddress];
    
    
    if (savedCardsArray.count == 0) {
        isSelectedBtnImageCard = YES;
        [self updateBtnImageBgCardColor];
    }else{
        isSelectedBtnImageCard = NO;
        [self updateBtnImageBgCardColor];
    }
    
    self.title = @"Purchase Passes";
    
    // Do any additional setup after loading the view.
}

-(void)updateBtnImageBgCardColor{
    if (isSelectedBtnImageCard == YES) {
        [btnImgCard setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"btnImgSelectedCardColor"]]];
    }else{
        [btnImgCard setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"btnImgUnSelectedCardColor"]]];
    }
}

-(IBAction)btnImgCardTapped:(id)sender
{
    
    selectedIndexPath=nil;
    if(isSelectedBtnImageCard == NO )
    {
        SavedCardsTableViewCell *cell = [savedCardsTableview cellForRowAtIndexPath:selectedIndexPath];
        cell.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:@"btnImgSelectedCardColor"]];
        isSelectedBtnImageCard = YES;
        [self updateBtnImageBgCardColor];

    }
    else
    {
        isSelectedBtnImageCard = NO;
        [self updateBtnImageBgCardColor];
        
    }
    selCard=nil;
    [savedCardsTableview reloadData];
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return savedCardsview.frame.size.height;
//}
//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *header = [[UIView alloc] init];
//    UIView *subheader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, savedCardsview.frame.size.height)];
//    [savedCardsview removeFromSuperview];
//    savedCardsview.frame=CGRectMake(0, 0, tableView.frame.size.width, savedCardsview.frame.size.height);
//    [subheader addSubview:savedCardsview];
//    [header addSubview:subheader];
//    savedCardsview.center=subheader.center;
//    return header;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 55.0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    savedcardsViewHeight.constant=55.0*savedCardsArray.count;
    return savedCardsArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SavedCardsTableViewCell *cell = (SavedCardsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    SavedCards *savedcard = [savedCardsArray objectAtIndex:indexPath.row];
    cell.deleteButton.tag=indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deletecard:) forControlEvents:UIControlEventTouchUpInside];
    cell.card=savedcard;
    cell.CardBgview.layer.cornerRadius=5.0;
    cell.CardBgview.layer.borderWidth=2.0;
    cell.CardBgview.clipsToBounds=YES;
    cell.CardBgview.layer.borderColor=[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"btnImgUnSelectedCardColor"]].CGColor;
    cell.canrdNumberLabel.text=savedcard.lastFour;
    
    
    if(selectedIndexPath.row==indexPath.row&&selectedIndexPath!=nil){
        cell.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:@"btnImgSelectedCardColor"]];
    }
    else{
        cell.backgroundColor = [UIColor clearColor];
    }
    NSBundle *resbundle =  [NSBundle baseResourcesBundle];
    NSURL *cardimage = [resbundle URLForResource:savedcard.paymentTypeId.stringValue withExtension:@"png"];
    
    if(cardimage==nil){
        cardimage = [resbundle URLForResource:@"creditcard" withExtension:@"png"];
    }
    
    cell.Cardimage.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:cardimage]];
    
    return cell;
    
}

-(void)deletecard:(UIButton*)sender{
    
//    NSString *message = [NSString stringWithFormat:[Utilities deleteCreditCardMessage]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:[Utilities deleteCreditCardTitle]]
                                                                             message:[Utilities stringResourceForId:[Utilities deleteCreditCardMessage]]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: [Utilities stringResourceForId:@"no"]
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action) {
                                                         }];
    [alertController addAction:cancelAction];
    UIAlertAction *deletecard = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"yes"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self showProgressDialog];
                                                           
                                                           SavedCards *savedcard = [savedCardsArray objectAtIndex:sender.tag];
                                                           
                                                           DeleteCardApi *deletecard = [[DeleteCardApi alloc] initWithListener:self savedCard:savedcard.cardNumber.stringValue];
                                                           [deletecard execute];
                                                           
                                                           [savedCardsTableview reloadData];
                                                       }];
    
    [alertController addAction:deletecard];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(selectedIndexPath){    SavedCardsTableViewCell *cellSelected = [tableView cellForRowAtIndexPath:indexPath];
        [cellSelected setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"btnImgUnSelectedCardColor"]]];
    }
    SavedCardsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    selectedIndexPath = indexPath;
    [cell setBackgroundColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"btnImgSelectedCardColor"]]];
    selCard=[savedCardsArray objectAtIndex:selectedIndexPath.row];
    [savedCardsTableview reloadData];
    isSelectedBtnImageCard = NO;
    [self updateBtnImageBgCardColor];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickOfContinue:(id)sender {
    
    
    if(selCard){
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        
        NSString *message = [NSString stringWithFormat:@"Enter the password for %@ to use saved cards.\n\nOnce the password is verified, this card will be used for further Payment", account.emailaddress];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[Utilities stringResourceForId:[Utilities retriveCreditCardAlertTitle]]
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            [textField setPlaceholder:[Utilities stringResourceForId:@"password"]];
            [textField setSecureTextEntry:YES];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"cancel"]
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction *action) {
                                                             }];
        [alertController addAction:cancelAction];
        UIAlertAction *verify = [UIAlertAction actionWithTitle:[Utilities stringResourceForId:@"verify"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           // [self showProgressDialog];
                                                           
                                                           NSString *password = ((UITextField *)[alertController.textFields objectAtIndex:0]).text;
                                                               if([password isEqualToString:account.password] ){
                                                               CreateOrderService *productsService = [[CreateOrderService alloc] initWithListener:self managedObjectContext:self.managedObjectContext withArray:_ticketsArray];
                                                               [productsService execute];
                                                           }
                                                           else{
                                                               UIAlertController *alertController1 = [UIAlertController alertControllerWithTitle:@"Password" message:@"Please provide correct password" preferredStyle:UIAlertControllerStyleAlert];
                                                               UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive
                                                                                                                    handler:^(UIAlertAction *action) {}];
                                                               [alertController1 addAction:cancelAction];
                                                               [self presentViewController:alertController1 animated:YES completion:nil];
                                                           }
                                                       }];
        
        [alertController addAction:verify];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    else{
        CreateOrderService *productsService = [[CreateOrderService alloc] initWithListener:self managedObjectContext:self.managedObjectContext withArray:_ticketsArray];
        [productsService execute];
    }
    
    
    
    
}

//-(void)callsaveforFuture
//{
//    CardSaveforFuture *cardService = [[CardSaveforFuture alloc] initWithListener:self];
//    [cardService execute];
//}
- (IBAction)onClickofBacktoCart:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    
    [self dismissProgressDialog];
    if ([service isMemberOfClass:[CreateOrderService class]]){
        NewTicketPurchaseViewController *ticketview = [[NewTicketPurchaseViewController alloc]initWithNibName:@"NewTicketPurchaseViewController" bundle:nil];
        if(selCard){
            ticketview.card=selCard;
        }
        [ticketview setManagedObjectContext:self.managedObjectContext];
        [self.navigationController pushViewController:ticketview animated:YES];
    }
    else if ([service isMemberOfClass:[GetSavedCard class]]){
        
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
        
        NSArray *SavedCardsArray=json[@"result"];
        [savedCardsArray removeAllObjects];
        for(NSDictionary *Dict in SavedCardsArray){
            [savedCardsArray addObject:[[SavedCards alloc]initWithDictionary:Dict]];
        }
        [savedCardsTableview reloadData];
    }
    else if ([service isMemberOfClass:[DeleteCardApi class]]){
        GetSavedCard *getSavedCard = [[GetSavedCard alloc]  initWithListener:self];
        [getSavedCard execute];
    }
}


-(void)onSaveCardButtonTap:(UIButton *)button{
    button.selected = !button.selected;
    
    if (button.isSelected) {
        // button is checked
        [saveCardButton setImage:[UIImage imageNamed:@"ic_checkedbox"] forState:UIControlStateNormal];
        [[ NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"IS_CHECKED"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else {
        // button is unchecked
        [saveCardButton setImage:[UIImage imageNamed:@"ic_uncheckedbox"] forState:UIControlStateNormal];
        [[ NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"IS_CHECKED"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    [savedCardsTableview reloadData];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
