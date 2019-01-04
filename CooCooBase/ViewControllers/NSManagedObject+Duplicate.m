//
//  NSManagedObject+Duplicate.m
//
//  Copyright (c) 2014 Barry Allard
//
//  MIT license
//
// inspiration: https://stackoverflow.com/questions/2998613/how-do-i-copy-or-move-an-nsmanagedobject-from-one-context-to-another 

#import "NSManagedObject+Duplicate.h"

@implementation NSManagedObject (Duplicate)
- (void)duplicateToTarget:(NSManagedObject *)target
{
    NSEntityDescription *entityDescription = self.objectID.entity;
    NSArray *attributeKeys = entityDescription.attributesByName.allKeys;
    NSDictionary *attributeKeysAndValues = [self dictionaryWithValuesForKeys:attributeKeys];
    [target setValuesForKeysWithDictionary:attributeKeysAndValues];
}

- (instancetype)duplicateAssociated
{
    NSManagedObject *result = [NSEntityDescription
                               insertNewObjectForEntityForName:self.objectID.entity.name
                                        inManagedObjectContext:self.managedObjectContext];
    
    [self duplicateToTarget:result];
    return result;
}

- (instancetype)duplicateUnassociated
{
    NSManagedObject *result = [[NSManagedObject alloc]
                                               initWithEntity:self.entity
                               insertIntoManagedObjectContext:nil];
    [self duplicateToTarget:result];
    return result;
}
@end