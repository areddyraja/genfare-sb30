//
//  RequestNewWalletService.m
//  Pods
//
//  Created by Andrey Kasatkin on 3/20/16.
//
//

#import "RequestNewWalletService.h"
#import <UIKit/UIKit.h>
#import "SSKeychain.h"
#import "Utilities.h"
#import "Wallet.h"

@implementation RequestNewWalletService
{
}

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)context;
{
    self = [super init];
    if (self) {
        self.method = METHOD_POST;
        self.listener = lis;
        self.managedObjectContext = context;
    }
    
    return self;
}

#pragma mark - Class overrides

- (NSString *)host
{
    return [Utilities apiHost];
}

- (NSString *)uri
{
    return @"wallet";
}

- (NSDictionary *)createRequest
{
    NSDictionary *device = [NSDictionary dictionaryWithObjectsAndKeys:
                            [Utilities deviceId], @"uuid",
                            nil];
    
    UIDevice *uiDevice = [UIDevice currentDevice];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            device, @"device",
            uiDevice.name, @"nickname",
            uiDevice.systemVersion, @"description",
            nil];
}

- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"RequestNewWalletsService result: %@", serverResult);
    
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
         if ([self setDataWithJson:[json valueForKey:@"result"]])
             return YES;
    }
    
    return NO;
}

- (BOOL)setDataWithJson:(NSDictionary *)json
{
    BOOL success = NO;
    
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:WALLET_MODEL];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@",[json valueForKey:@"id"]]];
    NSError *error = nil;
    NSArray *walletarray = [self.managedObjectContext executeFetchRequest:request error:&error];
    Wallet *wallet;
    if(walletarray.count>0){
        wallet = [walletarray firstObject];
    }
    else{
        wallet = (Wallet *)[NSEntityDescription insertNewObjectForEntityForName:WALLET_MODEL inManagedObjectContext:self.managedObjectContext];
    }
    
    
    if (![[json valueForKey:@"id"] isEqual:[NSNull null]]) {
        [wallet setId:[json valueForKey:@"id"]];
    }
    if (![[json valueForKey:@"deviceUUID"] isEqual:[NSNull null]]) {
        [wallet setDeviceUUID:[json valueForKey:@"deviceUUID"]];
    }
    if (![[json valueForKey:@"nickname"] isEqual:[NSNull null]]) {
        [wallet setNickname:[json valueForKey:@"nickname"]];
    }
    if (![[json valueForKey:@"status"] isEqual:[NSNull null]]) {
        [wallet setStatus:[json valueForKey:@"status"]];
    }
    if (![[json valueForKey:@"personId"] isEqual:[NSNull null]]) {
        [wallet setPersonId:[json valueForKey:@"personId"]];
    }
    if (![[json valueForKey:@"statusId"] isEqual:[NSNull null]]) {
        [wallet setStatusId:[json valueForKey:@"statusId"]];
    }
    if (![[json valueForKey:@"walletUUID"] isEqual:[NSNull null]]) {
        [wallet setWalletUUID:[json valueForKey:@"walletUUID"]];
    }
    [[NSUserDefaults standardUserDefaults] setValue:[json valueForKey:@"id"] forKey:@"WALLET_ID"];

    [self saveToKeychain:[json valueForKey:@"deviceUUID"]];
    
     if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    } else {
        success = YES;
    }
    
    return success;
}

-(void)saveToKeychain:(NSString *)walletUuid
{
    // Change default accessibilty permission to be always accessible
    [SSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
    
    // Save the CFUUID string to keychain for persistence if user uninstalls the app
    [SSKeychain setPassword:walletUuid forService:[[NSBundle mainBundle] bundleIdentifier] account:WALLET_MODEL];
}

@end
