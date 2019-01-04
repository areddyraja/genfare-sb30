//
//  BaseTicketsViewController.m
//  CooCooBase
//
//  Created by CooCooTech on 10/6/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "BaseTicketsViewController.h"

@interface BaseTicketsViewController ()

@end

@implementation BaseTicketsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Card details shown correctly,Text changes done.");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIColor *)colorFromHexString:(NSString *)hexString {
    if(!hexString)
        return nil;
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
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
