//
//  NSDictionary+DataDictionary.h
//  CDTATicketing
//
//  Created by omniwyse on 27/07/18.
//  Copyright © 2018 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (DataDictionary)
- (NSDictionary *)dictionaryRemovingNSNullValues;
@end
