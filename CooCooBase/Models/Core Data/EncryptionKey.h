//
//  EncryptionKey+CoreDataClass.h
//  
//
//  Created by Omniwyse on 2/13/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

 NSString *const ENCRYPTION_KEY_MODEL = @"EncryptionKey";

@interface EncryptionKey : NSManagedObject

@property (nullable, nonatomic, copy) NSString *algorithm;
@property (nullable, nonatomic, copy) NSString *keyId;
@property (nullable, nonatomic, copy) NSString *initializationVector;
@property (nullable, nonatomic, copy) NSString *secretKey;
@end



