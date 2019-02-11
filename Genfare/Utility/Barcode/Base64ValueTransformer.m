//
//  Base64ValueTransformer.m
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "Base64ValueTransformer.h"
#import <UIKit/UIKit.h>
#import "NSData+Base64.h"
#import "RNDecryptor.h"
#import "RNEncryptor.h"

/*Not used abywhere. can be safely deleted */
NSString *const AES256_KEY = @"coocoo356";

@implementation Base64ValueTransformer {}

#pragma mark - NSValueTransformer methods

+ (Class)transformedValueClass
{
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(NSData *)data
{
    if (data == nil) {
        return nil;
    }
    
    NSData *pngData = UIImagePNGRepresentation([UIImage imageWithData:data]);
    NSData *encryptedData = [RNEncryptor encryptData:pngData
                                        withSettings:kRNCryptorAES256Settings
                                            password:AES256_KEY
                                               error:nil];
    
    return [NSData dataFromBase64String:[encryptedData base64EncodedString]];
}

- (id)reverseTransformedValue:(id)value
{
    if (!([value length] > 0)) {
        return nil;
    }
    
    NSData *encryptedData = [NSData dataFromBase64String:[value base64EncodedString]];
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData withPassword:AES256_KEY error:nil];
    
    return [UIImage imageWithData:decryptedData];
}

@end
