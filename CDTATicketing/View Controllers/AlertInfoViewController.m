//
//  AlertInfoViewController.m
//  CDTA
//
//  Created by CooCooTech on 10/29/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "AlertInfoViewController.h"
#import "CDTAAppConstants.h"
//#import "LogoBarButtonItem.h"

@interface AlertInfoViewController ()

@end

NSString *const ALERT_INFO_TITLE = @"Alert Info";
float const MESSAGE_PADDING = 10.0f;
float const MESSAGE_SPACING = 20.0f;

@implementation AlertInfoViewController
{
    //LogoBarButtonItem *logoBarButton;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setViewName:ALERT_INFO_TITLE];
        [self setTitle:ALERT_INFO_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *helpText = [[NSBundle loadOverrideNibNamed:@"Help Alerts" owner:self options:nil] objectAtIndex:0];
    [self.helpSlider insertHelpView:helpText title:[Utilities stringResourceForId:@"instructions"]];
    
    UILabel *headerLabel = [[UILabel alloc]init];
    UILabel *messageLabel = [[UILabel alloc]init];
    UIFont *headerFont = [UIFont boldSystemFontOfSize:17.0f];
    UIFont *messageFont = [UIFont systemFontOfSize:17.0f];
    [self setViewDetails:self.alert.header];
    [headerLabel setText:self.alert.header];
    //[headerLabel setText:HEADER];
    [headerLabel setFont:headerFont];
    [headerLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [headerLabel setNumberOfLines:0];
    [messageLabel setText:self.alert.message];
    //[messageLabel setText:LIPSUM];
    [messageLabel setFont:messageFont];
    [messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [messageLabel setNumberOfLines:0];
    
    
    CGRect hRect, mRect;
    CGSize max = CGSizeMake([UIScreen mainScreen].bounds.size.width - (2 * MESSAGE_SPACING),FLT_MAX);
    
    hRect = [self.alert.header boundingRectWithSize:max options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: headerFont} context:nil];
    hRect.origin = CGPointMake(MESSAGE_SPACING, MESSAGE_SPACING);
    
    mRect = [self.alert.message boundingRectWithSize:max options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: messageFont} context:nil];
    mRect.origin = CGPointMake(MESSAGE_SPACING, hRect.origin.y + hRect.size.height + MESSAGE_PADDING);
    
    [headerLabel setFrame:hRect];
    [messageLabel setFrame:mRect];
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width,
                                               messageLabel.frame.origin.y + messageLabel.frame.size.height)];
    [self.scrollView addSubview:headerLabel];
    [self.scrollView addSubview:messageLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
