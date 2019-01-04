//
//  DatePicker.m
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "DatePicker.h"

@interface DatePicker()

@property (weak, nonatomic) id todayTarget;
@property (nonatomic) SEL todaySelector;
@property (weak, nonatomic) id doneTarget;
@property (nonatomic) SEL doneSelector;

@end

@implementation DatePicker
{
    CGRect originalFrame;
    float bottomOffset;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (DatePicker *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner
{
    id customView = nil;
    
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[self class]]) {
            customView = nibItem;
            
            break;
        }
    }
    
    return customView;
}

- (void)setupWithBottomOffset:(float)offset
{
    originalFrame = self.frame;
    bottomOffset = offset;
}

- (void)addTargetForTodayButton:(id)target action:(SEL)action
{
    self.todayTarget = target;
    self.todaySelector = action;
}

- (void)addTargetForDoneButton:(id)target action:(SEL)action
{
    self.doneTarget = target;
    self.doneSelector = action;
}

- (void)setHidden:(BOOL)hidden parentFrame:(CGRect)parentFrame animated:(BOOL)animated
{
    CGRect newFrame = parentFrame;
    newFrame.origin.y = hidden ? parentFrame.size.height : parentFrame.size.height - originalFrame.size.height - bottomOffset;
    
    if (animated) {
        [UIView beginAnimations:@"animateDatePicker" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.frame = newFrame;
        
        [UIView commitAnimations];
    } else {
        self.frame = newFrame;
    }
}

- (IBAction)selectToday:(id)sender {
    if (self.todayTarget) {
        [self.todayTarget performSelector:self.todaySelector withObject:nil afterDelay:0];
    }
}

- (IBAction)selectDone:(id)sender {
    if (self.doneTarget) {
        [self.doneTarget performSelector:self.doneSelector withObject:nil afterDelay:0];
    }
}

@end
