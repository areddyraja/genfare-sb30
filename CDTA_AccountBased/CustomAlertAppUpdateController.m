//
//  CustomAlertAppUpdateController.m
//  CDTATicketing
//
//  Created by omniwyse on 12/07/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "CustomAlertAppUpdateController.h"
#import "Utilities.h"

@interface CustomAlertAppUpdateController ()

@end

@implementation CustomAlertAppUpdateController
@synthesize response;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.opaque=YES;
    self.view.backgroundColor=[UIColor colorWithWhite:0.0 alpha:0.7];
    [alertView.layer setCornerRadius:8.0f];
    [alertView.layer setMasksToBounds:YES];
    NSDictionary *resultDict = [self.response valueForKey:@"result"];
    BOOL doUpdate = [[resultDict valueForKey:@"update"] boolValue];
    NSString * currentAppVersion = [Utilities appCurrentVersion];
    NSString * minAppVersion = [resultDict valueForKey:@"minAppVersion"];
    NSString *message = [NSString stringWithFormat:@"You are using %@ version \n%@ version is available \nClick OK button to update \nthe app from Appstore",currentAppVersion,minAppVersion];
    [infoLabel setText:message];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)oKButtonAction:(id)sender{
//    [self dismissViewControllerAnimated:YES completion:^{}];
//        NSString * selectedType = [self.optionsArray objectAtIndex:selectedIndex];
//        [self.delegate selectedOption:selectedIndex];
    [self.delegate OkAction];
}

@end
