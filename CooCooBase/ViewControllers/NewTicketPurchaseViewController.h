//
//  NewTicketPurchaseViewController.h
//  Pods
//
//  Created by Andrey Kasatkin on 2/25/16.
//
//

#import "BaseTicketPurchaseController.h"
#import <WebKit/WebKit.h>
#import "SavedCards.h"
@interface NewTicketPurchaseViewController : BaseTicketPurchaseController <UIWebViewDelegate, WKNavigationDelegate, UIAlertViewDelegate>

// TODO: These don't seem to be hooked up to the xib?
@property (nonatomic,retain)SavedCards *card;
@property (weak, nonatomic) IBOutlet UILabel *webMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *webViewPlaceholder;

@end
