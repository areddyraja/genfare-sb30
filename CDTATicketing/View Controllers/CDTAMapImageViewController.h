//
//  CDTAMapImageViewController.h
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CDTABaseViewController.h"
#import "Map.h"

@interface CDTAMapImageViewController : CDTABaseViewController <UIGestureRecognizerDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil map:(Map *)map;

@end
