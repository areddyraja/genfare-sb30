//
//  CustomPicker.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPicker : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) NSMutableArray *dates;

+ (CustomPicker *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner;
- (void)initialize;
- (void)addTargetForDoneButton:(id)target action:(SEL)action;
- (void)setHidden:(BOOL)hidden parentFrame:(CGRect)parentFrame animated:(BOOL)animated;
- (IBAction)done:(id)sender;

@end
