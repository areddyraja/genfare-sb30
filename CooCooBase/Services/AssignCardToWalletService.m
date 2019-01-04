//
//  AssignCardToWalletService.m
//  CooCooBase
//
//  Created by CooCooTech on 3/28/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "AssignCardToWalletService.h"
#import "Utilities.h"

@implementation AssignCardToWalletService
{
    NSString *walletUuid;
    NSString *cardUuid;
 }

- (id)initWithListener:(id)listener
            walletUuid:(NSString *)walletId
              cardUuid:(NSString *)cardId
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_POST;
        self.listener = listener;
        walletUuid = walletId;
        cardUuid = cardId;
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
    return [NSString stringWithFormat:@"wallet/%@/card/%@/assignment", walletUuid, cardUuid];
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
    NSLog(@"AssignCardToWalletService result: %@", serverResult);
    
    return [serverResult isEqualToString:@"200"];
}

@end
