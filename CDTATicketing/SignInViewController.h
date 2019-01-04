//
//  SignInViewController.h
//  Pods
//
//  Created by ibasemac3 on 3/17/17.
//
//
#import "BaseViewController.h"

#import <UIKit/UIKit.h>

@interface SignInViewController : BaseViewController<UIAlertViewDelegate>{
    BOOL doLogin;
}

@property(nonatomic,strong) UIViewController *cdtaController;

- (IBAction)SignInHandler:(id)sender ;
@end
