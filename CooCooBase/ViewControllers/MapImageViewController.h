//
//  MapImageViewController.h
//  CooCooBase
//
//  Created by CooCooTech on 8/26/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseViewController.h"

@interface MapImageViewController : BaseViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSString *mapFile;
@property (nonatomic) BOOL isLocal;

@end
