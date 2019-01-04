//
//  SlideUpTableView.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "SlideUpTableView.h"
#import "NSBundle+BaseResourcesBundle.h"

@interface SlideUpTableView()

@property (weak, nonatomic) id closeTarget;
@property (nonatomic) SEL closeSelector;

@end

@implementation SlideUpTableView
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

+ (SlideUpTableView *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner
{
    id tableView = nil;
    
    NSArray *nibContents = [[NSBundle baseResourcesBundle] loadNibNamed:nibName owner:owner options:NULL];
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    
    NSObject *nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[self class]]) {
            tableView = nibItem;
            
            break;
        }
    }
    
    return tableView;
}

- (void)initialize
{
    originalFrame = self.frame;
}

#pragma mark - View controls

- (void)addTargetForCloseButton:(id)target action:(SEL)action
{
    self.closeTarget = target;
    self.closeSelector = action;
}

- (void)setHidden:(BOOL)hidden parentFrame:(CGRect)parentFrame animated:(BOOL)animated
{
    CGRect newFrame = parentFrame;
    newFrame.origin.y = hidden ? parentFrame.size.height : originalFrame.origin.y;
    
    if (animated) {
        [UIView beginAnimations:@"animateSlideUpTableView" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.frame = newFrame;
        
        [UIView commitAnimations];
    } else {
        self.frame = newFrame;
    }
}

- (IBAction)close:(id)sender
{
    if (self.closeTarget) {
        [self.closeTarget performSelector:self.closeSelector withObject:nil afterDelay:0];
    }
}

@end
