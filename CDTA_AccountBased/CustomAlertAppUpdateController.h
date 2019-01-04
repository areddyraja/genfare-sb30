//
//  CustomAlertAppUpdateController.h
//  CDTATicketing
//
//  Created by omniwyse on 12/07/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomAlertAppUpdateController;             //define class, so protocol can see MyClass
@protocol CustomAlertAppUpdateControllerDelegate <NSObject>   //define delegate protocol
- (void) OkAction;  //define delegate method to be implemented within another class
@end //end protocol

@interface CustomAlertAppUpdateController : UIViewController{
        IBOutlet UILabel *infoLabel;
        IBOutlet UIView *alertView;
}
@property (strong, nonatomic) NSDictionary * response;
@property (nonatomic, strong) id <CustomAlertAppUpdateControllerDelegate> delegate;

@end

