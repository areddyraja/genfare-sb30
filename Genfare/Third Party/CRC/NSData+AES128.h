//
//  NSData+AES128.h
//  CooCooBase
//
//  Created by John Scuteri on 9/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (AES128)

- (NSData *)AES128EncryptDataWithKey:(NSData *)key mode:(CCOptions)operationMode;
- (NSData *)AES128DecryptDataWithKey:(NSData *)key mode:(CCOptions)operationMode;
- (NSData *)AES128EncryptDataWithKey:(NSData *)key iv:(NSData *)iv mode:(CCOptions)operationMode;
- (NSData *)AES128DecryptDataWithKey:(NSData *)key iv:(NSData *)iv mode:(CCOptions)operationMode;

@end
