//
//  GetProductsService.m
//  CooCooBase
//
//  Created by ibasemac3 on 12/15/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "GetProductsService.h"
#import "Utilities.h"
#import "Product.h"
@implementation GetProductsService
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
- (NSDictionary *)headers
{
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    NSString * base64String = [Utilities accessToken];
    [headers setValue:[NSString stringWithFormat:@"bearer %@", base64String] forKey:@"Authorization"];
    [headers setValue:@"application/json" forKey:@"Accept"];
    return headers;
}

- (NSString *)uri
{
    NSString *walletid = [[NSUserDefaults standardUserDefaults]valueForKey:@"WALLET_ID"];
    NSString *tenantId = [Utilities tenantId];
    NSLog(@"GetProductsService URI: %@", [NSString stringWithFormat:@"services/data-api/mobile/products?tenant=%@",tenantId]);
    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"accountbased"]||walletid==nil){
         return [NSString stringWithFormat:@"services/data-api/mobile/products?tenant=%@",tenantId];
    }
    return [NSString stringWithFormat:@"services/data-api/mobile/products?tenant=%@&walletId=%@",tenantId,walletid];
}



- (BOOL)processResponse:(id)serverResult
{
    NSArray *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

//    NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
//    json = [json dictionaryRemovingNSNullValues];
    
    return [self setDataWithJson:json];
}

- (BOOL)setDataWithJson:(NSArray *)result
{
    BOOL success = YES;
    
    NSUInteger count = result.count;
    
    NSFetchRequest *productsService = [[NSFetchRequest alloc] init];
    [productsService setEntity:[NSEntityDescription entityForName:PRODUCT_MODEL inManagedObjectContext:self.managedObjectContext]];
    [productsService setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *productsList = [self.managedObjectContext executeFetchRequest:productsService error:&error];
    //error handling goes here
    for (NSManagedObject *product in productsList) {
        [self.managedObjectContext deleteObject:product];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    
    for (int i = 0; i < count; i++) {
        NSDictionary *productDict = result[i];
        
        Product *product = (Product *)[NSEntityDescription insertNewObjectForEntityForName:PRODUCT_MODEL inManagedObjectContext:self.managedObjectContext];

        if (![[productDict valueForKey:@"productId"] isEqual:[NSNull null]]) {
            [product setProductId:[productDict valueForKey:@"productId"]];
        }
        if (![[productDict valueForKey:@"fareCode"] isEqual:[NSNull null]]) {
            [product setFareCode:[productDict valueForKey:@"fareCode"]];
        }
        if (![[productDict valueForKey:@"offeringId"] isEqual:[NSNull null]]) {
            [product setOfferingId:[productDict valueForKey:@"offeringId"]];
        }
        if (![[productDict valueForKey:@"ticketId"] isEqual:[NSNull null]]) {
            [product setTicketId:[productDict valueForKey:@"ticketId"]];
        }
        if (![[productDict valueForKey:@"barcodeTimer"] isEqual:[NSNull null]]) {
            [product setBarcodeTimer:[productDict valueForKey:@"barcodeTimer"]];
        }
        if (![[productDict valueForKey:@"displayOrder"] isEqual:[NSNull null]]) {
            [product setDisplayOrder:[productDict valueForKey:@"displayOrder"]];
        }
        if (![[productDict valueForKey:@"isActivationOnly"] isEqual:[NSNull null]]) {
            
           [product setIsActivationOnly:[productDict valueForKey:@"isActivationOnly"]];
        }
        if (![[productDict valueForKey:@"isCappedRideEnabled"] isEqual:[NSNull null]]) {
            
            [product setIsCappedRideEnabled:[productDict valueForKey:@"isCappedRideEnabled"]];
        }
        if (![[productDict valueForKey:@"isBonusRideEnabled"] isEqual:[NSNull null]]) {
            
            [product setIsBonusRideEnabled:[productDict valueForKey:@"isBonusRideEnabled"]];
        }
        if (![[productDict valueForKey:@"productDescription"] isEqual:[NSNull null]]) {
            
            [product setProductDescription:[productDict valueForKey:@"productDescription"]];
        }
        
        if (![[productDict valueForKey:@"designator"] isEqual:[NSNull null]]) {
            [product setDesignator:[productDict valueForKey:@"designator"]];

        }
        if (![[productDict valueForKey:@"ticketTypeId"] isEqual:[NSNull null]]) {
            [product setTicketTypeId:[productDict valueForKey:@"ticketTypeId"]];

        }
        if (![[productDict valueForKey:@"ticketSubTypeId"] isEqual:[NSNull null]]) {
            [product setTicketSubTypeId:[productDict valueForKey:@"ticketSubTypeId"]];

        }
        if (![[productDict valueForKey:@"price"] isEqual:[NSNull null]]) {
         [product setPrice:[[productDict valueForKey:@"price"]stringValue]];

        }

        if (![[productDict valueForKey:@"ticketTypeDescription"] isEqual:[NSNull null]]) {
            [product setTicketTypeDescription:[productDict valueForKey:@"ticketTypeDescription"]];
        }
        
        if ([product.isBonusRideEnabled boolValue]== YES) {
            NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"BONUS_THRESHOLD"];
            product.bonusThreshold = value;
        }else{
            product.bonusThreshold = [NSNumber numberWithInteger:-1];
        }
        
        if ([product.isCappedRideEnabled boolValue]== YES) {
            NSNumber * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"CAPPED_THRESHOLD"];
            product.cappedThreshold = value;
        }else{
            product.cappedThreshold = [NSNumber numberWithInteger:-1];
        }
        NSError *error1;
        if (![self.managedObjectContext save:&error1]) {
            NSLog(@"Error, couldn't save: %@", [error1 localizedDescription]);
        } else {
            success = YES;
        }
        
    }
    return success;
}

-(NSString*)checkNullValue:(NSString*)str{
    return @"";
}


@end
