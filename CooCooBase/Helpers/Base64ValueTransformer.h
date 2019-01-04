//
//  Base64ValueTransformer.h
//  CooCooBase
//
//  Created by CooCooTech on 8/21/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>
/*Not used abywhere. can be safely deleted */
@interface Base64ValueTransformer : NSValueTransformer

- (id)transformedValue:(NSString *)string;
- (id)reverseTransformedValue:(NSData *)data;

@end
