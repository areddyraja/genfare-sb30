//
//  OAuth.m
//  CDTATicketing
//
//  Created by omniwyse on 12/10/17.
//  Copyright © 2017 CooCoo. All rights reserved.
//

#import "OAuth.h"

NSString *const NO_OAUTH = @"No OAuth";

@implementation OAuth

- (BOOL)containsAccessToken:(NSString *)access{
    
    if (self.accessToken == access) {
        return YES;
    }else{
        return NO;
    }
}

@end
