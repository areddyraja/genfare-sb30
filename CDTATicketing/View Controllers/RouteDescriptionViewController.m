//
//  RouteDescriptionViewController.m
//  CDTA
//
//  Created by CooCooTech on 12/23/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "RouteDescriptionViewController.h"
#import "CDTAAppConstants.h"
//#import "LogoBarButtonItem.h"

@interface RouteDescriptionViewController ()

@end

NSString *const ROUTE_DESCRIPTION_TITLE = @"About";

@implementation RouteDescriptionViewController
{
    //LogoBarButtonItem *logoBarButton;
    Route *route;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil route:(Route *)rte
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        route = rte;
        
        [self setViewName:ROUTE_DESCRIPTION_TITLE];
        [self setViewDetails:[NSString stringWithFormat:@"id: %d", [route.routeId intValue]]];
        
        [self setTitle:ROUTE_DESCRIPTION_TITLE];
        
        //logoBarButton = [[LogoBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationItem setRightBarButtonItem:logoBarButton];
    
    NSString *description = [route.routeDescription stringByReplacingOccurrencesOfString:@"&lt;br /&gt;" withString:@"\n"];
    description = [description stringByReplacingOccurrencesOfString:@"&amp;amp;" withString:@"&"];
    description = [description stringByReplacingOccurrencesOfString:@"&amp;lsquo;" withString:@"'"];
    description = [description stringByReplacingOccurrencesOfString:@"&amp;rsquo;" withString:@"'"];
    description = [description stringByReplacingOccurrencesOfString:@"&amp;ldquo;" withString:@"\""];
    description = [description stringByReplacingOccurrencesOfString:@"&amp;rdquo;" withString:@"\""];
    description = [description stringByReplacingOccurrencesOfString:@"&amp;nbsp;" withString:@""];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&lt;.*?&gt;"
                                                                           options:0
                                                                             error:nil];
    description = [regex stringByReplacingMatchesInString:description
                                                  options:0
                                                    range:NSMakeRange(0, [description length])
                                             withTemplate:@""];
    
    [self.textView setText:description];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
