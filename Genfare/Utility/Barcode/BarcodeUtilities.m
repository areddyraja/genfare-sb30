//
//  BarcodeUtilities.m
//  CooCooBase
//
//  Created by CooCooTech on 4/16/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "BarcodeUtilities.h"
#import "NSData+AES128.h"
#import "NSData+Base64.h"

@implementation BarcodeUtilities

+ (NSString *)generateBarcodeWithTicket:(WalletContents *)ticket
                                product:(Product *)product
                          encriptionKey:(EncryptionKey *)encriptionKey
                             isFreeRide:(BOOL)isFreeRide
                               deviceID:(NSString *)deviceID
                              transitID:(NSNumber *)transitID
                              accountId:(NSString *)accountId
{
    Product *ticketProduct;
    NSString *encryptedString;
    EncryptionKey *currentKey;

    ticketProduct = product;
    currentKey=encriptionKey;
    
    int transitId_int = transitID.intValue;
    long departingStation=0;
    long arrivingStation=0;
    NSString *transitId=[NSString stringWithFormat:@"%d", transitId_int];
    NSString *sellerId=@"App";
    NSString *zone=@"SzTy";
    NSString *activation = @"app";
    NSNumber *passengercount=[NSNumber numberWithInt:1];
    NSNumber *activationCount=[NSNumber numberWithInt:1];
    
    NSString *ticketGroup=ticket.ticketGroup;
    NSString *memberID = ticket.member;
    
    float ticketFare = [ticket.fare floatValue];

    NSMutableString *barcodeString = [[NSMutableString alloc]init];
    barcodeString = [NSMutableString stringWithFormat:@"%6s%10s%2s%8s%5s%8s%1s%4s%4s%4s%4s%1s%@%10@%10@%6s%2s%2s%2s%2s%2s",
                     [[self fillString:transitId requiredLength:6] UTF8String],                                  // length 6 (alphanumeric)
                     [[self fillString:ticketGroup requiredLength:10] UTF8String],                             // 10 (alphanumeric)
                     [[self fillString:memberID requiredLength:2] UTF8String],                                   // 2  (alphabetic)
                     [[self fillString:deviceID requiredLength:8] UTF8String],                              // 8  Delivery ID (UTF-8)
                     [[self fillString:ticketProduct.fareCode requiredLength:5] UTF8String],                                   // 5  (alphanumeric)
                     
                     [[self fillString:[NSString stringWithFormat:@"%.2f", ticketFare]                // 8  (2-decimal float)
                        requiredLength:8] UTF8String],
                     
                     [[self fillString:[self convertToBase36:0] requiredLength:1] UTF8String],                          // 1  Seller Type (Base36)
                     [[self fillString:sellerId requiredLength:4] UTF8String],                                   // 4  (alphabetic)
                     [[self fillString:[self convertToBase36:departingStation] requiredLength:4] UTF8String],            // 4  (Base36)
                     [[self fillString:[self convertToBase36:arrivingStation] requiredLength:4] UTF8String],            // 4  (Base36)
                     [[self fillString:zone requiredLength:4] UTF8String],                                     // 4  Zone ID (alphanumeric)
                     
                     // 1  (Base36)
                     [[self fillString:[self convertToBase36:[self activationTypeForString:activation]] requiredLength:1] UTF8String],
                     
                     [NSString stringWithFormat:@"%lli",[ticket.purchasedDate longLongValue]/1000 ],                                                     // 10 (integer)
                     [NSString stringWithFormat:@"%lli",[ticket.generationDate longLongValue]/1000 ],                                                   // 10 (integer)
                     [NSString stringWithFormat:@"%lli",[ticket.generationDate longLongValue]/1000 ],                                                                     // 10 Generated Timestamp (integer)
                     [[self fillString:accountId requiredLength:6] UTF8String],                                             // 6  (alphanumeric)
                     [[self fillString:[self convertToBase36:[passengercount intValue]] requiredLength:2] UTF8String],   // 2  Passenger Count (Base36)
                     
                     // 2 (Base36)
                     [[self fillString:[self convertToBase36:[activationCount longValue]] requiredLength:2] UTF8String],
                     
                     [[self fillString:[self convertToBase36:0] requiredLength:2] UTF8String],                              // 2  Current Transfer Count (Base36)
                     [[self fillString:[self convertToBase36:0] requiredLength:2] UTF8String],                              // 2  Language ID (Base36)
                     [[self fillString:[self convertToBase36:0] requiredLength:2] UTF8String]];                             // 2  Currency ID (Base36)
    barcodeString = [NSMutableString stringWithFormat:@"%128s", [[self padString:barcodeString requiredLength:128] UTF8String]];
    
    NSString *prefix = @"CC356";
    NSString *orgId = [self fillString:[transitId uppercaseString] requiredLength:6];
    NSString *keyId = [self fillString:[currentKey.keyId uppercaseString] requiredLength:5];
    
    if ([currentKey.algorithm.lowercaseString isEqualToString:@"aes"]) {
        
        NSData *ivData = [[NSData alloc] initWithBase64EncodedString:currentKey.initializationVector options:0];
        NSData *keyData = [[NSData alloc] initWithBase64EncodedString:currentKey.secretKey options:0];
        
        NSData *passcodeData = [barcodeString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedData = [passcodeData AES128EncryptDataWithKey:keyData iv:ivData];
        
        encryptedString = [encryptedData base64EncodedString];
        
    } else if ([currentKey.algorithm.lowercaseString isEqualToString:@"rsa"]) {
        encryptedString = [self encryptString:barcodeString];
    }
    
    encryptedString = [NSString stringWithFormat:@"%@%@%@%@", prefix, orgId, keyId, encryptedString];
    
    //TODO - need to handle this from Swift library
    //QRCode generation starts from here
    
    return encryptedString;
}

+ (NSString *)encryptString:(NSString *)string;
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *resourcePath = [mainBundle pathForResource: @"public_key" ofType: @"der"];
    NSData *certData = [NSData dataWithContentsOfFile:resourcePath];
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData);
    SecKeyRef publicKey = NULL;
    SecTrustRef trust = NULL;
    SecPolicyRef policy = NULL;
    
    if (cert != NULL) {
        policy = SecPolicyCreateBasicX509();
        if (policy) {
            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr) {
                SecTrustResultType result;
                if (SecTrustEvaluate(trust, &result) == noErr) {
                    publicKey = SecTrustCopyPublicKey(trust);
                }
            }
        }
    }
    
    if (policy) {
        CFRelease(policy);
    }
    
    if (trust) {
        CFRelease(trust);
    }
    
    if (cert) {
        CFRelease(cert);
    }
    
    if (publicKey) {
        NSData *inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
        const void *bytes = [inputData bytes];
        int length = (int) [inputData length];
        uint8_t *plainText = malloc(length);
        memcpy(plainText, bytes, length);
        
        size_t cipherBufferSize;
        uint8_t *cipherBuffer;
        cipherBufferSize = SecKeyGetBlockSize(publicKey);
        cipherBuffer = malloc(cipherBufferSize);
        
        SecKeyEncrypt(publicKey, kSecPaddingPKCS1, plainText, length, cipherBuffer, &cipherBufferSize);
        
        NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
        
        free(plainText);
        CFRelease(publicKey);
        free(cipherBuffer);
        
        return [encryptedData base64EncodedString];
    }
    
    return nil;
}

+ (NSString *)fillString:(NSString *)data requiredLength:(int)requiredLength
{
    return [self extendString:data requiredLength:requiredLength character:'$'];
}

+ (NSString *)padString:(NSString *)data requiredLength:(int)requiredLength
{
    char *paddedData = (char *)calloc(requiredLength, sizeof(char));
    
    NSUInteger dataLength = [data length];
    
    for (int i = 0; i < requiredLength; i++) {
        if (i < dataLength) {
            paddedData[i] = [data characterAtIndex:i];
        } else {
            paddedData[i] = '#';
        }
    }
    
    NSString *paddedString = [[NSString alloc] initWithBytes:paddedData length:requiredLength encoding:NSUTF8StringEncoding];
    
    free(paddedData);
    
    return paddedString;
}

+ (NSString *)extendString:(NSString *)data requiredLength:(int)requiredLength character:(char)character
{
    char *paddedData = (char *)calloc(requiredLength, sizeof(char));
    
    NSUInteger dataLength = [data length];
    
    for (int i = 0; i < requiredLength; i++) {
        if (i < dataLength) {
            paddedData[i] = [data characterAtIndex:i];
        } else {
            paddedData[i] = character;
        }
    }
    
    NSString *paddedString = [[NSString alloc] initWithBytes:paddedData length:requiredLength encoding:NSUTF8StringEncoding];
    
    free(paddedData);
    
    return paddedString;
}

+ (NSString *)convertToBase36:(long)numberIn
{
    static char encodingTable[36] = {
        '0','1','2','3','4','5','6','7','8','9',
        'A','B','C','D','E','F','G','H','I','J',
        'K','L','M','N','O','P','Q','R','S','T',
        'U','V','W','X','Y','Z' };
    
    if (numberIn == 0) {
        return @"0";
    } else {
        long input = numberIn;
        NSMutableString *output = [[NSMutableString alloc] initWithString:@""];
        
        while (input > 0) {
            output = [NSMutableString stringWithFormat:@"%c%@", encodingTable[input % 36], output];
            input = input / 36;
        }
        
        return output;
    }
}

+ (int)activationTypeForString:(NSString *)activationTypeString
{
    if ([activationTypeString caseInsensitiveCompare:@"app"] == NSOrderedSame) {
        return 0;
    } else if ([activationTypeString caseInsensitiveCompare:@"pin"] == NSOrderedSame) {
        return 2;
    } else {
        return 1;
    }
}

@end
