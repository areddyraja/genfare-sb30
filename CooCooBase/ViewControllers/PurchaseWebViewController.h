//
//  PurchaseWebViewController.h
//  CooCooBase
//
//  Created by IBase Software on 27/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import <WebKit/WebKit.h>

@interface PurchaseWebViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIWebView *loadWebView;
@property (weak, nonatomic) IBOutlet UILabel *pageButton1;
@property (weak, nonatomic) IBOutlet UILabel *pageButton2;
@property (weak, nonatomic) IBOutlet UILabel *pageButton3;
@property (weak, nonatomic) IBOutlet UILabel *pageButton4Done;




@end
