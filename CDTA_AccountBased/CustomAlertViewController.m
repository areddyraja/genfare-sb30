//
//  CustomAlertViewController.m
//  CustomIOSAlertView
//
//  Created by omniwyse on 06/03/18.
//  Copyright © 2018 Wimagguc. All rights reserved.
//

#import "CustomAlertViewController.h"
#import "UIImage+LoadOverride.h"
#import "UIColor+hexString.h"
#import "UIImage+extensions.h"

@interface CustomAlertViewController (){
    int selectedIndex;
    IBOutlet UITableView *popuptableview;
}
@end
@implementation CustomAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     selectedIndex = -1;
    self.view.opaque=YES;
    self.view.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.7];
    
    self.optionsArray=[[NSMutableArray alloc] initWithArray:@[@"Credit Card",@"Farebox,TVM,POS etc..."]];
    // Do any additional setup after loading the view.

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(IBAction)Cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)Continue:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
    if (selectedIndex >= 0) {
        NSString * selectedType = [self.optionsArray objectAtIndex:selectedIndex];
        [self.delegate selectedOption:selectedIndex];
    }
}

-(IBAction)selectOption:(UIButton *)sender{
    if (sender == self.optionButton1) {
        selectedIndex = 0;
    }else{
        selectedIndex = 1;
    }
    
    [self selectOptionAtIndex:selectedIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectOptionAtIndex:(int)option {
    switch (option) {
        case 0:
            //
            self.optionIcon1.image = [UIImage imageNamed:@"credit-card-front-solid-s"];
            self.optionLabel1.textColor = UIColor.whiteColor;
            self.optionView1.backgroundColor = [UIColor colorWithHexString:@"#223668"];
            
            self.optionIcon2.image = [UIImage imageNamed:@"money-check-alt-solid"];
            self.optionLabel2.textColor = UIColor.blackColor;
            self.optionView2.backgroundColor = UIColor.whiteColor;

            break;
            
        case 1:
            //
            self.optionIcon2.image = [UIImage imageNamed:@"money-check-alt-solid-s"];
            self.optionLabel2.textColor = UIColor.whiteColor;
            self.optionView2.backgroundColor = [UIColor colorWithHexString:@"#223668"];
            
            self.optionIcon1.image = [UIImage imageNamed:@"credit-card-front-solid"];
            self.optionLabel1.textColor = UIColor.blackColor;
            self.optionView1.backgroundColor = UIColor.whiteColor;

            break;
            
        default:
            break;
    }
    selectedIndex = option;
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
