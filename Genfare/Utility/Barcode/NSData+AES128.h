//
//  NSData+AES128.h
//  CooCooBase
//
//  Created by John Scuteri on 9/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES128)

- (NSData *)AES128EncryptDataWithKey:(NSData *)key;
- (NSData *)AES128DecryptDataWithKey:(NSData *)key;
- (NSData *)AES128EncryptDataWithKey:(NSData *)key iv:(NSData *)iv;
- (NSData *)AES128DecryptDataWithKey:(NSData *)key iv:(NSData *)iv;

@end
