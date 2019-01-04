//
//  BaseService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "BaseService.h"
#import "AFNetworking.h"
#import "Utilities.h"
#import "CooCooAccountUtilities1.h"
#import "AuthorizeTokenService.h"
#import "GetOAuthService.h"
#import "GetAppUpdateService.h"
#import "Singleton.h"
#import "LoginService.h"
#import "RegisterAccountService.h"
#import "GetWalletContents.h"

int const METHOD_GET = 0;
int const METHOD_GET_JSON = 1;
int const METHOD_POST = 2;
int const METHOD_PATCH = 3;
int const METHOD_PUT = 4;
int const METHOD_DELETE = 5;
int const METHOD_SIMPLE = 6;
int const METHOD_SIMPLE_JSON = 7;
int const METHOD_SIMPLE_POST = 8;
int const METHOD_SIMPLE_POST_SECURE = 9;

NSString *const SERVICE_DATE_FORMAT = @"yyyy-MM-dd";
NSString *const SERVICE_TIME_FORMAT = @"HH:mm:00";

@implementation BaseService

- (id)init
{
    _method = METHOD_POST;
    
    return self;
}

#pragma mark - Subclass implementations

- (NSString *)host
{
    return nil;
}

- (NSString *)uri
{
    return nil;
}

- (NSDictionary *)headers
{
    return nil;
}

- (NSSet *)acceptableContentTypes
{
    return nil;
}

- (id)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
    
    return YES;
}

#pragma mark - Class implementations
+(NSString *)jsonPrettyString :(NSString *) str{
    NSError * error;
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&error];
    NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString *prettyPrintedJson = [NSString stringWithUTF8String:[prettyJsonData bytes]];
    //        NSLog(@"pretty:%@", prettyPrintedJson);
    return prettyPrintedJson;
}
-(void)printAPIData :(AFHTTPRequestOperation *) operation{
    NSLog(@"\nURL====\n%@",operation.request.URL);
    NSLog(@"\nMethodType====\n%@",operation.request.HTTPMethod);
    NSLog(@"\nHeaders====\n%@",operation.request.allHTTPHeaderFields);
    if (operation.request.HTTPBody > 0) {
        NSData * data = [NSData dataWithData:operation.request.HTTPBody];
        NSString * bodyString = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"\nBody====\n-->%@<--",bodyString);
    }
    NSLog(@"Status Code====%ld", operation.response.statusCode);
    NSLog(@"\nResponse====%@",operation.responseString);
    //      NSLog(@"\nResponse====PRETTY====%@",[BaseService jsonPrettyString:operation.responseString]);
    
}
-(void)printAPIFailureData :(AFHTTPRequestOperation *) operation errorData :(NSError *)error {
    //    NSLog(@"\nAPIFailure with Error====%@",error);
    NSLog(@"\nFailureURL====\n%@",operation.request.URL);
    NSLog(@"\nFailureMethodType====\n%@",operation.request.HTTPMethod);
    NSLog(@"\nFailureHeaders====\n%@",operation.request.allHTTPHeaderFields);
    if (operation.request.HTTPBody > 0) {
        NSData * data = [NSData dataWithData:operation.request.HTTPBody];
        NSString * bodyString = [NSString stringWithUTF8String:[data bytes]];
        NSLog(@"\nFailureBody====\n-->%@<--",bodyString);
    }
    NSLog(@"Status Code====%ld", operation.response.statusCode);
    if (operation.responseString.length > 0) {
        NSLog(@"\nFailureResponse====%@",operation.responseString);
        //        NSLog(@"\nFailureResponse====PRETTY====%@",[BaseService jsonPrettyString:operation.responseString]);
    }
}
//-(NSDictionary *)executeWithHandler:(myCompletion)completionBlock{
//
//    self.handler = completionBlock;
//
//    NSString *urlString = nil;
//
//    if (@available(iOS 8.0, *)) {
//        NSLog(@"base service host %@<--",self.host);
//
//        //        if ([self.host containsString:@"localhost"] || [self.host containsString:@"ngrok.io"] || (_method >= METHOD_SIMPLE) || [self.host containsString:@"api.dev3.gfcp.io"]) {
//        //            urlString = [NSString stringWithFormat:@"http://%@/", self.host];
//        //            // urlString = [NSString stringWithFormat:@"http://@api.dev3.gfcp.io/"];
//        //        } else {
//        //            urlString = [NSString stringWithFormat:@"https://%@/", self.host];
//        //
//        //        }
//        NSString *tenantId = [Utilities tenantId];
//        if ([tenantId isEqualToString:@"COTA"]) {
//            urlString = [NSString stringWithFormat:@"https://%@/", self.host];
//        }else if ([tenantId isEqualToString:@"CDTA"]){
//            if ([self.host containsString:@"api.cota.com"]){
//                urlString = [NSString stringWithFormat:@"https://%@/", self.host];
//            }
//            else if ([self.host containsString:@"localhost"] || [self.host containsString:@"ngrok.io"] || (_method >= METHOD_SIMPLE)) {
//                urlString = [NSString stringWithFormat:@"http://%@/", self.host];
//            } else {
//                urlString = [NSString stringWithFormat:@"https://%@/", self.host];
//            }        }else{}
//
//
//
//
//
//    } else {
//        // Fallback on earlier versions
//    }
//
//    __block BaseService *blockSafeSelf = self;
//    //    NSLog(@"\nurl:%@",[urlString stringByAppendingString:self.uri]);
//
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    if (_method == METHOD_GET_JSON) {
//        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
//                                                                    password:[Utilities authPassword]];
//
//        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
//        NSEnumerator *enumerator = [headers keyEnumerator];
//        id key;
//        while ((key = enumerator.nextObject)) {
//            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
//        }
//
//        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//
//        NSLog(@"%@",[urlString stringByAppendingString:self.uri]);
//        [manager GET:[urlString stringByAppendingString:self.uri]
//          parameters:self.createRequest
//             success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                 if (operation.response.statusCode == 401) {
//                     [[NSNotificationCenter defaultCenter] postNotificationName:@"callAuthorizeTokenService" object:nil];
//                 }
//                 if (responseObject) {
//                     BOOL dataSuccess = [blockSafeSelf processResponse:responseObject];
//
//                     if (dataSuccess) {
//                         [self printAPIData:operation];
//                         [self.listener threadSuccessWithClass:self response:responseObject];
//                         //                         NSDictionary * response = (NSDictionary *)responseObject;
//                         NSMutableDictionary * responseDictonary = [[NSMutableDictionary alloc] init];
//                         [responseDictonary setObject:(NSDictionary *)responseObject forKey:@"response"];
//                         [responseDictonary setObject:self forKey:@"service"];
//                         NSDictionary *anotherDict = [responseDictonary copy];
//                         self.handler(anotherDict);
//                     } else {
//                         [self.listener threadErrorWithClass:self response:responseObject];
//                         self.handler(nil);
//                     }
//                 } else {
//                     [self.listener threadErrorWithClass:self response:nil];
//                     self.handler(nil);
//                 }
//             }
//             failure:^(AFHTTPRequestOperation * operation, NSError * error) {
//                 if (operation.response.statusCode == 401) {
//                     //[[NSNotificationCenter defaultCenter] postNotificationName:@"callAuthorizeTokenService" object:nil];
//                 }
//                 //                 NSLog(@"GET JSON Base Error: %@", error);
//
//                 NSDictionary * json = (NSDictionary *)operation.responseObject;
//                 //                 NSLog(@"GET JSON Base Response: %@", json);
//
//                 [self.listener threadErrorWithClass:self response:operation.responseObject];
//                 [self printAPIFailureData:operation errorData:error];
//                 self.handler(nil);
//             }];
//    }
//    return nil;
//}


- (void)threadErrorWithClass:(id)service response:(id)response{
    if([service isMemberOfClass:[GetAppUpdateService class]]){
        NSLog(@"GetAppUpdateService Failed");
    }
    [self.listener threadErrorWithClass:service response:nil];
}
- (void)threadSuccessWithClass:(id)service response:(id)response{
    if([service isMemberOfClass:[GetAppUpdateService class]]){
        [self getAppUpdateSupportingMethod:response];
    }else{
        [self execute];
    }
}
-(void)getAppUpdateSupportingMethod:(id)response{
    NSDictionary *responseDict=[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    responseDict = [responseDict dictionaryRemovingNSNullValues];
    NSDictionary *resultDict = [responseDict valueForKey:@"result"];
    BOOL doUpdate = [[resultDict valueForKey:@"update"] boolValue];
    NSString * currentAppVersion = [Utilities appCurrentVersion];
    NSString * minAppVersion = [resultDict valueForKey:@"minAppVersion"];
    NSString *message = [NSString stringWithFormat:@"You are using %@ version \n%@ version is available \nClick OK button to update \nthe app from Appstore",currentAppVersion,minAppVersion];
    if (doUpdate == YES) {
        //                    [[Singleton sharedManager] showAlert:@"Update Available" message:message];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountBased" bundle:nil];
        CustomAlertAppUpdateController *appUpdate=[storyboard instantiateViewControllerWithIdentifier:@"appUpdate"];
        [appUpdate setResponse:responseDict];
        appUpdate.delegate=self;
        appUpdate.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        appUpdate.modalPresentationStyle=UIModalPresentationOverCurrentContext;

        if ([[Singleton sharedManager] isAppUpdateAlertPresented] == YES) {
            [[Singleton sharedManager] setIsAppUpdateAlertPresented:NO];
           // NSLog(@"Alert exists");
        }else{
            [[Singleton sharedManager] setIsAppUpdateAlertPresented:YES];
        //    NSLog(@" please present alert here.");
        //    [[[Singleton sharedManager] currentNVC] presentViewController:appUpdate animated:NO completion:nil];
            [[Utilities topMostController] presentViewController:appUpdate animated:NO completion:nil];
        }
    }
    else{
        [self executeActualAPi];
    }
}

-(void)execute{
    if(self.managedObjectContext==nil){
        self.managedObjectContext=[[Singleton sharedManager] managedContext];
    }
    if([self isMemberOfClass:[LoginService class]] || [self isMemberOfClass:[RegisterAccountService class]] || [self isMemberOfClass:[GetWalletContents class]]){
        GetAppUpdateService *appUpdateService = [[GetAppUpdateService alloc] initWithListener:self managedObjectContext:self.managedObjectContext];
        [appUpdateService executeActualAPi];
    }
    else{
        [self executeActualAPi];
    }
    
    
}


- (void)executeActualAPi
{
    NSString *urlString = nil;
    
    if (@available(iOS 8.0, *)) {
//        NSLog(@"base service host %@<--",self.host);
    
        NSString *tenantId = [Utilities tenantId];
        if ([tenantId isEqualToString:@"COTA"]) {
            urlString = [NSString stringWithFormat:@"https://%@/", self.host];
        }else if ([tenantId isEqualToString:@"BCT"]) {
            urlString = [NSString stringWithFormat:@"https://%@/", self.host];
        }else if ([tenantId isEqualToString:@"CDTA"]){
            if ([self.host containsString:@"api.cota.com"]){
                urlString = [NSString stringWithFormat:@"https://%@/", self.host];
            }
            else if ([self.host containsString:@"localhost"] || [self.host containsString:@"ngrok.io"] || (_method >= METHOD_SIMPLE)) {
                urlString = [NSString stringWithFormat:@"http://%@/", self.host];
            } else {
                urlString = [NSString stringWithFormat:@"https://%@/", self.host];
            }
        }else{
            urlString = [NSString stringWithFormat:@"https://%@/", self.host];
        }
    } else {
        // Fallback on earlier versions
    }
    
    __block BaseService *blockSafeSelf = self;
    //    NSLog(@"\nurl:%@",[urlString stringByAppendingString:self.uri]);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Use METHOD_SIMPLE for endpoints outside of the CooCoo domain
    if (_method == METHOD_SIMPLE) {
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        
        [manager GET:[urlString stringByAppendingString:self.uri]
          parameters:self.createRequest
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                 
             }];
    } else if (_method == METHOD_SIMPLE_JSON) {
        NSDictionary *headers = [self headers];
        if (headers) {
            NSEnumerator *enumerator = [headers keyEnumerator];
            id key;
            while ((key = enumerator.nextObject)) {
                [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
            }
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        [manager GET:[urlString stringByAppendingString:self.uri]
          parameters:self.createRequest
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                 
             }];
    } else if (_method == METHOD_SIMPLE_POST
               ) {
        NSDictionary *headers = [self headers];
        if (headers) {
            NSEnumerator *enumerator = [headers keyEnumerator];
            id key;
            while ((key = enumerator.nextObject)) {
                [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
            }
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        [manager POST:[urlString stringByAppendingString:self.uri]
           parameters:self.createRequest
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                  
              }];
    } else if (_method == METHOD_SIMPLE_POST_SECURE) {
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [[manager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSDictionary *headers = [self headers];
        if (headers) {
            NSEnumerator *enumerator = [headers keyEnumerator];
            id key;
            while ((key = enumerator.nextObject)) {
                [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
            }
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        if (self.acceptableContentTypes) {
            [[manager responseSerializer] setAcceptableContentTypes:self.acceptableContentTypes];
        }
        
        NSString *uri = @"";
        if ([self.uri length] > 0) {
            uri = self.uri;
        }
        
        [manager POST:[urlString stringByAppendingString:uri]
           parameters:self.createRequest
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
               
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                 
              }];
    } else if (_method == METHOD_GET) {
//        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
//                                                                    password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        
        [manager GET:[urlString stringByAppendingString:self.uri]
          parameters:self.createRequest
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                
             }];
    } else if (_method == METHOD_GET_JSON) {
//             [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
//                                                                        password:[Utilities authPassword]];
//
        
        
        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
       // NSLog(@"%@",[urlString stringByAppendingString:self.uri]);
        [manager GET:[urlString stringByAppendingString:self.uri]
          parameters:self.createRequest
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                 
             }];
    } else if (_method == METHOD_PATCH) {
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [[manager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
      //  [[manager requestSerializer]setAuthorizationHeaderFieldWithUsername:[Utilities authUsername] password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        [manager PATCH:[urlString stringByAppendingString:self.uri]
            parameters:self.createRequest
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                   
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                   
               }];
    }  else if (_method == METHOD_PUT) {
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        
//        [[manager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
//                                                                    password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        [manager PUT:[urlString stringByAppendingString:self.uri]
          parameters:self.createRequest
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                 
             }];
    } else if (_method == METHOD_DELETE) {
//        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
//                                                                    password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        [manager DELETE:[urlString stringByAppendingString:self.uri]
             parameters:self.createRequest
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                   
                    
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                    
                }];
    }else if (_method == METHOD_PUT) {
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        
        [[manager requestSerializer] setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
//                                                                    password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        [manager PUT:[urlString stringByAppendingString:self.uri]
          parameters:self.createRequest
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                 
             }];
    } else if (_method == METHOD_DELETE) {
//        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
//                                                                    password:[Utilities authPassword]];
        
        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        [manager DELETE:[urlString stringByAppendingString:self.uri]
             parameters:self.createRequest
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
                    
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
                    
                }];
    } else {
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        NSDictionary *headers = [Utilities headers:[urlString stringByAppendingString:self.uri]];
       // NSLog(@"....................%@",headers);
        NSEnumerator *enumerator = [headers keyEnumerator];
        id key;
        while ((key = enumerator.nextObject)) {
            [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [[manager responseSerializer] setAcceptableContentTypes:[NSSet setWithObjects:@"text/html", @"application/json", @"application/x-www-form-urlencoded", nil]];
        NSString *url = [urlString stringByAppendingString:self.uri];
        if ([url rangeOfString:@"grant_type=password"].location != NSNotFound ) {
            NSMutableData *postData = [self createRequest];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                                   cachePolicy:NSURLRequestReloadIgnoringCacheData  timeoutInterval:10];
            [request setHTTPMethod:@"POST"];
            [request setAllHTTPHeaderFields:headers];
            if (postData) {
                [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[(NSMutableData *)postData length]] forHTTPHeaderField:@"content-length"];
                [request setHTTPBody:postData];
            }
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.responseSerializer = [AFJSONResponseSerializer serializer];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];
            }];
            [operation start];
        }else{
            [manager POST:[urlString stringByAppendingString:self.uri]
               parameters:self.createRequest
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {

                      [blockSafeSelf checkAndValidateSuccessHttpResponse:operation response:responseObject];

                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      [blockSafeSelf checkAndValidateFailureHttpResponse:operation error:error];

                  }];
        }
    }
}

-(Account *)currentUserAccount {
    if(self.managedObjectContext==nil){
        self.managedObjectContext=[[Singleton sharedManager] managedContext];
    }

    Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
    return account;
}

-(void)checkAndValidateFailureHttpResponse:(AFHTTPRequestOperation *)operation error:(NSError*)error{
    [self printAPIFailureData:operation errorData:error];
    NSLog(@"statusCode is:->%ld<-",(long)operation.response.statusCode);
    long statusCode = operation.response.statusCode;
    if (statusCode == 420) {
//        [[Singleton sharedManager] logOutHandler];
//        [Utilities popToRootViewController];
        return;
    }else if ([self isMemberOfClass:[AuthorizeTokenService class]] && statusCode != 200) {
//        [[Singleton sharedManager] logOutHandler];
//        [Utilities popToRootViewController];
        return;
    }else if (![self isMemberOfClass:[AuthorizeTokenService class]] && statusCode >= 401) {
        Account *account = [CooCooAccountUtilities1 currentAccount:self.managedObjectContext];
        if(account){
            AuthorizeTokenService *tokenService = [[AuthorizeTokenService alloc] initWithListener:self username:account.emailaddress password:account.password];
            [tokenService execute];
        }else{
            GetOAuthService * getOAuthService = [[GetOAuthService alloc] initWithListener:self];
            [getOAuthService execute];
        }
    }
    [self.listener threadErrorWithClass:self response:operation.responseObject];
}
-(void)checkAndValidateSuccessHttpResponse:(AFHTTPRequestOperation *)operation response:(id)responseObject{
    if (responseObject==nil) {
        [self.listener threadErrorWithClass:self response:operation.responseString];
        return;
    }
    if (operation.responseString) {
        BOOL dataSuccess = [self processResponse:operation.responseString];
        if (dataSuccess) {
            [self printAPIData:operation];
            [self.listener threadSuccessWithClass:self response:operation.responseString];
        } else {
            [self.listener threadErrorWithClass:self response:operation.responseString];
        }} else {
            [self.listener threadErrorWithClass:self response:nil];
        }
}

#pragma mark - Helper methods

+ (BOOL)isResponseOk:(NSDictionary *)jsonResponse{
    if ([[jsonResponse valueForKey:@"status"] isEqualToString:@"success"] || [jsonResponse valueForKey:@"success"]) {
        return YES;
    } else {
        return NO;
    }
}
#pragma mark - CustomAlertView Delegate Method
- (void) OkAction{
    //Appstore Link
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities appstoreLink]]]];
    //    if ([[[Utilities apiEnvironment] lowercaseString] containsString:@"st"]) {
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities stagingLink]]]];
    //    }else if ([[[Utilities apiEnvironment] lowercaseString] containsString:@"ua"]){
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities uatLink]]]];
    //    }else{
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[Utilities stringResourceForId:[Utilities appstoreLink]]]];
    //    }
    
}
@end

