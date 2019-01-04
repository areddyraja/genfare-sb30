//
//  Map.h
//  CDTA
//
//  Created by CooCooTech on 10/22/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Map : NSObject

@property (copy, nonatomic) NSString *name;
@property (nonatomic) BOOL isLocal;
@property (copy, nonatomic) NSString *uri;

@end
