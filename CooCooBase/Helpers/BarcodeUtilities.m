//
//  BarcodeUtilities.m
//  CooCooBase
//
//  Created by CooCooTech on 4/16/15.
//  Copyright (c) 2015 CooCoo. All rights reserved.
//

#import "BarcodeUtilities.h"
#import "AppConstants.h"
#import "EncryptionSet.h"
#import "EncryptionKey.h"
#import "NSBundle+BaseResourcesBundle.h"
#import "NSData+AES128.h"
#import "NSData+Base64.h"
#import "Utilities.h"
#import "zint.h"
#import "Product.h"
#import "RNEncryptor.h"
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)


@implementation BarcodeUtilities

+ (UIImageView *)regenerateBarcodeWithTicket:(WalletContents *)ticket
                                   accountId:(NSString *)accountId
                        managedObjectContext:(NSManagedObjectContext *)managedObjectContext
                               viewContainer:(UIView *)viewContainer
{
    UIImage *barcodeImage = [self generateBarcodeWithTicket:ticket accountId:accountId managedObjectContext:managedObjectContext];
    
    float barcodeWidth = barcodeImage.size.width / 2;
    float barcodeHeight = barcodeImage.size.height / 2;
    
    UIImageView *barcodeView = [[UIImageView alloc] initWithImage:barcodeImage];
    
//    [barcodeView setFrame:CGRectMake((viewContainer.frame.size.width / 2) - (barcodeWidth / 2),
//                                     (viewContainer.frame.size.height / 2) - (barcodeHeight / 2),
//                                     barcodeWidth,
//                                     barcodeHeight)];
    
    [barcodeView setFrame:CGRectMake((viewContainer.frame.size.width / 2) - (barcodeWidth / 2),
                                     SCREEN_HEIGHT/6,
                                     barcodeWidth,
                                     barcodeHeight)];
    
    return barcodeView;
}

+ (UIImage *)generateBarcodeWithTicket:(WalletContents *)ticket
                             accountId:(NSString *)accountId
                  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    
    
    
    
    Product *ticketProduct;
    NSArray *fetchedObjects;
     NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRODUCT_MODEL  inManagedObjectContext: managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(ticketId == %@)",ticket.ticketIdentifier]];
    NSError * error = nil;
    fetchedObjects = [managedObjectContext executeFetchRequest:fetch error:&error];
    
    
    if(fetchedObjects.count>0){
        ticketProduct=fetchedObjects.firstObject;
    }
    
    NSArray *encryptionKeys = [[NSArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ENCRYPTION_KEY_MODEL];
    encryptionKeys = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    EncryptionKey *currentKey = nil;
    for (EncryptionKey *key in encryptionKeys) {
        currentKey=key;
            
    }
    int transitId_int = ((NSNumber *) [[NSUserDefaults standardUserDefaults] valueForKey:@"TRANSIT_ID"]).intValue;
    long departingStation=0;
    long arrivingStation=0;
    NSString *transitId=[NSString stringWithFormat:@"%d", transitId_int];
    NSString *sellerId=@"App";
    NSString *zone=@"SzTy";
    NSString *activation = TYPE_APP;
    NSNumber *passengercount=[NSNumber numberWithInt:1];
    NSNumber *activationCount=[NSNumber numberWithInt:1];
    
    NSString *ticketGroup=ticket.ticketGroup;
    NSString *memberID=ticket.member;
    
 
     if(ticketGroup==nil||[ticketGroup isKindOfClass:[NSNull class]]||[ticketGroup length]==0){
         ticketGroup = [[NSUserDefaults standardUserDefaults] objectForKey:@"accticketgroupid"];
    }
    
    
    if(memberID==nil||[memberID isKindOfClass:[NSNull class]]||[memberID  length]==0){
        memberID = [[NSUserDefaults standardUserDefaults] objectForKey:@"accmemberid"];
    }
    
    
    NSData *pngData = nil;
    
    if (currentKey  ) {
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
        
       
        
//        if (ticket.de) {
//            departingStation = [ticket.departureStation longValue];//NSNumber allows long
//        } else {
//            departingStation = [ticket.departId intValue];//NSString to int
//        }
//
//        if (ticket.arrivalStation) {
//            arrivingStation = [ticket.arrivalStation longValue];//NSNumber allows long
//        } else {
//            arrivingStation = [ticket.arriveId intValue];//NSString to int
//        }
        
        
        NSString *currentTimeInSec=[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
        float ticketFare;
        NSString * isFreeRideString = [[NSUserDefaults standardUserDefaults] valueForKey:@"isFreeRide"];
        if ([isFreeRideString isEqualToString:@"YES"]) {
            ticketFare = 0.0;
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isFreeRide"];
        }else{
            ticketFare = [ticket.fare floatValue];
        }
        NSMutableString *barcodeString = [[NSMutableString alloc]init];
        barcodeString = [NSMutableString stringWithFormat:@"%6s%10s%2s%8s%5s%8s%1s%4s%4s%4s%4s%1s%@%10@%10@%6s%2s%2s%2s%2s%2s",
                         [[self fillString:transitId requiredLength:6] UTF8String],                                  // length 6 (alphanumeric)
                         [[self fillString:ticketGroup requiredLength:10] UTF8String],                             // 10 (alphanumeric)
                         [[self fillString:memberID requiredLength:2] UTF8String],                                   // 2  (alphabetic)
                         [[self fillString:[Utilities deviceId] requiredLength:8] UTF8String],                              // 8  Delivery ID (UTF-8)
                         [[self fillString:ticketProduct.fareCode requiredLength:5] UTF8String],                                   // 5  (alphanumeric)
                         
                         [[self fillString:[NSString stringWithFormat:@"%.2f", ticketFare]                // 8  (2-decimal float)
                            requiredLength:8] UTF8String],
                         
                         [[self fillString:[self convertToBase36:0] requiredLength:1] UTF8String],                          // 1  Seller Type (Base36)
                         [[self fillString:sellerId requiredLength:4] UTF8String],                                   // 4  (alphabetic)
                         [[self fillString:[self convertToBase36:departingStation] requiredLength:4] UTF8String],			// 4  (Base36)
                         [[self fillString:[self convertToBase36:arrivingStation] requiredLength:4] UTF8String],			// 4  (Base36)
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
        
        NSString *encryptedString;
        
        if ([currentKey.algorithm.lowercaseString isEqualToString:ENCRYPTION_TYPE_AES]) {
            
            NSData *ivData = [[NSData alloc] initWithBase64EncodedString:currentKey.initializationVector options:0];
            NSData *keyData = [[NSData alloc] initWithBase64EncodedString:currentKey.secretKey options:0];
            
            NSData *passcodeData = [barcodeString dataUsingEncoding:NSUTF8StringEncoding];
            NSData *encryptedData = [passcodeData AES128EncryptDataWithKey:keyData iv:ivData];
 
            encryptedString = [encryptedData base64EncodedString];
     
         } else if ([currentKey.algorithm.lowercaseString isEqualToString:ENCRYPTION_TYPE_RSA]) {
            encryptedString = [self encryptString:barcodeString];
        }
        
        encryptedString = [NSString stringWithFormat:@"%@%@%@%@", prefix, orgId, keyId, encryptedString];
        
        struct zint_symbol *my_symbol = ZBarcode_Create();
        my_symbol->symbology = BARCODE_QRCODE;
        my_symbol->scale = 2.5;
        ZBarcode_Encode_and_Buffer(my_symbol,
                                   (unsigned char*)[encryptedString cStringUsingEncoding:NSASCIIStringEncoding],
                                   0, 0);
        /*
         * rgba array contains values (usually either 0 or 255) following the pattern of red, green, blue, then alpha
         * where 4 consecutive values correspond to one pixel color description
         */
        int width = my_symbol->bitmap_width;
        int height = my_symbol->bitmap_height;
        char *myBuffer = my_symbol->bitmap;
        char *rgba = (char *)malloc(width * height * 4);
        for (int i = 0; i < width * height; ++i) {
            rgba[4 * i] = myBuffer[3 * i];
            rgba[4 * i + 1] = myBuffer[3 * i + 1];
            rgba[4 * i + 2] = myBuffer[3 * i + 2];
            rgba[4 * i + 3] = 0;
        }
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef bitmapContext = CGBitmapContextCreate(rgba,
                                                           width,
                                                           height,
                                                           8,           // Bits per component
                                                           4 * width,   // Bytes per row
                                                           colorSpace,
                                                           (CGBitmapInfo) kCGImageAlphaNoneSkipLast);
        CFRelease(colorSpace);
        
        CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
        UIImage *barcodeImage = [UIImage imageWithCGImage:cgImage];
        
        CFRelease(cgImage);
        CFRelease(bitmapContext);
        free(rgba);
        
        pngData = UIImagePNGRepresentation(barcodeImage);
        ZBarcode_Delete(my_symbol);
        
        // Create a copy of the image
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@tickets", transitId]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSLog(@"created directory to store barcodes");
            
            if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error]) {
                //NSLog(@"Create directory error: %@", error);
            }
        }
        
        path = [path stringByAppendingPathComponent:[ticket.identifier stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:pngData
                                              attributes:nil];
    } else {
        // No Encryption available
        // Get a copy of the image
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@tickets", transitId]];

        path = [path stringByAppendingPathComponent:[ticket.identifier stringByReplacingOccurrencesOfString:@" " withString:@""]];
        pngData = [[NSData alloc]initWithContentsOfFile:path];
    }
    
    return [UIImage imageWithData:pngData];
}

+ (NSString *)encryptString:(NSString *)string;
{
    NSString *resourcePath = [[NSBundle baseResourcesBundle] pathForResource:@"public_key" ofType:@"der"];
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
    if ([activationTypeString caseInsensitiveCompare:TYPE_APP] == NSOrderedSame) {
        return 0;
    } else if ([activationTypeString caseInsensitiveCompare:@"pin"] == NSOrderedSame) {
        return 2;
    } else {
        return 1;
    }
}

@end
