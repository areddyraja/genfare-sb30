//
//  NSManagedObject+Duplicate.h
//
//  Copyright (c) 2014 Barry Allard
//
//  MIT license
//
// inspiration: https://stackoverflow.com/questions/2998613/how-do-i-copy-or-move-an-nsmanagedobject-from-one-context-to-another 

#import <CoreData/CoreData.h>

@interface NSManagedObject (Duplicate)
// shallow copy of MOC ASSOCIATED object, does not update relationships
- (instancetype)duplicateAssociated;

// shallow copy of MOC UNASSOCIATED object, does not update relationships
- (instancetype)duplicateUnassociated;
@end
