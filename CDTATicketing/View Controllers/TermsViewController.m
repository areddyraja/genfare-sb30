//
//  TermsViewController.m
//  CDTA
//
//  Created by CooCooTech on 1/13/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "TermsViewController.h"
//#import "LogoBarButtonItem.h"

@interface TermsViewController ()

@end

NSString *const TERMS_DESCRIPTION_TITLE = @"Terms of Use";

@implementation TermsViewController
{
    //LogoBarButtonItem *logoBarButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:TERMS_DESCRIPTION_TITLE];
        [self setTitle:TERMS_DESCRIPTION_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
    
    NSString *cotaTerms = @"Central Ohio Transit Authority Terms of Use for COTA.com and COTA Passenger Wi-Fi\n\nAccess to the Central Ohio Transit Authority (COTA) website and use of COTA Passenger Wi-Fi is subject to the following terms and conditions. Your use of this site or accessing the Wi-Fi indicates your acceptance of these terms. We may periodically change the terms without notice, so please check from time to time as your continued use of the site or passenger Wi-Fi signifies your acceptance of the terms and conditions, including changed items.\n\nAcceptable Use\n\nThis service is provided for lawful, personal use only. You may not use it for any other reason or resell any aspect of this service. You must not use this service to transmit any material or perform any other action, which would be in violation of any applicable law or regulation or the rights of any third party. Any use not authorized above is strictly prohibited.\n\nCOTA shall have the right, but not the duty, to monitor, intercept, and disclose any transmissions over or using this service, and to provide user information, use records, and other related information to appropriate authorities under certain circumstances (for example, in response to lawful process, orders, subpoenas, or warrants, or to protect the interests of COTA).\n\nPer COTA policy, passengers utilizing this service must use personal headphones while using sound-producing devices.\n\nCaution\n\nThere are certain privacy and security risks inherent in the use of an open wireless network. You acknowledge that, by use of this service, your device could be exposed to viruses or other harmful applications and that your device or files could be accessed or monitored by third parties. You acknowledge that you are solely responsible for providing security measures that are suited to your intended use of the service. COTA does not guarantee the security of this service or the privacy of any data.\n\nContent\n\nCOTA is not responsible for any content, data, services, products, or other information accessed or downloaded through this service. You acknowledge that there is content available through the Internet, which may be offensive, inaccurate, or otherwise harmful. You also acknowledge that COTA does not monitor or regulate this content, and that access of content available through this service is solely at your own risk.\n\nDisclaimer\n\nCOTA does not warrant the accuracy or completeness of any Material displayed on its website. COTA may change any of the Material at any time without notice. The Materials may be out of date, and COTA makes no commitment to update the Materials. Customers are urged to call COTA customer service at (614) 228-1776 for assistance, if required.\n\nCOTA does not make any warranties or guarantees regarding this service or any content or information accessed by use of this service. THIS SERVICE IS PROVIDED ON AN “AS IS” BASIS, AND YOUR USE OF THE SERVICE IS AT YOUR OWN RISK. COTA HEREBY DISCLAIMS ANY AND ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NONINFRINGEMENT AND TITLE, AND ANY WARRANTIES ARISING FROM A COURSE OF DEALING, USAGE, OR TRADE PRACTICE. COTA DOES NOT WARRANT THAT THE SERVICE WILL PERFORM AT A PARTICULAR SPEED OR THAT IT WILL BE UNINTERRUPTED, ERROR-FREE, OR SECURE.\n\nLimitation of Liability\n\nYou acknowledge and agree that COTA shall not be liable for any claim arising out of, related to, or in any way involving the use of this service.  ANY AND ALL LIABILITY FOR NEGLIGENCE IN PROVIDING OR SECURING THIS SERVICE IS EXPRESSLY PRECLUDED. COTA SHALL NOT BE LIABLE UNDER ANY CIRCUMSTANCES FOR ANY INDIRECT, CONSEQUENTIAL, PUNITIVE, EXEMPLARY, INCIDENTAL, OR SPECIAL DAMAGES, OR LOST PROFITS, WHETHER FORESEEABLE OR UNFORESEEABLE, THAT ARISE OUT OF, RELATE TO, OR IN ANY WAY INVOLVE USE OF THIS SERVICE.\n\nIndemnification\n\nYou agree to hold harmless and indemnify COTA from and against any third party claim arising from, related to, or in any way involving your use of this service, including any liability, losses, damages (actual and consequential), suits, judgments, litigation costs, and attorney fees, of any kind or nature.\n\nCopyright\n\nCOTA retains copyright rights on graphic images and the content of this website. This means that\n\nYou may not:\n\n • distribute the text or graphics to others without the express written permission of COTA;\n\n • “mirror” this information on your website without permission;or\n\n • modify or re-use the text or graphics on this website\n\nYou may:\n\n • print copies of the information for your own personal use; and\n\n • reference this website from your own documents. Commercial use of this information is prohibited without COTA’s explicit written permission. In all copies of this information, you must include this notice and any other copyright notices originally included with such information.\n\nTrademarks\n\nThe trademarks, service marks, and logos (the “Trademarks”) used and displayed herein are registered and unregistered Trademarks of the Central Ohio Transit Authority. Nothing herein should be construed as granting, by implication, estoppel, or otherwise, any license or right to use any Trademark displayed herein, without the written permission of the Trademark owner.\n\nChildren\n\nCOTA requests that parents supervise their children while online. No personal information should be provided by minor children without parental consent.\n\nJurisdiction\n\nAny dispute arising from these terms shall be resolved exclusively in the state and federal courts located in the City of Columbus in the state of Ohio.\n\n";
    
       NSString *cdtaTerms = @"DISCLAIMER\n\nCopyright\nAll content on the Capital District Transportation Authority (CDTA) iRide Application including the collection, arrangement, assembly and presentation of pages and all logos, maps, text, images, feeds and databases are the property of CDTA or its content suppliers and are protected by copyright laws.\n\nYou may not user the CDTA logo, the CDTA map or any other copyrighted material from the CDTA website without express written permission in advance from CDTA.\n\nTrademarks\nThe CDTA logo and the iRide logo and slogan are registered trademarks of the Capital District Transportation Authority. CDTA trademarks may not be used in connection with any product or service that is not CDTA's, in any manner that is likely to cause confusion among customers or in any manner that disparages or discredits CDTA. Other products or company names used on this website may be trademarks of their respective owners.\n\nWarranty and disclaimer\nWhile CDTA makes every effort to ensure the accuracy of the information presented here, the CDTA iRide Application is provided on an \"as is\" basis. CDTA makes no representations or warranties of any kind, express or implied, as to the operation or content of this site or any other website to which it is linked. To the extent permitted by law, CDTA disclaims all warranties, express or implied, including but not limited to implied warranties of merchantability and fitness for a particular purpose. CDTA, its Directors or employees will not be liable for any damages of any kind arising from the use of this site or any site to which it is linked, including but not limited to direct, indirect, punitive and consequential damages.\n\nUse restrictions\nThe CDTA application is available as a resource for your personal, non-commercial use. With the exception of RSS Feeds, Data Feeds and public Application Programming Interfaces (API), you may not reproduce, redistribute, or frame CDTA applications content without express written permission in advance from CDTA.\n\nRSS, Data Feeds and Application Programming Interfaces (API)\nCDTA makes certain information available in Really Simple Syndication feeds (\"RSS Feeds\"). You may reproduce and redistribute content in CDTA RSS Feeds provided that you, (a) do not modify or delete any content from the feed, and (b) include the feed's link or a clear attribution to http://www.cdta.org . CDTA reserves the right to alter and/or no longer provide RSS Feeds at any time without prior notice.\n\nCDTA also makes certain data available in other data feed formats (\"Data Feeds\") or via Application Programming Interfaces (API). These Data Feeds and APIs are subject to the Developer License Agreements (\"DLA\") that accompany their distribution. You should read and understand the DLA before using CDTA Data Feeds and APIs.\n\nNo automated queries\nWith the exception of queries to RSS Feeds and Data Feeds, you may not send scripted, automated or otherwise programmed queries of any sort to the CDTA website without express written permission in advance from CDTA.\n\nContact information\nAddress your correspondence about these policies to:\n\nEmail: http://www.cdta.org/contact_form.php\n\nPhone: 518-482-8822\n\nMail:\n\nCDTA\n110 Watervliet Avenue\nAlbany, New York 12206\n\nInformation Reviewed: January 9, 2014.";
    
    
    NSString *tenantId = [Utilities tenantId];
    if ([tenantId isEqualToString:@"COTA"]) {
//            [self.textView setText:cotaTerms];
    }else if ([tenantId isEqualToString:@"CDTA"]){
           // [self.textView setText:cdtaTerms];
    }else{}

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
