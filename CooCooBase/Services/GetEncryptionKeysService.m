//
//  LoginService.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "GetEncryptionKeysService.h"
#import "CooCooAccountUtilities1.h"
#import "RuntimeData.h"
#import "StoredData.h"
#import "Utilities.h"
#import "EncryptionKey.h"


@implementation GetEncryptionKeysService
{
 
    
}

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
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
    return [NSString stringWithFormat:@"services/data-api/mobile/encryptionkey?tenant=%@",tenantId];
}

- (NSDictionary *)createRequest
{
    return nil;
}


- (BOOL)processResponse:(id)serverResult
{
    
    
    
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];


 
    NSLog(@"Getencryptionkeys result : %@", serverResult);
    [self setDataWithJson:json];
   
//      NSArray *server = [json objectForKey:@"result"];
//    if(server.count >0){
//        NSDictionary *walletDict = server.firstObject;
//        [[NSUserDefaults standardUserDefaults]setObject:walletDict[@"walletId"] forKey:@"WALLET_ID"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//     }

 
    
    
    return YES;
}



- (void)setDataWithJson:(NSDictionary *)json
{
    
    
    [self deleteAllFromEntity:ENCRYPTION_KEY_MODEL];
    
    EncryptionKey *encryptionSet = (EncryptionKey *)[NSEntityDescription insertNewObjectForEntityForName:ENCRYPTION_KEY_MODEL inManagedObjectContext:self.managedObjectContext];
    
    NSDictionary *result = json[@"result"];
    encryptionSet.initializationVector=result[@"initializationVector"];
    encryptionSet.secretKey=result[@"secretKey"];
    encryptionSet.algorithm=result[@"algorithm"];
    encryptionSet.keyId=result[@"keyId"];
    
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    }
}

- (void) deleteAllFromEntity:(NSString *)entityName {
    NSFetchRequest * allRecords = [[NSFetchRequest alloc] init];
    [allRecords setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext]];
    [allRecords setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * result = [self.managedObjectContext executeFetchRequest:allRecords error:&error];
    for (NSManagedObject * profile in result) {
        [self.managedObjectContext deleteObject:profile];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end

