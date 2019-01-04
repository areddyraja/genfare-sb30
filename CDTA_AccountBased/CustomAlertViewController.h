//
//  CustomAlertViewController.h
//  CustomIOSAlertView
//
//  Created by omniwyse on 06/03/18.
//  Copyright © 2018 Wimagguc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iRide-Swift.h"

@class CustomAlertViewController;             //define class, so protocol can see MyClass
@protocol CustomAlertViewControllerDelegate <NSObject>   //define delegate protocol
- (void) selectedOption: (NSInteger ) selectedIndex;  //define delegate method to be implemented within another class
@end //end protocol

@interface CustomAlertViewController : UIViewController
@property (nonatomic,retain) NSArray * optionsArray;
@property (nonatomic, weak) id <CustomAlertViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *optionButton1;
@property (weak, nonatomic) IBOutlet UIButton *optionButton2;
@property (weak, nonatomic) IBOutlet GFCustomTableViewCellShadowView *optionView1;
@property (weak, nonatomic) IBOutlet GFCustomTableViewCellShadowView *optionView2;
@property (weak, nonatomic) IBOutlet UIImageView *optionIcon1;
@property (weak, nonatomic) IBOutlet UIImageView *optionIcon2;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel2;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel1;


@end




