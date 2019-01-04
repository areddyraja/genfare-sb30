//
//  CustomPicker.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CustomPicker.h"
#import "AppConstants.h"
#import "NSBundle+BaseResourcesBundle.h"

NSString *const DATE_PICKER_REVERSE = @"LLL d, YY";
NSString *const DATE_PICKER_FORMAT = @"LLL d, YYYY (ccc)";
NSString *const DATE_PICKER_FORMAT_NEXT = @"LLL d, YYYY ('Next' ccc)";
NSString *const DATE_PICKER_FORMAT_AFTER = @"LLL d, YYYY";

@interface CustomPicker()

@property (weak, nonatomic) id doneTarget;
@property (nonatomic) SEL doneSelector;

@end

@implementation CustomPicker
{
    CGRect originalFrame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

+ (CustomPicker *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner
{
    id customView = nil;
    
    NSArray *nibContents = [[NSBundle baseResourcesBundle] loadNibNamed:nibName owner:owner options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    
    NSObject *nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[self class]]) {
            customView = nibItem;
            
            break;
        }
    }
    
    return customView;
}

- (void)initialize
{
    originalFrame = self.frame;
    
    [self.picker setDelegate:self];
    [self.picker setDataSource:self];
}

- (void)addTargetForDoneButton:(id)target action:(SEL)action
{
    self.doneTarget = target;
    self.doneSelector = action;
}

- (void)setHidden:(BOOL)hidden parentFrame:(CGRect)parentFrame animated:(BOOL)animated
{
    CGRect newFrame = parentFrame;
    newFrame.origin.y = hidden ? parentFrame.size.height : parentFrame.size.height - originalFrame.size.height;
    
    if (animated) {
        [UIView beginAnimations:@"animateCustomPicker" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.frame = newFrame;
        
        [UIView commitAnimations];
    } else {
        self.frame = newFrame;
    }
}

- (IBAction)done:(id)sender
{
    if (self.doneTarget) {
        [self.doneTarget performSelector:self.doneSelector withObject:nil afterDelay:0];
    }
}

#pragma mark - UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:LOCALE];
    [formatter setDateFormat:DATE_PICKER_FORMAT];
    
    if (row >= 7) {
        [formatter setDateFormat:DATE_PICKER_FORMAT_NEXT];
    } else if (row >= 14) {
        [formatter setDateFormat:DATE_PICKER_FORMAT_AFTER];
    }
    
    NSString *dateString = [formatter stringFromDate:[self.dates objectAtIndex:row]];
    
    return dateString;
}

#pragma mark - UIPickerViewDataSource methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.dates count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

@end
