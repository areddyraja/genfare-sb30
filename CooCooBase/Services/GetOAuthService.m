//
//  GetOAuthService.m
//  CDTATicketing
//
//  Created by omniwyse on 12/10/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "GetOAuthService.h"
#import "OAuth.h"
#import "Singleton.h"
//#import "CDTARuntimeData.h"


@implementation GetOAuthService

- (id)initWithListener:(id)listener
{
    self = [super init];
    if (self) {
        self.method = METHOD_POST;
        self.managedObjectContext=[[Singleton sharedManager] managedContext];
        self.listener = listener;
    }
    
    return self;
}

- (NSSet *)acceptableContentTypes
{
    return [[NSSet alloc] initWithObjects:@"application/json", nil];
}

 #pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities auth_host];
}
- (NSString *)uri
{
//    NSString *authUsername = [Utilities authUsername];
//    NSString * updatedUri = [NSString stringWithFormat:@"authenticate/oauth/token?grant_type=client_credentials&client_id=%@",authUsername];
    NSString * updatedUri = [NSString stringWithFormat:@"authenticate/oauth/token?grant_type=client_credentials"];
    return updatedUri;
}

- (NSDictionary *)headers
{
    return nil;
}


- (NSDictionary *)createRequest
{
    NSString *authUsername = [Utilities authUsername];
    NSDictionary *deviceDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      authUsername, @"client_id",
                                      nil];
    return deviceDictionary;
}

- (BOOL)processResponse:(id)serverResult
{
    
    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
 
    if ((json != nil) && [json count] > 0) {
        [self setDataWithJson:json];
        
        return YES;
    }
    
    return NO;
}


#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
//    NSLog(@"Oauth json====== %@",json);
    OAuth *oAuth = [[OAuth alloc] init];
    [oAuth setAccessToken:[json objectForKey:@"access_token"]];
    [oAuth setTokenType:[json objectForKey:@"token_type"]];
    [oAuth setExpiresIn:[json objectForKey:@"expires_in"]];
    [oAuth setScope:[json objectForKey:@"scope"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

 
    [defaults setObject:[json objectForKey:@"access_token"] forKey:COMMON_KEY_ACCESS_TOKEN];
     [defaults synchronize];
    

}



@end
