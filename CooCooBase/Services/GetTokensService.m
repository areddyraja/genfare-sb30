//
//  GetTokensService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetTokensService.h"
#import "AFNetworking.h"
#import "BaseService.h"
#import "Token.h"
#import "Utilities.h"

@implementation GetTokensService
{
    NSManagedObjectContext *managedObjectContext;
}

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        managedObjectContext = context;
    }
    
    return self;
}

- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [Utilities transitId], @"transitid",
            nil];
}

- (void)execute
{
    __block GetTokensService *blockSafeSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:[Utilities authUsername]
                                                                password:[Utilities authPassword]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
    NSDictionary *headers = [Utilities headers:[[Utilities apiUrl] stringByAppendingString:@"/security-tokens/"]];
    NSEnumerator *enumerator = [headers keyEnumerator];
    id key;
    while ((key = enumerator.nextObject)) {
        [[manager requestSerializer] setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    
    [manager GET:[[Utilities apiUrl] stringByAppendingString:@"/security-tokens/"]
      parameters:self.createRequest
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [blockSafeSelf processResponse:responseObject];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"GetTokensService Base Error Req: %@, Response: %@", operation.request, operation.responseString);
         }];
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        [self deleteOldTokens];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:TOKEN_MODEL inManagedObjectContext:managedObjectContext]];
        
        NSError *error = nil;
        NSArray *tokens = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        // Delete any nil tokens just in case
        for (Token *token in tokens) {
            if (!token.image) {
                [managedObjectContext deleteObject:token];
            }
        }
        
        NSError *saveError = nil;
        [managedObjectContext save:&saveError];
        
        NSArray *resultArray = [json valueForKey:@"result"];
        
        if (self.isGetTokenOfDay) {
            NSString *key = [Token tokenDateStringFromDate:[NSDate date]];
            NSString *tokenUrl = [resultArray valueForKey:key];
            
            BOOL tokenExists = NSNotFound != [tokens indexOfObjectPassingTest:^(Token *token, NSUInteger idx, BOOL *stop) {
                BOOL condition = token.image && [token.date isEqualToString:key];
                
                return condition;
            }];
            
            if (!tokenExists) {
                Token *token = (Token *)[NSEntityDescription insertNewObjectForEntityForName:TOKEN_MODEL inManagedObjectContext:managedObjectContext];
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tokenUrl]];
                
                if (imageData != nil) {
                    [token setDate:key];
                    [token setImage:imageData];
                    
                    NSError *saveError;
                    if (![managedObjectContext save:&saveError]) {
                        NSLog(@"Main Context error, couldn't save: %@", [saveError localizedDescription]);
                    }
                }
            }
        } else {
            for (NSString *key in resultArray) {
                NSString *tokenUrl = [resultArray valueForKey:key];
                
                BOOL tokenExists = NSNotFound != [tokens indexOfObjectPassingTest:^(Token *token, NSUInteger idx, BOOL *stop) {
                    BOOL condition = token.image && [token.date isEqualToString:key];
                    
                    return condition;
                }];
                
                if (!tokenExists) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                        [context setParentContext:managedObjectContext];
                        
                        Token *token = (Token *)[NSEntityDescription insertNewObjectForEntityForName:TOKEN_MODEL inManagedObjectContext:context];
                        
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tokenUrl]];
                        
                        if (imageData != nil) {
                            [token setDate:key];
                            [token setImage:imageData];
                            
                            NSError *saveError;
                            if (![context save:&saveError]) {
                                NSLog(@"Background Context error, couldn't save: %@", [saveError localizedDescription]);
                            }
                            
                            [managedObjectContext performBlock:^{
                                NSError *saveError;
                                if (![managedObjectContext save:&saveError]) {
                                    NSLog(@"Main Context Error, couldn't save: %@", [saveError localizedDescription]);
                                }
                            }];
                        }
                    });
                }
            }
        }
        
        return YES;
    }
    
    return NO;
}

- (void)deleteOldTokens
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:TOKEN_MODEL inManagedObjectContext:managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date < %@", [Token tokenDateStringFromDate:[NSDate date]]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *tokens = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Token *token in tokens) {
        [managedObjectContext deleteObject:token];
    }
    
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}

@end
