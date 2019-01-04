//
//  ForgetCardService.h.m
//  CooCooBase
//
//  Created by Andrey Kasatkin on 3/25/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "ReleaseCardService.h"
#import "Utilities.h"
@implementation ReleaseCardService
{
    Card *card;
}

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                  card:(Card *)cardObject
{
    self = [super init];
    if (self) {
        self.listener = lis;
        card = cardObject;
        self.managedObjectContext = managedObjectContext;
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
    return [NSString stringWithFormat:@"wallet/%@/card/%@/release", [Utilities walletId], card.uuid];
}

- (BOOL)processResponse:(id)serverResult
{
    if ([serverResult isEqualToString:@"200"]) {
        [self.managedObjectContext deleteObject:card];
        
        NSError * error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error ! %@", error);
        } else {
            return YES;
        }
    }
    
    return NO;
}

@end
