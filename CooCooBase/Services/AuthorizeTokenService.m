//
//  AuthorizeTokenService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/14/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "AuthorizeTokenService.h"
#import "Utilities.h"
#import "StoredData.h"
#import "OAuth.h"
#import "AppConstants.h"

@implementation AuthorizeTokenService
{
    NSString *username;
    NSString *password;
    //    NSString *token;
}


- (id)initWithListener:(id)lis
              username:(NSString *)user
              password:(NSString *)pass
{
    self = [super init];
    if (self) {
        self.listener = lis;
        self.method = METHOD_POST;
        username = user;
        password = pass;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities auth_host];
}
//- (NSDictionary *)headers
//{
//    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
//
//    [headers setObject:@"Basic Y29vY29vOnNlY3JldA==" forKey:@"Authorization"];
//
//    return headers;
//}
- (NSString *)uri{
//    NSString *authUsername = [Utilities authUsername];
    //    NSString * updatedUri = [NSString stringWithFormat:@"authenticate/oauth/token?grant_type=password"];
    //                             &client_id=%@&username=%@&password=%@",authUsername,username,password];
    NSString * updatedUri = [NSString stringWithFormat:@"authenticate/oauth/token?grant_type=password"];

    return updatedUri;
}
- (id)createRequest{
    NSString *authUsername = [Utilities authUsername];
    NSString *encodedPassword = [Utilities urlencode:password];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"username=%@",username] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"&password=%@",encodedPassword] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"&client_id=%@",authUsername] dataUsingEncoding:NSUTF8StringEncoding]];
    return postData;
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
- (void)setDataWithJson:(NSDictionary *)json{
    // NSLog(@"Oauth json====== %@",json);
    OAuth *oAuth = [[OAuth alloc] init];
    [oAuth setAccessToken:[json objectForKey:@"access_token"]];
    [oAuth setTokenType:[json objectForKey:@"token_type"]];
    [oAuth setExpiresIn:[json objectForKey:@"expires_in"]];
    [oAuth setScope:[json objectForKey:@"scope"]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults setObject:[json objectForKey:@"access_token"] forKey:KEY_ACCESS_TOKEN];
    [defaults setObject:[json objectForKey:@"access_token"] forKey:COMMON_KEY_ACCESS_TOKEN];
    [defaults synchronize];

}
@end

