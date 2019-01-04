//
//  ReportExceptionsService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "ReportExceptionsService.h"
#import "AFNetworking.h"
#import "AppConstants.h"
#import "AppException.h"
#import "BaseService.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"

NSString *const URI_EXCEPTIONS = @"apperror/addarray/";

@implementation ReportExceptionsService
{
    NSManagedObjectContext *managedObjectContext;
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        managedObjectContext = context;
    }
    
    return self;
}

- (NSArray *)createRequestWithQueue:(NSArray *)appExceptions
{
    NSMutableArray *exceptionsArray = [[NSMutableArray alloc] init];
    
    for (AppException *exception in appExceptions) {
        NSDictionary *exceptionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                             TYPE_APP, @"devicetype",
                                             [Utilities deviceId], @"deviceid",
                                             [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], @"appversion",
                                             [NSString stringWithFormat:@"%d", exception.errorType], @"errortype",
                                             exception.errorDetail, @"errordetail",
                                             [NSString stringWithFormat:@"%.f", exception.errorDateTime], @"errordatetime",
                                             nil];
        
        [exceptionsArray addObject:exceptionDictionary];
    }
    
    return [exceptionsArray copy];
}

- (void)execute
{
    NSArray *appExceptions = [[RuntimeData instance] appExceptions];
    
    if ([appExceptions count] > 0) {
        // Tag the subsequent code as a task that can continue running if app goes into background during execution
        _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self endBackgroundTask];
        }];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [[manager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
                                                                    password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[NSString stringWithFormat:@"%@/%@", [Utilities apiUrl], URI_EXCEPTIONS]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [[manager responseSerializer] setAcceptableContentTypes:
         [NSSet setWithObjects:@"text/html", @"application/json", nil]];
        
        [manager POST:[NSString stringWithFormat:@"%@/%@", [Utilities apiUrl], URI_EXCEPTIONS]
           parameters:[self createRequestWithQueue:appExceptions]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([BaseService isResponseOk:responseObject]) {
                      [[RuntimeData instance] setAppExceptions:[[NSArray alloc] init]];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"ReportExceptionsService Base Error Req: %@, Response: %@", operation.request, operation.responseString);
              }];
        
        // End task if app is still in foreground so resources may be deallocated by the OS
        [self endBackgroundTask];
    }
}

- (void)endBackgroundTask
{
    [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
    _backgroundTask = UIBackgroundTaskInvalid;
}

@end
