//
//  GetWalletContents.m
//  CooCooBase
//
//  Created by IBase Software on 28/12/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "GetWalletContents.h"
#import "Utilities.h"
#import "WalletContents.h"
@implementation GetWalletContents{
    NSString *wallet_Id;
}
- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)managedContext withwalletid:(NSString *)walletID{
        self = [super init];
        if (self) {
            self.method = METHOD_GET_JSON;
            self.listener = listener;
            self.managedObjectContext = managedContext;
            wallet_Id = walletID;
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
    return [NSString stringWithFormat:@"services/data-api/mobile/wallets/%@/contents?tenant=%@", wallet_Id,tenantId];
}
    
- (NSDictionary *)createRequest
{
    return nil;
}
    
- (BOOL)processResponse:(id)serverResult
{
    NSArray *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    if (json.count >0) {
        [[NSUserDefaults standardUserDefaults]setObject:json forKey:@"WALLET_CONTENTS"];
        [self setDataWithJson:json];
        return YES;
    }
    return  YES;
    
   //NSDictionary *json = (NSDictionary *)serverResult;

//   if ([BaseService isResponseOk:json]) {
//        [self setDataWithJson:[json valueForKey:@"result"]];
//        return YES;
//   }

}
    
#pragma mark - Other methods
    
- (BOOL)setDataWithJson:(NSArray *)result
{
    BOOL success = NO;
    
    NSUInteger count = result.count;

    for (int i = 0; i < count; i++) {
        NSDictionary *walletContentDict = result[i];
        
        WalletContents *walletContent;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:WALLET_CONTENT_MODEL inManagedObjectContext:self.managedObjectContext ]];
        [fetchRequest setIncludesPropertyValues:NO];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticketIdentifier == %@", [walletContentDict valueForKey:@"ticketIdentifier"]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *existingWalletContentsFromDb = [self.managedObjectContext  executeFetchRequest:fetchRequest error:&error];
        if(existingWalletContentsFromDb.count==0){
            walletContent = (WalletContents *)[NSEntityDescription insertNewObjectForEntityForName:WALLET_CONTENT_MODEL inManagedObjectContext:self.managedObjectContext ];
            [walletContent setActivationCount:[NSNumber numberWithInt:0]];
            [walletContent setTicketSource:@"service"];

        }
        else{
            walletContent=existingWalletContentsFromDb.firstObject;
        }

        if (![[walletContentDict valueForKey:@"identifier"] isEqual:[NSNull null]]) {
            [walletContent setIdentifier:[walletContentDict valueForKey:@"identifier"]];
        }
        if (![[walletContentDict valueForKey:@"ticketIdentifier"] isEqual:[NSNull null]]) {
            [walletContent setTicketIdentifier:[walletContentDict valueForKey:@"ticketIdentifier"]];
        }
        if (![[walletContentDict valueForKey:@"type"] isEqual:[NSNull null]]) {
            [walletContent setType:[walletContentDict valueForKey:@"type"]];
        }
        if (![[walletContentDict valueForKey:@"valueRemaining"] isEqual:[NSNull null]]) {
            [walletContent setValueRemaining:[walletContentDict valueForKey:@"valueRemaining"]];
        }
       
        if (![[walletContentDict valueForKey:@"ticketGroup"] isEqual:[NSNull null]]) {
            [walletContent setValueOriginal:[walletContentDict valueForKey:@"valueOriginal"]];
        }
        if (![[walletContentDict valueForKey:@"expirationDate"] isEqual:[NSNull null]]) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *exDate = [df dateFromString:[walletContentDict valueForKey:@"expirationDate"]];
            NSNumber *dateNum = [NSNumber numberWithDouble:[exDate timeIntervalSince1970]];
            [walletContent setTicketExpiryDate:dateNum];
        }

        if (![[walletContentDict valueForKey:@"expirationDate"] isEqual:[NSNull null]]) {
            [walletContent setExpirationDate:[walletContentDict valueForKey:@"expirationDate"]];
        }
        
        if (![[walletContentDict valueForKey:@"ticketEffectiveDate"] isEqual:[NSNull null]]) {
            [walletContent setTicketEffectiveDate:[walletContentDict valueForKey:@"ticketEffectiveDate"]];
        }
        if (![[walletContentDict valueForKey:@"status"] isEqual:[NSNull null]]) {
            [walletContent setStatus:[walletContentDict valueForKey:@"status"]];
        }
        if (![[walletContentDict valueForKey:@"slot"] isEqual:[NSNull null]]) {
            [walletContent setSlot:[walletContentDict valueForKey:@"slot"]];
        }
        if (![[walletContentDict valueForKey:@"slot"] isEqual:[NSNull null]]) {
            [walletContent setSlot:[walletContentDict valueForKey:@"slot"]];
        }
        if (![[walletContentDict valueForKey:@"purchasedDate"] isEqual:[NSNull null]]) {
            [walletContent setPurchasedDate:[walletContentDict valueForKey:@"purchasedDate"]];
        }
        if (![[[[walletContentDict valueForKey:@"Attribute"]objectAtIndex:0]valueForKey:@"value"] isEqual:[NSNull null]]) {
            [walletContent setGroup:[[[walletContentDict valueForKey:@"Attribute"]objectAtIndex:0]valueForKey:@"value"]];
        }
        if (![[walletContentDict valueForKey:@"instanceCount"] isEqual:[NSNull null]]) {
            [walletContent setInstanceCount:[walletContentDict valueForKey:@"instanceCount"]];
        }
        
        if (![[[[walletContentDict valueForKey:@"Attribute"]objectAtIndex:1]valueForKey:@"value"] isEqual:[NSNull null]]) {
            
            NSDictionary *walletJson = [walletContentDict valueForKey:@"Attribute"];
            if ([walletJson allKeys].count > 0) {
            [walletContent setMember:[walletJson objectForKey:@"value"]];
            }
        }
        if (![[walletContentDict valueForKey:@"attributes"] isEqual:[NSNull null]]) {
            
            NSDictionary *walletJson = [walletContentDict valueForKey:@"attributes"];
            NSArray *attbs = [walletJson valueForKey:@"Attribute"];
            if (attbs.count > 1) {
                if (![[[attbs objectAtIndex:1] valueForKey:@"value"] isEqual:[NSNull null]]) {
                    [walletContent setMember:[[attbs objectAtIndex:1] valueForKey:@"value"]];
                }
            }
        }
        if (![[walletContentDict valueForKey:@"attributes"] isEqual:[NSNull null]]) {
            
            NSDictionary *walletJson = [walletContentDict valueForKey:@"attributes"];
            NSArray *attbs = [walletJson valueForKey:@"Attribute"];
            if (attbs.count > 1) {
                if (![[[attbs objectAtIndex:0] valueForKey:@"value"] isEqual:[NSNull null]]) {
                    [walletContent setTicketGroup:[[attbs objectAtIndex:0] valueForKey:@"value"]];
                }
            }
        }
        if (![[walletContentDict valueForKey:@"fare"] isEqual:[NSNull null]]) {
            [walletContent setFare:[walletContentDict valueForKey:@"fare"]];
        }
        if (![[walletContentDict valueForKey:@"designator"] isEqual:[NSNull null]]) {
            [walletContent setDesignator:[walletContentDict valueForKey:@"designator"]];
        }
        if (![[walletContentDict valueForKey:@"description"] isEqual:[NSNull null]]) {
            [walletContent setDescriptation:[walletContentDict valueForKey:@"description"]];
        }
        if (![[walletContentDict valueForKey:@"balance"] isEqual:[NSNull null]]) {
            [walletContent setBalance:[walletContentDict valueForKey:@"balance"]];
        }
        if (![[walletContentDict valueForKey:@"agencyId"] isEqual:[NSNull null]]) {
            [walletContent setAgencyId:[walletContentDict valueForKey:@"agencyId"]];
        }
        
        [walletContent setAllowInteraction:[NSNumber numberWithBool:true]];

        NSError *error1;
        if (![self.managedObjectContext  save:&error1]) {
            NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
        } else {
            success = YES;
        }
        
    }
    return success;
}
    
@end

