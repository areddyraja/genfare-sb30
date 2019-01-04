//
//  RouteDescriptionViewController.h
//  CDTA
//
//  Created by CooCooTech on 12/23/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "Route.h"

@interface RouteDescriptionViewController : CDTABaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil route:(Route *)route;

@property (weak, nonatomic) IBOutlet UITextView *textView;


@end
