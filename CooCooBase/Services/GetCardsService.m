//
//  GetCardsService.m
//  Pods
//
//  Created by Andrey Kasatkin on 3/20/16.
//
//

#import "GetCardsService.h"
#import "Utilities.h"
#import "Card.h"

@implementation GetCardsService
{
    NSString *walletUuid;
}

- (id)initWithListener:(id)listener
            walletUuid:(NSString *)wallet
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = listener;
        walletUuid = wallet;
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
    NSLog(@"GetCardsService URI: %@", [NSString stringWithFormat:@"wallet/%@/cards", walletUuid]);
    
    return [NSString stringWithFormat:@"wallet/%@/cards", walletUuid];
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
    //NSLog(@"GetCardsService result: %@", serverResult);
    
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        if (![[json valueForKey:@"result"] isEqual:[NSNull null]]) {
            NSArray *result = [json valueForKey:@"result"];
            
            [self deleteCards];
            return [self setDataWithJson:result];
        }
        
        return YES;
    }
    
    return NO;
}


- (BOOL)setDataWithJson:(NSArray *)result
{
    BOOL success = NO;
    
    NSUInteger count = result.count;
    
    for (int i = 0; i < count; i++) {
        NSDictionary *cardDict = result[i];
        
        Card *card = (Card *)[NSEntityDescription insertNewObjectForEntityForName:CARD_MODEL inManagedObjectContext:self.managedObjectContext];
        [card setIsTemporary:[NSNumber numberWithBool:NO]];
        [card setUuid:[cardDict valueForKey:@"uuid"]];
        [card setHuuid:[cardDict valueForKey:@"huuid"]];
        [card setCvv:[cardDict valueForKey:@"cvv"]];
        [card setState:[cardDict valueForKey:@"state"]];
        
        NSDate *createdDate = [Utilities dateFromUTCString:[cardDict valueForKey:@"created"]];
        NSDate *modifiedDate = [Utilities dateFromUTCString:[cardDict valueForKey:@"modified"]];
        
        [card setCreatedDateTime:createdDate];
        [card setModifiedDateTime:modifiedDate];
        
        if (![[cardDict valueForKey:@"nickname"] isEqual:[NSNull null]]) {
            [card setNickname:[cardDict valueForKey:@"nickname"]];
        }
        
        if (![[cardDict valueForKey:@"description"] isEqual:[NSNull null]]) {
            [card setCardDescription:[cardDict valueForKey:@"description"]];
        }
        
        if (![[cardDict valueForKey:@"wallet"] isEqual:[NSNull null]]) {
            NSDictionary *walletJson = [cardDict objectForKey:@"wallet"];
            
            [card setWalletUuid:[walletJson objectForKey:@"uuid"]];
            [card setWalletHuuid:[walletJson objectForKey:@"huuid"]];
        }
        
        NSDictionary *accountObject = [cardDict valueForKey:@"account"];
        
        if (![[cardDict valueForKey:@"account"] isEqual:[NSNull null]]) {
            [card setAccountEmail:[accountObject valueForKey:@"email_address"]];
            [card setAccountId:[accountObject valueForKey:@"uuid"]];
            
            if (![[accountObject valueForKey:@"authorization"] isEqual:[NSNull null]]) {
                [card setAccountAuthToken:[[accountObject valueForKey:@"authorization"] valueForKey:@"token"]];
            }
        }
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
    } else {
        success = YES;
    }
    
    return success;
}

- (void)deleteCards
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:CARD_MODEL inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *cards = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Card *card in cards) {
        [self.managedObjectContext deleteObject:card];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
