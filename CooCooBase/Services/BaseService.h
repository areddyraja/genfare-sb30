//
//  BaseService.h
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

/*
 * Must be implemented by the ViewController making the service call
 */
#import <Foundation/Foundation.h>
#import "AppConstants.h"
#import <CoreData/CoreData.h>
#import "CustomAlertAppUpdateController.h"
#import "Account.h"

@protocol ServiceListener <NSObject>

- (void)threadSuccessWithClass:(id)service response:(id)response;
- (void)threadErrorWithClass:(id)service response:(id)response;

@end

@interface BaseService : NSObject<CustomAlertAppUpdateControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

FOUNDATION_EXPORT int const METHOD_GET;
FOUNDATION_EXPORT int const METHOD_GET_JSON;
FOUNDATION_EXPORT int const METHOD_POST;
FOUNDATION_EXPORT int const METHOD_PUT;
FOUNDATION_EXPORT int const METHOD_PATCH;
FOUNDATION_EXPORT int const METHOD_DELETE;
FOUNDATION_EXPORT int const METHOD_SIMPLE_POST_SECURE;
FOUNDATION_EXPORT int const METHOD_SIMPLE;
FOUNDATION_EXPORT int const METHOD_SIMPLE_JSON;
FOUNDATION_EXPORT int const METHOD_SIMPLE_POST;
FOUNDATION_EXPORT NSString *const SERVICE_DATE_FORMAT;
FOUNDATION_EXPORT NSString *const SERVICE_TIME_FORMAT;

@property (strong, nonatomic) id <ServiceListener> listener;
@property (nonatomic) int method;

- (void)execute;

+ (BOOL)isResponseOk:(NSDictionary *)jsonResponse;
typedef void(^myCompletion)(NSDictionary *);
@property (nonatomic, copy) myCompletion handler;
-(NSDictionary *)executeWithHandler:(myCompletion)completionBlock;

-(Account *)currentUserAccount;

@end

