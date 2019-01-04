//
//  ReportExceptionsService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportExceptionsService : NSObject

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

- (void)execute;

@end
