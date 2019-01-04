//
//  SMSVerficationViewController.m
//  CDTATicketing
//
//  Created by Gaian Solutions on 5/8/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "SMSVerficationViewController.h"
#import "GetConfigApi.h"
#import "Account.h"
#import "CooCooAccountUtilities1.h"
#import "SMSStatusVerificationViewController.h"
#import <MessageUI/MessageUI.h>
#import "Utilities.h"

@interface SMSVerficationViewController ()<MFMessageComposeViewControllerDelegate>

@end

@implementation SMSVerficationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sendSMSBtn.enabled=false;
    [accountStatusLbl setHidden:YES];
    
   UIBarButtonItem *btnHome = [[UIBarButtonItem alloc] initWithTitle:@"Home"
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                                                       target:self
                                         action:@selector(homeBtnHandler)];
    self.navigationItem.leftBarButtonItem = btnHome;

    
    
    smsVerificationLbl.text=[@"Need to Send an SMS for Verification" stringByAppendingFormat:@"\n%@",@"Don't edit message body while sending message"];
    GetConfigApi *configapi=[[GetConfigApi alloc] initWithListener:self];
    [configapi execute];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)homeBtnHandler{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)threadSuccessWithClass:(id)service response:(id)response{
    [super threadSuccessWithClass:service response:response];
    [self dismissProgressDialog];

    if([service isMemberOfClass:[GetConfigApi class]]){
        sendSMSBtn.enabled=true;
    }
}

- (void)threadErrorWithClass:(id)service response:(id)response
{
    [self dismissProgressDialog];

}

-(IBAction)sendSMS:(id)sender{
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageComposer =
        [[MFMessageComposeViewController alloc] init];
         [messageComposer setBody:[self getMessageString]];
        
        NSArray *receipantsArray=[NSArray  arrayWithObjects:[[NSUserDefaults standardUserDefaults]objectForKey:@"AGENCY_CONTACT_NUMBER"] ,nil];
        [messageComposer setRecipients:receipantsArray];
        messageComposer.messageComposeDelegate = self;
        [self presentViewController:messageComposer animated:YES completion:^{
            
           
        }];
    }
   
    
}

-(NSString*)getMessageString
{
    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    NSString *encodedStr = [Utilities stringToBase64:[NSString stringWithFormat:@"%@|%@",account.emailaddress,[Utilities deviceId]]];
    return [@"AUTH " stringByAppendingString:encodedStr];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];

    if(result==MessageComposeResultSent){
    SMSStatusVerificationViewController *smcVerficationVC=[[SMSStatusVerificationViewController alloc] initWithNibName:@"SMSStatusVerificationViewController" bundle:[NSBundle mainBundle]];
    smcVerficationVC.managedObjectContext=self.managedObjectContext;
    [self.navigationController pushViewController:smcVerficationVC animated:true];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
