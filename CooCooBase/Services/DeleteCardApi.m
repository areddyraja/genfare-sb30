





#import "DeleteCardApi.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"


@implementation DeleteCardApi
{
    NSString *savedCardNumber;
    
}

- (id)initWithListener:(id)lis savedCard:(NSString *)savedCard

{
    self = [super init];
    if (self) {
        self.method=METHOD_DELETE;
        self.listener = lis;
        savedCardNumber = (NSString *)savedCard;
        
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
    return [NSString stringWithFormat:@"services/data-api/mobile/payment/options/%@?tenant=%@",savedCardNumber,tenantId];
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
    NSLog(@"deleted card: %@", serverResult);
    return YES;
}

@end

