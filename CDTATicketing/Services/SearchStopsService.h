//
//  SearchStopsService.h
//  CDTA
//
//  Created by CooCooTech on 12/18/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "CooCooBase.h"

@interface SearchStopsService : BaseService

@property (copy, nonatomic) NSString *searchTerm;

- (id)initWithListener:(id)listener;

@end
