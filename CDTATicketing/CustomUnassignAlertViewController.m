//
//  CustomUnassignAlertViewController.m
//  CDTATicketing
//
//  Created by omniwzse on 19/11/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

#import "CustomUnassignAlertViewController.h"

@interface CustomUnassignAlertViewController ()

@end

@implementation CustomUnassignAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)confirmMessage:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
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
