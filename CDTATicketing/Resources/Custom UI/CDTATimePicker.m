//
//  CDTATimePicker.m
//  CDTA
//
//  Created by CooCooTech on 10/17/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTATimePicker.h"

@interface CDTATimePicker()

@property (weak, nonatomic) id nowTarget;
@property (nonatomic) SEL nowSelector;
@property (weak, nonatomic) id doneTarget;
@property (nonatomic) SEL doneSelector;

@end

@implementation CDTATimePicker
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

+ (CDTATimePicker *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner
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

- (void)addTargetForNowButton:(id)target action:(SEL)action
{
    self.nowTarget = target;
    self.nowSelector = action;
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

- (IBAction)selectNow:(id)sender {
    if (self.nowTarget) {
        [self.nowTarget performSelector:self.nowSelector withObject:nil afterDelay:0];
    }
}

- (IBAction)selectDone:(id)sender {
    if (self.doneTarget) {
        [self.doneTarget performSelector:self.doneSelector withObject:nil afterDelay:0];
    }
}

@end
