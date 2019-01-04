//
//  SignUpViewController.h
//  Pods
//
//  Created by ibasemac3 on 3/17/17.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SignUpViewController : BaseViewController<UITextFieldDelegate>{
    BOOL doSignUp;
    NSString *email;
    NSString *password;
}

@property(nonatomic,strong) UIViewController *cdtaController;


-(IBAction)signUpHandler:(id)sender;
@end
