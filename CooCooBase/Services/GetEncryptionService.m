//
//  GetEncryptionService.m
//  CooCooBase
//
//  Created by John Scuteri on 9/22/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "GetEncryptionService.h"
#import "EncryptionSet.h"
#import "Utilities.h"
#import "EncryptionKey.h"
@implementation GetEncryptionService
{
}

- (id)initWithListener:(id)lis
  managedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
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
    NSString *tenantId = [Utilities tenantId];
    return [NSString stringWithFormat:@"services/data-api/mobile/encryptionkey?tenant=%@",tenantId];
    //return @"services/data-api/mobile/encryptionkey?tenant=COTA";
}

- (NSDictionary *)createRequest
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [Utilities transitId], @"transitid",
            nil];
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    if ([BaseService isResponseOk:json]) {
        [self setDataWithJson:[json valueForKey:@"result"]];
        return YES;
    }
    
    return NO;
}


- (void)setDataWithJson:(NSDictionary *)json
{
    
   
    [self deleteAllFromEntity:ENCRYPTION_KEY_MODEL];
    
     EncryptionKey *encryptionSet = (EncryptionKey *)[NSEntityDescription insertNewObjectForEntityForName:ENCRYPTION_KEY_MODEL inManagedObjectContext:self.managedObjectContext];
    
    encryptionSet.initializationVector=json[@"initializationVector"];
     encryptionSet.secretKey=json[@"secretKey"];
    encryptionSet.algorithm=json[@"algorithm"];
    encryptionSet.keyId = json[@"keyId"];
    
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

/*
- (void)setDataWithJson:(NSArray *)json
{
    for (NSDictionary *encryptionObjectDict in json) {
        [self deleteEncryptedSetById:[NSNumber numberWithInteger:[[encryptionObjectDict valueForKey:@"id"] integerValue]]];
        EncryptionSet *encryptionSet = (EncryptionSet *)[NSEntityDescription insertNewObjectForEntityForName:ENCRYPTION_SET_MODEL inManagedObjectContext:managedObjectContext];
        [encryptionSet setIdNum:[NSNumber numberWithInteger:[[encryptionObjectDict valueForKey:@"id"] integerValue]]];
       
        [encryptionSet setPrimaryData:[encryptionObjectDict valueForKey:@"publicKey"]];//primary_data is changed to public_key
        if ([[encryptionObjectDict valueForKey:@"algorithm"] caseInsensitiveCompare:@"aes"] == NSOrderedSame){
            [encryptionSet setSecondaryData:[encryptionObjectDict valueForKey:@"initializationVector"]];//for AES
        } else {
           [encryptionSet setSecondaryData:[encryptionObjectDict valueForKey:@"private_key"]];//for RSA
        }
        
        [encryptionSet setEnabled:[NSNumber numberWithInteger:1]];//hradcode 1 for enabled
        
        [encryptionSet setCurrentKey:[NSNumber numberWithBool:[[encryptionObjectDict valueForKey:@"current_key"] boolValue]]]; //this is does not exist and never existed
        
        // Create a String from your datasource
        NSString *startDateString = [encryptionObjectDict valueForKey:@"valid_from"];
        NSString *endDateString = [encryptionObjectDict valueForKey:@"valid_until"];
        //Create a formatter
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //Set the format & TimeZone - essential as otherwise the time component wont be used
        [formatter setDateFormat:@"yyyy’-‘MM’-‘dd’T’HH’:’mm’:’ss"];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        //Create your NSDate
        NSDate *validFrom = [formatter dateFromString:startDateString];
        NSDate *validUntil = [formatter dateFromString:endDateString];
        [encryptionSet setEnabledTimestamp:[NSNumber numberWithDouble:[validFrom timeIntervalSince1970]]];
        [encryptionSet setDisableTimestamp:[NSNumber numberWithDouble:[validUntil timeIntervalSince1970]]];
        
        [encryptionSet setKeyType:[encryptionObjectDict valueForKey:@"algorithm"]];//key_type changed to and algorithm
        
        
       // [encryptionSet setUpdatedTimestamp:[NSNumber numberWithDouble:[[encryptionObjectDict valueForKey:@"updated"] doubleValue]]];
       // [encryptionSet setCreatedTimestamp:[NSNumber numberWithDouble:[[encryptionObjectDict valueForKey:@"created"] doubleValue]]];
        
        
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Error, couldn't save: %@", [error localizedDescription]);
        }
    }
}
 */

- (void)deleteEncryptedSetById:(NSNumber *)idNum
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:ENCRYPTION_SET_MODEL inManagedObjectContext:self.managedObjectContext]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"idNum == %@", idNum];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *encryptionSets = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (EncryptionSet *encryptionSet in encryptionSets) {
        [self.managedObjectContext deleteObject:encryptionSet];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
