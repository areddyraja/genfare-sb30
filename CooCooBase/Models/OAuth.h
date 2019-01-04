//
//  OAuth.h
//  CDTATicketing
//
//  Created by omniwyse on 12/10/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuth : NSObject

FOUNDATION_EXPORT NSString *const NO_OAUTH;

@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *tokenType;
@property (copy, nonatomic) NSNumber *expiresIn;
@property (copy, nonatomic) NSString *scope;

- (BOOL)containsAccessToken:(NSString *)accessToken;

@end
