//
//  CardEventRevision.m
//  CooCooBase
//
//  Created by CooCooTech on 5/10/16.
//  Copyright © 2016 CooCoo. All rights reserved.
//

#import "CardEventRevision.h"

@implementation CardEventRevision

NSString *const KEY_REVISION_ID = @"revisionId";

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        self.revisionId = [decoder decodeInt64ForKey:KEY_REVISION_ID];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt64:self.revisionId forKey:KEY_REVISION_ID];
}

@end
