//
//  TimePicker.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "TimePicker.h"
#import "NSBundle+BaseResourcesBundle.h"

@interface TimePicker()

@property (weak, nonatomic) id doneTarget;
@property (nonatomic) SEL doneSelector;

@end

@implementation TimePicker
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

+ (TimePicker *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner
{
    id customView = nil;
    
    NSArray *nibContents = [[NSBundle baseResourcesBundle] loadNibNamed:nibName owner:owner options:NULL];
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

- (void)initialize
{
    originalFrame = self.frame;
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
        [UIView beginAnimations:@"animateDatePicker" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.frame = newFrame;
        
        [UIView commitAnimations];
    } else {
        self.frame = newFrame;
    }
}

- (IBAction)done:(id)sender {
    if (self.doneTarget) {
        [self.doneTarget performSelector:self.doneSelector withObject:nil afterDelay:0];
    }
}

@end
