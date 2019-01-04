//
//  ForgotLoginViewController.m
//  CooCooBase
//
//  Created by John Scuteri on 5/29/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "Utilities.h"
#import "AppConstants.h"
#import "ForgotLoginViewController.h"
#import "GetOAuthService.h"

@interface ForgotLoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;

@end

@implementation ForgotLoginViewController
{
    NSString *email;
    BOOL doForgotPasswordService;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:[Utilities stringResourceForId:@"forgot_password_title"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    doForgotPasswordService = NO;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    if ([self.defaultEmail length] > 0) {
        [self.fieldEmail setText:self.defaultEmail];
    }
    
    self.imgUser.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@LogoBig",[[Utilities tenantId] lowercaseString]]];
    
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self applyStylesAndColors];
}

-(void)applyStylesAndColors {
    self.navigationController.navigationBarHidden = YES;
    
    if ([self.fieldEmail respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@PlaceHolderTextColor",[[Utilities tenantId] lowercaseString]]]];
        self.fieldEmail.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }

    self.view.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@LoginBGColor",[[Utilities tenantId] lowercaseString]]]];
    self.submitButton.backgroundColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@BigButtonBGColor",[[Utilities tenantId] lowercaseString]]]];
    [self.btnSignIn setTitleColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:[NSString stringWithFormat:@"%@BigButtonBGColor",[[Utilities tenantId] lowercaseString]]]] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonReset:(id)sender
{
    email = [self.fieldEmail text];
    
    if ([email length] > 0) {
        // Close the keyboard
        [self.view endEditing:YES];
        [self showProgressDialog];
        NSString * accessToken = [Utilities commonaccessToken];
        if (accessToken) {
            ForgotPasswordService *passService = [[ForgotPasswordService alloc] initWithListener:self userEmail:email];
            [passService execute];
        }else{
            doForgotPasswordService = YES;
            GetOAuthService * getOAuthService = [[GetOAuthService alloc] initWithListener:self];
            [getOAuthService execute];
        }
    }
}

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[GetOAuthService class]]){
        if (doForgotPasswordService == YES) {
            [self showProgressDialog];
            ForgotPasswordService *passService = [[ForgotPasswordService alloc] initWithListener:self userEmail:email];
            [passService execute];
        }else{
            [self dismissProgressDialog];
        }
    }else if ([service isMemberOfClass:[ForgotPasswordService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:[Utilities stringResourceForId:@"success"]
                                  message:[Utilities stringResourceForId:@"password_reset_success"]
                                  delegate:self
                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];
    
    if ([service isMemberOfClass:[ForgotPasswordService class]]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:[Utilities stringResourceForId:@"error"]
                                  message:[Utilities stringResourceForId:@"password_reset_fail"]
                                  delegate:nil
                                  cancelButtonTitle:[Utilities stringResourceForId:@"close"]
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
