//
//  AccountBalance.m
//  AFNetworking-iOS10.0
//
//  Created by omniwyse on 11/04/18.
//

#import "AccountBalance.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"

@implementation AccountBalance

{
    
}


- (id)initWithListener:(id)lis
{
    self = [super init];
    if (self) {
        self.method=METHOD_GET;
        self.listener = lis;
        
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities dev_ApiHost];
}

- (NSString *)uri
{
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/account/balance?tenant=%@",tenantId];
}

- (NSDictionary *)createRequest
{
    
    return nil;
}
- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    NSString * base64String = [Utilities accessToken];
    [headers setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];
    [headers setValue:@"application/json" forKey:@"Accept"];
    return headers;
}

- (BOOL)processResponse:(id)serverResult
{
    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
 
    [[NSUserDefaults standardUserDefaults] setObject:json[@"balance"] forKey:@"accountbalance"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

@end
