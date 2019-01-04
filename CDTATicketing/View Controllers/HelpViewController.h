//
//  HelpViewController.h
//  CDTA
//
//  Created by CooCooTech on 9/24/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"

@interface HelpViewController : CDTABaseViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *twitterImage;
@property (weak, nonatomic) IBOutlet UIImageView *facebookImage;
@property (weak, nonatomic) IBOutlet BorderedButton *visitTheWebsiteProperty;
@property (weak, nonatomic) IBOutlet BorderedButton *callNumberProperty;
@property (weak, nonatomic) IBOutlet BorderedButton *commentsProperty;

- (IBAction)visitWebsite:(id)sender;
- (IBAction)callNumber:(id)sender;
- (IBAction)sendEmail:(id)sender;
- (IBAction)goTos:(id)sender;
- (IBAction)goPrivacy:(id)sender;

@end
