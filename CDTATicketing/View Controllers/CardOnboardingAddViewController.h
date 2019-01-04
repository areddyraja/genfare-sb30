//
//  CardOnboardingAddViewController.h
//  CDTATicketing
//
//  Created by CooCooTech on 3/31/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "BaseCardOnboardingViewController.h"

@interface CardOnboardingAddViewController : BaseCardOnboardingViewController

@property (weak, nonatomic) IBOutlet UIImageView *cardImage;
@property (weak, nonatomic) IBOutlet UITextField *nicknameText;
@property (weak, nonatomic) IBOutlet UITextField *descriptionText;

@end
