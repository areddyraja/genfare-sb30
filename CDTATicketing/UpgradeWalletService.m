//
//  UpgradeWalletService.m
//  Pods
//
//  Created by ibasemac3 on 6/20/17.
//
//

#import "UpgradeWalletService.h"
#import "Utilities.h"

@implementation UpgradeWalletService
{
        NSDictionary *paramDict;
        NSString *walletid;
        NSManagedObjectContext *context;
}

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
         parameterDict:(NSMutableDictionary *)dict
              walletID:(NSString *)walletID
{
    self = [super init];
    if (self) {
    paramDict = dict;
    walletid = walletID;
    context = managedObjectContext;
    self.method = METHOD_PUT;
    self.listener = lis;
    
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
    return [NSString stringWithFormat:@"wallet/%@",walletid];
}

- (NSDictionary *)createRequest
{
    return paramDict;
}

- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"serverResult %@", serverResult);
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        } else {
            return YES;
        }
    }
    return NO;
}


@end
