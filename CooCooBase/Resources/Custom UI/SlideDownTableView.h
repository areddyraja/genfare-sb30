//
//  SlideDownTableView.h
//  OCTA
//
//  Created by John Scuteri on 6/5/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideDownTableView : UIView

@property (weak, nonatomic) IBOutlet UITableView *tableView;

+ (SlideDownTableView *)viewWithNibName:(NSString *)nibName owner:(NSObject *)owner;
- (void)initialize;
- (void)addTargetForCloseButton:(id)target action:(SEL)action;
- (void)setHidden:(BOOL)hidden parentFrame:(CGRect)parentFrame animated:(BOOL)animated;
- (IBAction)close:(id)sender;

@end
