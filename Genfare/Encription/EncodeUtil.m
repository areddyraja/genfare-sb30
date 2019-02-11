//
//  EncodeUtil.m
//  Genfare
//
//  Created by omniwzse on 12/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

#import "EncodeUtil.h"
#import <MapKit/MapKit.h>
#import "iRide-Swift.h"

@implementation EncodeUtil

// http://objc.id.au/post/9245961184/mapkit-encoded-polylines
+ (NSMutableArray *)decodePolyLine:(NSString *)encodedStr
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    const char *bytes = [encodedStr UTF8String];
    NSUInteger length = [encodedStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:finalLat longitude:finalLon];
        [array addObject:loc];
    }
    
    return array;
}

@end
