//
//  SlideDownTableView.m
//  OCTA
//
//  Created by John Scuteri on 6/5/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "SlideDownTableView.h"
#import "NSBundle+BaseResourcesBundle.h"

@interface SlideDownTableView()

@property (weak, nonatomic) id closeTarget;
@property (nonatomic) SEL closeSelector;

@end

@implementation SlideDownTableView
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

+ (SlideDownTableView *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner
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
    originalFrame = [[UIScreen mainScreen] bounds];
    originalFrame.origin.y = 0;
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
    
    if (hidden) {
        newFrame.origin.y = originalFrame.origin.y - originalFrame.size.height;
    } else {
        newFrame.origin.y = originalFrame.origin.y;
    }
    
    if (animated) {
        [UIView beginAnimations:@"animateSlideDownTableView" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.frame = newFrame;
        [UIView commitAnimations];
    } else {
        self.frame = newFrame;
    }
}

- (IBAction)close:(id)sender {
    if (self.closeTarget) {
        [self.closeTarget performSelector:self.closeSelector withObject:nil afterDelay:0];
    }
}

@end
