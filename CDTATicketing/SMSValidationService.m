
#import "SMSValidationService.h"
#import "Utilities.h"
@implementation SMSValidationService
{
    NSString *deviceid;
    
}

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext deviceid:(NSString*)uid
{
    self = [super init];
    if (self) {
        deviceid=uid;
        self.method = METHOD_GET;
        self.listener = listener;
        self.managedObjectContext = managedContext;
        
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
    
     return [NSString stringWithFormat:@"services/data-api/mobile/users/on/%@/status?tenant=%@",deviceid,tenantId];
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
    
    NSLog(@"Released wallet service of  result for created user: %@", serverResult);
    
    
    return YES;
}

@end


