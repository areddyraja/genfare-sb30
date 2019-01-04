//
//  PurchasePassesViewController.h
//  CDTATicketing
//
//  Created by Reddy Raja on 4/12/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchasePassesViewController : UIViewController
@property(nonatomic,retain) IBOutlet UIImageView *qrImageView;

- (void)generateQRCodeImage:(NSString *)strInput;
@end
