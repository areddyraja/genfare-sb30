//
//  DatePicker.h
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePicker : UIView

@property (weak, nonatomic) IBOutlet UIDatePicker *picker;

+ (DatePicker *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner;
- (void)setupWithBottomOffset:(float)offset;
- (void)addTargetForTodayButton:(id)target action:(SEL)action;
- (void)addTargetForDoneButton:(id)target action:(SEL)action;
- (void)setHidden:(BOOL)hidden parentFrame:(CGRect)parentFrame animated:(BOOL)animated;

- (IBAction)selectToday:(id)sender;
- (IBAction)selectDone:(id)sender;

@end
