//
//  NSData+AES128.m
//  CooCooBase
//
//  Created by John Scuteri on 9/18/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "NSData+AES128.h"


@implementation NSData (AES128)

- (NSData *)AES128EncryptDataWithKey:(NSData *)key mode:(CCOptions)operationMode
{
    return [self AES128EncryptDataWithKey:key iv:nil mode:operationMode];
}

- (NSData *)AES128DecryptDataWithKey:(NSData *)key mode:(CCOptions)operationMode
{
    return [self AES128DecryptDataWithKey:key iv:nil mode:operationMode];
}

- (NSData *)AES128EncryptDataWithKey:(NSData *)key iv:(NSData *)iv mode:(CCOptions)operationMode
{
    return [self AES128Operation:kCCEncrypt key:key iv:iv mode:operationMode];
}

- (NSData *)AES128DecryptDataWithKey:(NSData *)key iv:(NSData *)iv mode:(CCOptions)operationMode
{
    return [self AES128Operation:kCCDecrypt key:key iv:iv mode:operationMode];
}

- (NSData *)AES128Operation:(CCOperation)operation key:(NSData *)key iv:(NSData *)iv mode:(CCOptions)operationMode
{
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          operationMode,
                                          key.bytes,
                                          kCCBlockSizeAES128,
                                          iv.bytes,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    
    return nil;
}

@end
