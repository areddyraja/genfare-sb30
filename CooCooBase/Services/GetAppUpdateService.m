//
//  GetAppUpdateService.m
//  CDTATicketing
//
//  Created by omniwyse on 11/07/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import "GetAppUpdateService.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"

@implementation GetAppUpdateService{
}

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = listener;
        self.managedObjectContext = managedContext;
    }
    return self;
}
#pragma mark - Class overrides

- (NSString *)host{
    return [Utilities dev_ApiHost];
}
- (NSString *)uri{
    NSString *tenantId = [Utilities tenantId];
    NSString *versionString = [Utilities appCurrentVersion];
    return [NSString stringWithFormat:@"services/data-api/mobile/app/iOS/%@?tenant=%@",versionString,tenantId];
}
- (NSArray *)createRequest{
    return nil;
//    return  epochsecond;
}
//- (NSDictionary *)headers{
//    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
//    NSString * base64String = [Utilities accessToken];
//    [headers setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];
//    [headers setValue:@"application/json" forKey:@"Accept"];
//    return headers;
//}




- (BOOL)processResponse:(id)serverResult{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    if ((json != nil) && [json count] > 0) {
        [self setDataWithJson:json];
        return YES;
    }
    return NO;
}
#pragma mark - Other methods
- (void)setDataWithJson:(NSDictionary *)json{
//    NSDictionary *resultDict = [json valueForKey:@"result"];
//    NSNumber * doUpdate = [resultDict valueForKey:@"update"];
}
@end
