//
//  GetStoredValueProductsService.m
//  CDTATicketing
//
//  Created by CooCooTech on 9/30/15.
//  Copyright © 2015 CooCoo. All rights reserved.
//

#import "GetStoredValueProductsService.h"
#import "StoredValueDuration.h"
#import "StoredValueProduct.h"
#import "StoredValueProgramRule.h"
#import "StoredValueRange.h"
#import "StoredValueRuleCriteria.h"
#import "Tenant.h"

@implementation GetStoredValueProductsService
{
     NSString *cardId;
}

- (id)initWithListener:(id)listener
  managedObjectContext:(NSManagedObjectContext *)context
                cardId:(NSString *)card
{
    self = [super init];
    if (self) {
        self.method = METHOD_GET_JSON;
        self.listener = listener;
        self.managedObjectContext = context;
        cardId = card;
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
    return [NSString stringWithFormat:@"app/wallet/stored_value/products/%@", cardId];
}

 - (NSDictionary *)headers
{
    return nil;
}

- (NSDictionary *)createRequest
{
    return nil;
}

- (BOOL)processResponse:(id)serverResult
{
       NSDictionary *json=[NSJSONSerialization JSONObjectWithData:[serverResult dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    json = [json dictionaryRemovingNSNullValues];
    
    //NSLog(@"StoredValueProducts: %@", serverResult);
    
    if ([BaseService isResponseOk:json]) {
        [self deleteProducts];
        [self deletePrograms];
        
        [self setDataWithJson:[json valueForKey:@"result"]];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Other methods

- (void)setDataWithJson:(NSDictionary *)json
{
    NSArray *productsJson = [json valueForKey:@"products"];
    if (productsJson != nil) {
        for (NSDictionary *productJson in productsJson) {
            StoredValueProduct *product = (StoredValueProduct *)[NSEntityDescription insertNewObjectForEntityForName:STORED_VALUE_PRODUCT_MODEL
                                                                                              inManagedObjectContext:self.managedObjectContext];
            [product setProductId:[productJson valueForKey:@"id"]];
            [product setName:[productJson valueForKey:@"name"]];
            [product setAmount:[productJson valueForKey:@"amount"]];
            [product setProductDescription:[productJson valueForKey:@"description"]];
            [product setNote:[productJson valueForKey:@"note"]];
            [product setRevisionId:[productJson valueForKey:@"revision_id"]];
            [product setCode:[productJson valueForKey:@"code"]];
            [product setTicketGroupId:[productJson valueForKey:@"ticket_group_id"]];
            [product setMemberId:[productJson valueForKey:@"member_id"]];
            
            StoredValueRange *entrants = [[StoredValueRange alloc] init];
            
            NSDictionary *entrantsJson = [productJson objectForKey:@"entrants"];
            
            [entrants setMaximum:[[entrantsJson valueForKey:@"maximum"] floatValue]];
            [entrants setMinimum:[[entrantsJson valueForKey:@"minimum"] floatValue]];
            [entrants setStep:[[entrantsJson valueForKey:@"step"] floatValue]];
            [entrants setOrder:[entrantsJson valueForKey:@"order"]];
            [entrants setIsNegated:[[entrantsJson valueForKey:@"negated"] boolValue]];
            
            NSData *entrantsData = [NSKeyedArchiver archivedDataWithRootObject:entrants];
            
            [product setEntrants:entrantsData];
            
            Tenant *tenant = [[Tenant alloc] init];
            
            NSDictionary *tenantJson = [productJson objectForKey:@"tenant"];
            
            [tenant setTenantId:[[tenantJson valueForKey:@"id"] intValue]];
            [tenant setName:[tenantJson valueForKey:@"name"]];
            [tenant setShortName:[tenantJson valueForKey:@"shortName"]];
            [tenant setTimeZone:[tenantJson valueForKey:@"timeZone"]];
            
            NSData *tenantData = [NSKeyedArchiver archivedDataWithRootObject:tenant];
            
            [product setTenant:tenantData];
            
            NSDictionary *ticketSettingsJson = [productJson objectForKey:@"ticket_settings"];
            NSData *ticketSettingsData = [NSKeyedArchiver archivedDataWithRootObject:ticketSettingsJson];
            
            [product setTicketSettings:ticketSettingsData];
            
            [product setIsForSale:[NSNumber numberWithBool:YES]];
            
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"Error, couldn't save: %@", [saveError localizedDescription]);
            }
        }
    }
    
    NSArray *programsJson = [json valueForKey:@"programs"];
    if (programsJson != nil) {
        for (NSDictionary *programJson in programsJson) {
            NSArray *rulesJson = [programJson valueForKey:@"rules"];
            if (rulesJson != nil) {
                for (NSDictionary *ruleJson in rulesJson) {
                    StoredValueProgramRule *rule = (StoredValueProgramRule *)[NSEntityDescription insertNewObjectForEntityForName:STORED_VALUE_PROGRAM_RULE_MODEL
                                                                                                           inManagedObjectContext:self.managedObjectContext];
                    
                    for (int i = 0; i < 2; i++) {
                        NSDictionary *programRuleJson;
                        
                        if (i == 0) {
                            programRuleJson = [ruleJson objectForKey:@"benefit"];
                        } else {
                            programRuleJson = [ruleJson objectForKey:@"requirement"];
                        }
                        
                        StoredValueRuleCriteria *criteria = [[StoredValueRuleCriteria alloc] init];
                        [criteria setAttribute:[programRuleJson valueForKey:@"attribute"]];
                        
                        NSDictionary *entrantsJson = [programRuleJson objectForKey:@"entrants"];
                        
                        if (entrantsJson) {
                            StoredValueRange *entrants = [[StoredValueRange alloc] init];
                            
                            [entrants setMaximum:[[entrantsJson valueForKey:@"maximum"] floatValue]];
                            [entrants setMinimum:[[entrantsJson valueForKey:@"minimum"] floatValue]];
                            [entrants setStep:[[entrantsJson valueForKey:@"step"] floatValue]];
                            [entrants setOrder:[entrantsJson valueForKey:@"order"]];
                            [entrants setIsNegated:[[entrantsJson valueForKey:@"negated"] boolValue]];
                            
                            [criteria setEntrants:entrants];
                        }
                        
                        NSMutableArray *productCodes = [[NSMutableArray alloc] init];
                        
                        NSArray *productsJson = [programRuleJson valueForKey:@"products"];
                        
                        for (NSDictionary *productJson in productsJson) {
                            NSString *productCode = [productJson valueForKey:@"code"];
                            
                            [productCodes addObject:productCode];
                            
                            StoredValueProduct *product = (StoredValueProduct *)[NSEntityDescription insertNewObjectForEntityForName:STORED_VALUE_PRODUCT_MODEL
                                                                                                              inManagedObjectContext:self.managedObjectContext];
                            [product setProductId:[productJson valueForKey:@"id"]];
                            [product setName:[productJson valueForKey:@"name"]];
                            [product setAmount:[productJson valueForKey:@"amount"]];
                            [product setProductDescription:[productJson valueForKey:@"description"]];
                            [product setNote:[productJson valueForKey:@"note"]];
                            [product setRevisionId:[productJson valueForKey:@"revision_id"]];
                            [product setCode:productCode];
                            [product setTicketGroupId:[productJson valueForKey:@"ticket_group_id"]];
                            [product setMemberId:[productJson valueForKey:@"member_id"]];
                            
                            StoredValueRange *entrants = [[StoredValueRange alloc] init];
                            
                            NSDictionary *entrantsJson = [productJson objectForKey:@"entrants"];
                            
                            [entrants setMaximum:[[entrantsJson valueForKey:@"maximum"] floatValue]];
                            [entrants setMinimum:[[entrantsJson valueForKey:@"minimum"] floatValue]];
                            [entrants setStep:[[entrantsJson valueForKey:@"step"] floatValue]];
                            [entrants setOrder:[entrantsJson valueForKey:@"order"]];
                            [entrants setIsNegated:[[entrantsJson valueForKey:@"negated"] boolValue]];
                            
                            NSData *entrantsData = [NSKeyedArchiver archivedDataWithRootObject:entrants];
                            
                            [product setEntrants:entrantsData];
                            
                            Tenant *tenant = [[Tenant alloc] init];
                            
                            NSDictionary *tenantJson = [productJson objectForKey:@"tenant"];
                            
                            [tenant setTenantId:[[tenantJson valueForKey:@"id"] intValue]];
                            [tenant setName:[tenantJson valueForKey:@"name"]];
                            [tenant setShortName:[tenantJson valueForKey:@"shortName"]];
                            [tenant setTimeZone:[tenantJson valueForKey:@"timeZone"]];
                            
                            NSData *tenantData = [NSKeyedArchiver archivedDataWithRootObject:tenant];
                            
                            [product setTenant:tenantData];
                            
                            NSDictionary *ticketSettingsJson = [productJson objectForKey:@"ticket_settings"];
                            NSData *ticketSettingsData = [NSKeyedArchiver archivedDataWithRootObject:ticketSettingsJson];
                            
                            [product setTicketSettings:ticketSettingsData];
                            
                            [product setIsForSale:[NSNumber numberWithBool:NO]];
                            
                            NSError *saveError;
                            if (![self.managedObjectContext save:&saveError]) {
                                NSLog(@"Error, couldn't save: %@", [saveError localizedDescription]);
                            }
                        }
                        
                        // Use the productCode as the ID
                        [criteria setProductIds:[productCodes copy]];
                        
                        StoredValueDuration *window = [[StoredValueDuration alloc] init];
                        
                        NSDictionary *windowJson = [programRuleJson objectForKey:@"window"];
                        
                        [window setDuration:[[windowJson valueForKey:@"duration"] integerValue]];
                        [window setOffset:[[windowJson valueForKey:@"offset"] intValue]];
                        
                        [criteria setWindow:window];
                        
                        NSDictionary *amountJson = [programRuleJson objectForKey:@"amount"];
                        
                        if (amountJson) {
                            StoredValueVector *amount = [[StoredValueVector alloc] init];
                            
                            [amount setMagnitude:[[amountJson valueForKey:@"magnitude"] floatValue]];
                            [amount setType:[amountJson valueForKey:@"type"]];
                            
                            [criteria setAmount:amount];
                        }
                        
                        NSData *criteriaData = [NSKeyedArchiver archivedDataWithRootObject:criteria];
                        
                        if (i == 0) {
                            [rule setBenefit:criteriaData];
                        } else {
                            [rule setRequirement:criteriaData];
                        }
                    }
                    
                    NSError *saveError;
                    if (![self.managedObjectContext save:&saveError]) {
                        NSLog(@"Error, couldn't save: %@", [saveError localizedDescription]);
                    }
                }
            }
        }
    }
}

- (void)deleteProducts
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:STORED_VALUE_PRODUCT_MODEL
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *storedValueProducts = [[NSMutableArray alloc] initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    
    for (StoredValueProduct *product in storedValueProducts) {
        [self.managedObjectContext deleteObject:product];
        
        NSError *saveError = nil;
        [self.managedObjectContext save:&saveError];
    }
}

- (void)deletePrograms
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:STORED_VALUE_PROGRAM_RULE_MODEL
                                        inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error = nil;
    NSArray *rules = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (StoredValueProgramRule *rule in rules) {
        [self.managedObjectContext deleteObject:rule];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}

@end
