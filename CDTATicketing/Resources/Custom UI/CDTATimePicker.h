//
//  CDTATimePicker.h
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDTATimePicker : UIView

@property (weak, nonatomic) IBOutlet UIDatePicker *picker;

+ (CDTATimePicker *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner;
- (void)setupWithBottomOffset:(float)offset;
- (void)addTargetForNowButton:(id)target action:(SEL)action;
- (void)addTargetForDoneButton:(id)target action:(SEL)action;
- (void)setHidden:(BOOL)hidden parentFrame:(CGRect)parentFrame animated:(BOOL)animated;

- (IBAction)selectNow:(id)sender;
- (IBAction)selectDone:(id)sender;

@end
